//
//  SetLogInputView.swift
//  Lumberjacked
//

import SwiftUI

// MARK: - Mode

enum SetLogInputMode {
    /// Full table during an active workout: Previous, Reps, lbs, checkbox.
    case activeWorkout(previousSets: [LogSet]?)
    /// Editing a past log: Reps and lbs, no Previous, no checkbox.
    case editLog
    /// Creating or editing a MovementLogTemplate: Reps only, no Previous, no lbs, no checkbox.
    case editTemplate

    var showsPrevious: Bool {
        if case .activeWorkout = self { return true }
        return false
    }
    var showsLoad: Bool {
        if case .editTemplate = self { return false }
        return true
    }
    var showsCheckbox: Bool {
        if case .activeWorkout = self { return true }
        return false
    }
    var repsFieldWidth: CGFloat {
        if case .editTemplate = self { return 90 }
        return 52
    }
    var repsColumnLabel: String {
        if case .editTemplate = self { return "Reps / Range" }
        return "Reps"
    }
}

// MARK: - Focus identifier

private enum FocusedField: Hashable {
    case reps(UUID)
    case load(UUID)
}

// MARK: - Column widths

private enum Col {
    static let set:      CGFloat = 36
    static let previous: CGFloat = 100
    static let reps:     CGFloat = 52
    static let load:     CGFloat = 52
    static let checkbox: CGFloat = 28
}

// MARK: - SetLogInputView

struct SetLogInputView: View {

    let mode: SetLogInputMode
    var isEmbedded: Bool = false
    var readOnly: Bool = false

    @Binding var logSets:      [LogSet]
    @Binding var templateSets: [TemplateSet]

    @State private var editableSets: [EditableSet] = []

    @State private var showRestTimePicker = false
    @State private var pickerTargetSetId: UUID? = nil
    @State private var pickerMinutes: Int = 2
    @State private var pickerSeconds: Int = 0
    @FocusState private var focusedField: FocusedField?

    @State private var missingRepsSetId: UUID? = nil
    @State private var missingRepsNeedsLoad: Bool = false

    @State private var swipeOffsets: [UUID: CGFloat] = [:]
    @State private var dragBases:    [UUID: CGFloat] = [:]

    @State private var reorderDraggingId:    UUID? = nil
    @State private var reorderStartIndex:    Int   = 0
    @State private var reorderCurrentIndex: Int   = 0
    // Total height of one slot (row ≈ 44pt + pill layout height ≈ 8pt)
    private let reorderSlotHeight: CGFloat = 52

    // Amount the pill/button extends into each adjacent row (visual overlap).
    // Must be ≤ the content row's vertical padding so text is never covered.
    private let pillHalfHeight: CGFloat = 10
    private let deleteRevealWidth: CGFloat = 80

    @Environment(RestTimerEnvironment.self) private var restTimer
    @AppStorage("weightUnit") private var weightUnitRaw: String = WeightUnit.lb.rawValue

    private var weightUnit: WeightUnit { WeightUnit(rawValue: weightUnitRaw) ?? .lb }

    @State private var loadStrings: [UUID: String] = [:]

    // MARK: - Initializers

    init(mode: SetLogInputMode,
         logSets: Binding<[LogSet]>,
         templateSets: Binding<[TemplateSet]> = .constant([]),
         isEmbedded: Bool = false,
         readOnly: Bool = false) {
        self.mode          = mode
        self._logSets      = logSets
        self._templateSets = templateSets
        self.isEmbedded    = isEmbedded
        self.readOnly      = readOnly
    }

    init(mode: SetLogInputMode,
         templateSets: Binding<[TemplateSet]>,
         logSets: Binding<[LogSet]> = .constant([]),
         isEmbedded: Bool = false,
         readOnly: Bool = false) {
        self.mode          = mode
        self._logSets      = logSets
        self._templateSets = templateSets
        self.isEmbedded    = isEmbedded
        self.readOnly      = readOnly
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerRow
                .padding(.horizontal, 10)
            if isEmbedded {
                rowsContent
            } else {
                ScrollView { rowsContent }
            }
        }
        .alert("Rest time is up!", isPresented: Binding(
            get: { restTimer.showTimerAlert },
            set: { restTimer.showTimerAlert = $0 }
        )) {
            Button("OK") { }
        }
        .onAppear { loadFromBinding() }
        .onChange(of: weightUnitRaw) {
            for set in editableSets {
                loadStrings[set.id] = displayLoadString(set.load)
            }
        }
    }

    // MARK: - Rows content (shared between standalone and embedded modes)

    @ViewBuilder
    private var emptyStateRow: some View {
        if case .editTemplate = mode {
            Text("Tap '+' to add optional suggested sets and rep ranges to this movement")
                .font(DesignSystem.Font.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .background(Color.brandSecondary)
        } else {
            HStack(spacing: 8) {
                Image(systemName: "tray")
                    .foregroundStyle(.tertiary)
                Text("No sets logged")
                    .foregroundStyle(.secondary)
            }
            .font(DesignSystem.Font.body)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.brandSecondary)
        }
    }

    @ViewBuilder
    private var rowsContent: some View {
        VStack(spacing: 0) {
            if editableSets.isEmpty {
                emptyStateRow
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
                    .padding(.horizontal, 10)
            }
            ForEach(Array(editableSets.enumerated()), id: \.element.id) { index, _ in
                if index > 0 && !readOnly {
                    // Rest time pill between row (index-1) and row (index).
                    // Negative vertical padding makes it reduce its layout footprint
                    // so it visually overlaps both neighbors. zIndex(10) ensures it
                    // paints on top of both adjacent content rows (which use zIndex(1)).
                    restTimePill(above: $editableSets[index - 1], below: $editableSets[index])
                        .padding(.vertical, -pillHalfHeight)
                        .zIndex(10)
                }
                setRow($editableSets[index], index: index)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
                    .padding(.horizontal, 10)
                    .zIndex(1)
                    // Instant insertion prevents the red delete button from
                    // flashing through the content HStack during fade-in.
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
            }
            if !readOnly {
                // "+" button with the same overlap treatment as the pill.
                addSetButton
                    .padding(.top, -pillHalfHeight)
                    .zIndex(10)
            }
        }
        // Explicit background ensures the gap between rows shows brandBackground so
        // the brandBackground capsule fill blends in correctly.
        .background(Color.brandBackground)
    }

    // MARK: - Header row

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("Set")
                .frame(width: Col.set, alignment: .leading)
                .padding(.leading, 4)

            if mode.showsPrevious {
                Text("Previous")
                    .frame(width: Col.previous, alignment: .leading)
                    .padding(.leading, 12)
            }

            Spacer()

            Text(mode.repsColumnLabel)
                .frame(width: mode.repsFieldWidth, alignment: .center)

            if mode.showsLoad {
                Text(weightUnit.columnLabel)
                    .frame(width: Col.load, alignment: .center)
                    .padding(.leading, 8)   // matches loadField's padding(.leading, 8) in the row
            }

            if mode.showsCheckbox {
                Spacer().frame(width: Col.checkbox)
                    .padding(.leading, 8)   // matches checkboxButton's padding(.leading, 8) in the row
            }
        }
        .sectionLabel()
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    // MARK: - Set row (content only — no pill)

    @ViewBuilder
    private func setRow(_ set: Binding<EditableSet>, index: Int) -> some View {
        if readOnly {
            readOnlySetRow(set, index: index)
        } else {
            editableSetRow(set, index: index)
        }
    }

    private func readOnlySetRow(_ set: Binding<EditableSet>, index: Int) -> some View {
        let s = set.wrappedValue
        let workingIdx = editableSets.workingSetIndex(for: s.id)
        return HStack(spacing: 0) {
            Text(s.displayLabel(workingSetIndex: workingIdx))
                .font(.headline)
                .foregroundStyle(Color.brandPrimaryText)
                .frame(width: 28, height: 28)
                .background(Color.brandSecondaryLight)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                .frame(width: Col.set, alignment: .leading)
            Spacer()
            Text(s.reps.isEmpty ? "–" : s.reps)
                .font(.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(width: mode.repsFieldWidth)
            if mode.showsLoad {
                Text(formatLoad(s.load))
                    .font(.system(size: 17, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .frame(width: Col.load)
                    .padding(.leading, 8)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.brandSecondary)
    }

    private func formatLoad(_ load: Double?) -> String {
        guard let load else { return "–" }
        return displayLoadString(load)
    }

    private func displayLoadString(_ lbValue: Double?) -> String {
        guard let lbValue else { return "" }
        let displayValue = weightUnit.fromLb(lbValue)
        let rounded = (displayValue * 10).rounded() / 10
        return rounded.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(rounded)) : String(format: "%.1f", rounded)
    }

    private func updateLoadString(for id: UUID) {
        guard let idx = editableSets.firstIndex(where: { $0.id == id }) else { return }
        loadStrings[id] = displayLoadString(editableSets[idx].load)
    }

    @ViewBuilder
    private func editableSetRow(_ set: Binding<EditableSet>, index: Int) -> some View {
        let s = set.wrappedValue
        let workingIdx = editableSets.workingSetIndex(for: s.id)
        let previousSet = previousSetFor(s)
        let aboveSet: EditableSet? = {
            guard let idx = editableSets.firstIndex(where: { $0.id == s.id }), idx > 0 else { return nil }
            return editableSets[idx - 1]
        }()

        ZStack(alignment: .trailing) {
            // Opaque base — prevents the red delete button from flashing through
            // during row insertion animations before the content HStack renders.
            Color.brandSecondary

            // Red delete button, revealed when the content slides left.
            Button(role: .destructive) {
                withAnimation {
                    editableSets.removeAll { $0.id == s.id }
                    swipeOffsets.removeValue(forKey: s.id)
                    dragBases.removeValue(forKey: s.id)
                }
                syncToBinding()
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundStyle(.white)
                    .frame(width: deleteRevealWidth)
                    .frame(maxHeight: .infinity)
            }
            .background(Color.red)

            // Row content — slides left to reveal delete button.
            HStack(spacing: 0) {
                Menu {
                    ForEach(EditableSet.SetType.allCases, id: \.self) { type in
                        Button {
                            if let idx = editableSets.firstIndex(where: { $0.id == s.id }) {
                                editableSets[idx].setType = type
                                editableSets[idx].rest_time = EditableSet.defaultRestTime(for: type)
                                // Reset the running timer for the pill above this set if it is active.
                                // The effective rest for that pill may have changed (e.g. switching to a
                                // pre-rest type hands ownership of the pill to this set's new rest_time).
                                if idx > 0 {
                                    let aboveId = editableSets[idx - 1].id
                                    if restTimer.activeSetId == aboveId {
                                        let newRest: Int
                                        if editableSets[idx].setType.isPreRest {
                                            newRest = editableSets[idx].rest_time ?? 0
                                        } else {
                                            newRest = editableSets[idx - 1].rest_time ?? 0
                                        }
                                        if newRest > 0 {
                                            restTimer.start(seconds: newRest, setId: aboveId)
                                        } else {
                                            restTimer.cancel()
                                        }
                                    }
                                }
                                syncToBinding()
                            }
                        } label: {
                            if type == s.setType {
                                Label(type.fullName, systemImage: "checkmark")
                            } else {
                                Text(type.fullName)
                            }
                        }
                    }
                } label: {
                    Text(s.displayLabel(workingSetIndex: workingIdx))
                        .font(.headline)
                        .foregroundStyle(Color.brandPrimaryText)
                        .frame(width: 28, height: 28)
                        .background {
                            ZStack {
                                if s.isChecked { Color.brandSecondary } else { Color.brandSecondaryLight }
                                if s.isChecked { Color.green.opacity(0.25) }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                }
                .frame(width: Col.set, alignment: .leading)

                if mode.showsPrevious {
                    Text(previousText(previousSet))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: Col.previous, alignment: .leading)
                        .padding(.leading, 12)
                        .lineLimit(1)
                }

                Spacer()

                repsField(set).frame(width: mode.repsFieldWidth)

                if mode.showsLoad {
                    loadField(set, previousSet: previousSet, aboveSet: aboveSet)
                        .frame(width: Col.load)
                        .padding(.leading, 8)
                }

                if mode.showsCheckbox {
                    let nextSet: EditableSet? = {
                        guard let idx = editableSets.firstIndex(where: { $0.id == s.id }),
                              editableSets.indices.contains(idx + 1) else { return nil }
                        return editableSets[idx + 1]
                    }()
                    checkboxButton(set, nextSet: nextSet)
                        .frame(width: Col.checkbox, alignment: .center)
                        .padding(.leading, 8)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            // Two-layer background: opaque base prevents the red delete button
            // from showing through the semi-transparent green checked overlay.
            // Color.brandSecondary is opaque; Color(.systemFill) must NOT be used
            // here because it is semi-transparent (~20% alpha).
            .background {
                ZStack {
                    Color.brandSecondary
                    if s.isChecked { Color.green.opacity(0.25) }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: s.isChecked)
            .offset(x: swipeOffsets[s.id] ?? 0)
        }
        .clipped()
        // Offset matches the content HStack so the handle slides with the row during swipe-to-delete.
        .overlay { dragHandle(s).offset(x: swipeOffsets[s.id] ?? 0) }
        .shadow(color: .black.opacity(reorderDraggingId == s.id ? 0.18 : 0), radius: 6, y: 3)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    let dx = value.translation.width
                    let dy = value.translation.height
                    let cur = swipeOffsets[s.id] ?? 0
                    guard abs(dx) > abs(dy) * 1.5 || cur < 0 else { return }
                    guard dx < 0 || cur < 0 else { return }
                    if dragBases[s.id] == nil { dragBases[s.id] = cur }
                    swipeOffsets[s.id] = min(max((dragBases[s.id] ?? cur) + dx, -deleteRevealWidth), 0)
                }
                .onEnded { _ in
                    let cur = swipeOffsets[s.id] ?? 0
                    dragBases.removeValue(forKey: s.id)
                    withAnimation(.snappy(duration: 0.25)) {
                        swipeOffsets[s.id] = cur < -deleteRevealWidth / 2 ? -deleteRevealWidth : nil
                    }
                }
        )
    }

    // MARK: - Reps field

    private func repsField(_ set: Binding<EditableSet>) -> some View {
        let idx = editableSets.firstIndex(where: { $0.id == set.wrappedValue.id }) ?? 0
        let placeholder: String = {
            if case .editTemplate = mode { return idx == 0 ? "e.g. 8-12" : "–" }
            guard case .activeWorkout = mode else { return "–" }
            if idx > 0 {
                let above = editableSets[idx - 1]
                if above.type == set.wrappedValue.type, !above.reps.isEmpty {
                    return above.reps
                }
            }
            if idx < templateSets.count, let reps = templateSets[idx].reps, !reps.isEmpty {
                return reps
            }
            let prev = previousSetFor(set.wrappedValue)
            return prev.map { $0.reps > 0 ? String($0.reps) : "–" } ?? "–"
        }()
        let keyboardType: UIKeyboardType = {
            if case .editTemplate = mode { return .numbersAndPunctuation }
            return mode.showsLoad ? .numberPad : .default
        }()
        return TextField(placeholder, text: set.reps)
            .keyboardType(keyboardType)
            .font(.system(size: 17, weight: .semibold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .background {
                ZStack {
                    if set.wrappedValue.isChecked { Color.brandSecondary } else { Color.brandSecondaryLight }
                    if set.wrappedValue.isChecked { Color.green.opacity(0.25) }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            .focused($focusedField, equals: .reps(set.wrappedValue.id))
            .selectAllTextOnFocus()
            .onChange(of: set.wrappedValue.reps) { _, new in
                syncToBinding()
                if !new.isEmpty, missingRepsSetId == set.wrappedValue.id { missingRepsSetId = nil }
            }
            .popover(isPresented: Binding(
                get: { missingRepsSetId == set.wrappedValue.id },
                set: { if !$0 { missingRepsSetId = nil } }
            )) {
                Text(missingRepsNeedsLoad
                     ? "Don't forget to enter your reps and weight!"
                     : "Don't forget to enter your reps!")
                    .font(.callout)
                    .padding()
                    .presentationCompactAdaptation(.popover)
            }
    }

    // MARK: - Load field

    private func loadStringBinding(for setId: UUID) -> Binding<String> {
        Binding(
            get: { loadStrings[setId] ?? "" },
            set: { newText in
                if let dotIdx = newText.firstIndex(of: ".") {
                    let afterDot = newText[newText.index(after: dotIdx)...]
                    if afterDot.count > 1 { return }
                }
                loadStrings[setId] = newText
                let lbValue: Double?
                if newText.isEmpty || newText == "." {
                    lbValue = nil
                } else {
                    lbValue = Double(newText).map { weightUnit.toLb($0) }
                }
                if let idx = editableSets.firstIndex(where: { $0.id == setId }) {
                    editableSets[idx].load = lbValue
                    syncToBinding()
                }
            }
        )
    }

    private func loadField(_ set: Binding<EditableSet>, previousSet: LogSet? = nil, aboveSet: EditableSet? = nil) -> some View {
        let setId = set.wrappedValue.id
        let placeholder: String = {
            if let above = aboveSet, above.type == set.wrappedValue.type, let load = above.load {
                return displayLoadString(load)
            }
            guard let load = previousSet?.load else { return "–" }
            return displayLoadString(load)
        }()
        return TextField(placeholder, text: loadStringBinding(for: setId))
            .keyboardType(.decimalPad)
            .font(.system(size: 17, weight: .semibold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .background {
                ZStack {
                    if set.wrappedValue.isChecked { Color.brandSecondary } else { Color.brandSecondaryLight }
                    if set.wrappedValue.isChecked { Color.green.opacity(0.25) }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            .focused($focusedField, equals: .load(setId))
            .selectAllTextOnFocus()
    }

    // MARK: - Checkbox

    private func checkboxButton(_ set: Binding<EditableSet>, nextSet: EditableSet?) -> some View {
        Button {
            let wasChecked = set.wrappedValue.isChecked
            let setId     = set.wrappedValue.id
            withAnimation { set.wrappedValue.isChecked = !wasChecked }
            if !wasChecked {
                fillPlaceholders(for: set)
                updateLoadString(for: set.wrappedValue.id)
                if set.wrappedValue.reps.isEmpty {
                    missingRepsSetId = setId
                    missingRepsNeedsLoad = set.wrappedValue.load == nil
                }
            }
            syncToBinding()
            if wasChecked {
                if missingRepsSetId == setId { missingRepsSetId = nil }
                restTimer.cancel()
            } else if editableSets.last?.id == setId {
                // Last set: no rest needed, cancel any timer left over from previous sets
                restTimer.cancel()
            } else {
                // If the next set is a pre-rest type (dropset/myoreps), the pill above it
                // belongs to that set's rest_time, not this set's post-rest.
                let effectiveRest: Int
                if let next = nextSet, next.setType.isPreRest {
                    effectiveRest = next.rest_time ?? 0
                } else {
                    effectiveRest = set.wrappedValue.rest_time ?? 0
                }
                if effectiveRest > 0 {
                    restTimer.start(seconds: effectiveRest, setId: setId)
                } else {
                    restTimer.cancel()
                }
            }
        } label: {
            Image(systemName: set.wrappedValue.isChecked
                  ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(set.wrappedValue.isChecked ? Color.green : Color.secondary)
                .font(.title3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Rest time pill

    private func restTimePill(above: Binding<EditableSet>, below: Binding<EditableSet>) -> some View {
        let aboveSet = above.wrappedValue
        let belowSet = below.wrappedValue
        // Pre-rest types (dropset, myoreps) own the pill above them — their rest_time is
        // the time to wait before starting that set, not after the set above.
        let targetSet = belowSet.setType.isPreRest ? below : above
        // Timer is always keyed to the above set's id (the one that was checked to start it).
        let setId = aboveSet.id
        let isActive = restTimer.isRunning && restTimer.activeSetId == setId
        let displaySeconds = targetSet.wrappedValue.rest_time ?? 0
        let displayText = isActive
            ? restTimer.formattedTimeRemaining
            : restTimer.formattedTime(displaySeconds)

        return HStack {
            Spacer()
            Button {
                let currentSeconds = targetSet.wrappedValue.rest_time ?? 0
                pickerMinutes = currentSeconds / 60
                pickerSeconds = (currentSeconds % 60 / 10) * 10
                pickerTargetSetId = setId
                showRestTimePicker = true
            } label: {
                Text(displayText)
                    .font(.system(size: 17, weight: isActive ? .heavy : .semibold).monospacedDigit())
                    .foregroundStyle(isActive ? Color.red : Color.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .background(Capsule().fill(Color.brandBackground))
            .popover(isPresented: Binding(
                get: { showRestTimePicker && pickerTargetSetId == setId },
                set: { if !$0 { showRestTimePicker = false } }
            )) {
                restTimePickerContent(targetSet)
            }
            Spacer()
        }
    }

    private func restTimePickerContent(_ set: Binding<EditableSet>) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                Picker("Minutes", selection: $pickerMinutes) {
                    ForEach(0...10, id: \.self) { Text("\($0)m") }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                .clipped()

                Picker("Seconds", selection: $pickerSeconds) {
                    ForEach([0, 10, 20, 30, 40, 50], id: \.self) { Text("\($0)s") }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                .clipped()
            }

            Button("Set") {
                let total = pickerMinutes * 60 + pickerSeconds
                if let idx = editableSets.firstIndex(where: { $0.id == set.wrappedValue.id }) {
                    editableSets[idx].rest_time = total > 0 ? total : nil
                    syncToBinding()
                }
                showRestTimePicker = false
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .presentationCompactAdaptation(.popover)
    }

    // MARK: - Drag handle

    private func dragHandle(_ set: EditableSet) -> some View {
        Image(systemName: "line.3.horizontal")
            .foregroundStyle(.tertiary)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 5, coordinateSpace: .global)
                    .onChanged { value in
                        if reorderDraggingId != set.id {
                            reorderDraggingId   = set.id
                            reorderStartIndex   = editableSets.firstIndex(where: { $0.id == set.id }) ?? 0
                            reorderCurrentIndex = reorderStartIndex
                        }
                        performReorder(yOffset: value.translation.height)
                    }
                    .onEnded { _ in
                        reorderDraggingId = nil
                        syncToBinding()
                    }
            )
    }

    private func performReorder(yOffset: CGFloat) {
        let steps = Int((yOffset / reorderSlotHeight).rounded())
        let target = max(0, min(editableSets.count - 1, reorderStartIndex + steps))
        guard target != reorderCurrentIndex else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            editableSets.move(
                fromOffsets: IndexSet(integer: reorderCurrentIndex),
                toOffset: target > reorderCurrentIndex ? target + 1 : target
            )
        }
        reorderCurrentIndex = target
    }

    // MARK: - Add set button

    private var addSetButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    let newSet = EditableSet.defaultWorkingSet(copyingFrom: editableSets.last)
                    if editableSets.count >= 2 {
                        editableSets[editableSets.count - 1].rest_time =
                            editableSets[editableSets.count - 2].rest_time
                    }
                    editableSets.append(newSet)
                    loadStrings[newSet.id] = displayLoadString(newSet.load)
                    syncToBinding()
                }
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.accentColor))
            }
            .buttonStyle(.plain)
            Spacer()
        }
        // No top padding here — the VStack applies .padding(.top, -pillHalfHeight)
        // externally so the capsule visually overlaps the last content row above.
        .padding(.bottom, 12)
    }

    // MARK: - Previous data

    // Greedy left-to-right type-match: each current set claims the first unclaimed historical
    // set of the same type. Mirrors the load-matching logic in EditableMovementEntry.init(from:)
    // so the Previous column is consistent with the prepopulated loads.
    private var previousSetMap: [UUID: LogSet] {
        guard case .activeWorkout(let previousSets) = mode,
              let previousSets else { return [:] }
        var claimedIndices = Set<Int>()
        var map: [UUID: LogSet] = [:]
        for set in editableSets {
            guard let idx = previousSets.indices.first(where: {
                !claimedIndices.contains($0) && previousSets[$0].type == set.type
            }) else { continue }
            claimedIndices.insert(idx)
            map[set.id] = previousSets[idx]
        }
        return map
    }

    private func previousSetFor(_ set: EditableSet) -> LogSet? {
        previousSetMap[set.id]
    }

    private func fillPlaceholders(for set: Binding<EditableSet>) {
        guard case .activeWorkout = mode else { return }
        let s = set.wrappedValue
        let idx = editableSets.firstIndex(where: { $0.id == s.id }) ?? 0

        let aboveSet: EditableSet? = idx > 0 ? editableSets[idx - 1] : nil

        if s.reps.isEmpty {
            let placeholder: String = {
                if let above = aboveSet, above.type == s.type, !above.reps.isEmpty {
                    return above.reps
                }
                if idx < templateSets.count, let reps = templateSets[idx].reps, !reps.isEmpty {
                    return reps
                }
                let prev = previousSetFor(s)
                return prev.map { $0.reps > 0 ? String($0.reps) : "–" } ?? "–"
            }()
            if placeholder != "–" && !placeholder.contains("-") {
                set.wrappedValue.reps = placeholder
            }
        }

        if s.load == nil {
            if let above = aboveSet, above.type == s.type, let load = above.load {
                set.wrappedValue.load = load
            } else {
                set.wrappedValue.load = previousSetFor(s)?.load
            }
        }
    }

    private func previousText(_ logSet: LogSet?) -> String {
        guard let s = logSet else { return "–" }
        if let load = s.load {
            return "\(s.reps) × \(displayLoadString(load)) \(weightUnit.unitLabel)"
        }
        return "\(s.reps)"
    }

    // MARK: - Binding sync

    private func loadFromBinding() {
        let incoming: [EditableSet]
        if case .editTemplate = mode {
            incoming = templateSets.map { EditableSet(from: $0) }
        } else {
            incoming = logSets.map { EditableSet(from: $0) }
        }
        if !sameShape(incoming, editableSets) {
            editableSets = incoming
            loadStrings = [:]
        }
        for set in editableSets where loadStrings[set.id] == nil {
            loadStrings[set.id] = displayLoadString(set.load)
        }
    }

    private func syncToBinding() {
        if case .editTemplate = mode {
            templateSets = editableSets.map { $0.asTemplateSet }
        } else {
            logSets = editableSets.map { $0.asLogSet }
        }
    }

    private func sameShape(_ a: [EditableSet], _ b: [EditableSet]) -> Bool {
        guard a.count == b.count else { return false }
        return zip(a, b).allSatisfy {
            $0.type == $1.type && $0.reps == $1.reps && $0.rest_time == $1.rest_time
        }
    }
}


// MARK: - Select-all-on-focus modifier

private extension View {
    func selectAllTextOnFocus() -> some View {
        onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { _ in
            DispatchQueue.main.async {
                UIApplication.shared.sendAction(#selector(UITextField.selectAll(_:)), to: nil, from: nil, for: nil)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Active Workout – with previous") {
    @Previewable @State var sets: [LogSet] = [
        LogSet(reps: 8,  load: 135, type: "warmup",  rest_time: 60),
        LogSet(reps: 10, load: 155, type: "working", rest_time: 120),
        LogSet(reps: 10, load: 155, type: "working", rest_time: 120),
        LogSet(reps: 8,  load: 155, type: "failure", rest_time: nil),
    ]
    let previous: [LogSet] = [
        LogSet(reps: 8,  load: 130, type: "warmup",  rest_time: nil),
        LogSet(reps: 10, load: 150, type: "working", rest_time: nil),
        LogSet(reps: 9,  load: 150, type: "working", rest_time: nil),
    ]
    NavigationStack {
        SetLogInputView(
            mode: .activeWorkout(previousSets: previous),
            logSets: $sets
        )
        .navigationTitle("Bench Press")
        .navigationBarTitleDisplayMode(.inline)
    }
    .environment(RestTimerEnvironment())
}

#Preview("Active Workout – no previous") {
    @Previewable @State var sets: [LogSet] = [
        LogSet(reps: 0, load: nil, type: "warmup",  rest_time: 60),
        LogSet(reps: 0, load: nil, type: "working", rest_time: 120),
        LogSet(reps: 0, load: nil, type: "working", rest_time: 120),
    ]
    NavigationStack {
        SetLogInputView(
            mode: .activeWorkout(previousSets: nil),
            logSets: $sets
        )
        .navigationTitle("Squat")
        .navigationBarTitleDisplayMode(.inline)
    }
    .environment(RestTimerEnvironment())
}

#Preview("Edit Log") {
    @Previewable @State var sets: [LogSet] = [
        LogSet(reps: 8,  load: 135, type: "warmup",  rest_time: 60),
        LogSet(reps: 10, load: 155, type: "working", rest_time: 120),
        LogSet(reps: 10, load: 155, type: "working", rest_time: 120),
        LogSet(reps: 8,  load: 155, type: "failure", rest_time: nil),
    ]
    NavigationStack {
        SetLogInputView(
            mode: .editLog,
            logSets: $sets
        )
        .navigationTitle("Deadlift – Jan 5")
        .navigationBarTitleDisplayMode(.inline)
    }
    .environment(RestTimerEnvironment())
}

#Preview("Edit Template") {
    @Previewable @State var sets: [TemplateSet] = [
        TemplateSet(reps: "5",    type: "warmup",  rest_time: 60),
        TemplateSet(reps: "8-10", type: "working", rest_time: 120),
        TemplateSet(reps: "8-10", type: "working", rest_time: 120),
        TemplateSet(reps: "8-10", type: "failure", rest_time: nil),
    ]
    NavigationStack {
        SetLogInputView(
            mode: .editTemplate,
            templateSets: $sets
        )
        .navigationTitle("Bench Press Template")
        .navigationBarTitleDisplayMode(.inline)
    }
    .environment(RestTimerEnvironment())
}

#Preview("Empty – Active Workout") {
    @Previewable @State var sets: [LogSet] = []
    NavigationStack {
        SetLogInputView(
            mode: .activeWorkout(previousSets: nil),
            logSets: $sets
        )
        .navigationTitle("New Movement")
        .navigationBarTitleDisplayMode(.inline)
    }
    .environment(RestTimerEnvironment())
}
#endif
