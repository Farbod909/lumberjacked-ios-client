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
}

// MARK: - Focus identifier

private enum FocusedField: Hashable {
    case restTime(UUID)
    case reps(UUID)
    case load(UUID)
}

// MARK: - Column widths

private enum Col {
    static let set:      CGFloat = 36
    static let previous: CGFloat = 80
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

    @State private var editingRestTimeId: UUID? = nil
    @State private var restTimeText: String = ""
    @FocusState private var focusedField: FocusedField?

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
        .onChange(of: focusedField) { oldValue, newValue in
            if case .restTime(let oldId) = oldValue {
                commitRestTimeEdit(for: oldId)
            }
            if case .restTime(let newId) = newValue,
               let set = editableSets.first(where: { $0.id == newId }) {
                restTimeText = restTimer.formattedTime(set.rest_time ?? 0)
            }
        }
    }

    // MARK: - Rows content (shared between standalone and embedded modes)

    private var emptyStateRow: some View {
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

    @ViewBuilder
    private var rowsContent: some View {
        VStack(spacing: 0) {
            if editableSets.isEmpty {
                emptyStateRow
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                    .padding(.horizontal, 10)
            }
            ForEach(Array(editableSets.enumerated()), id: \.element.id) { index, _ in
                if index > 0 && !readOnly {
                    // Rest time pill between row (index-1) and row (index).
                    // Negative vertical padding makes it reduce its layout footprint
                    // so it visually overlaps both neighbors. zIndex(10) ensures it
                    // paints on top of both adjacent content rows (which use zIndex(1)).
                    restTimePill($editableSets[index - 1])
                        .padding(.vertical, -pillHalfHeight)
                        .zIndex(10)
                }
                setRow($editableSets[index], index: index)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
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

            Text("Reps")
                .frame(width: Col.reps, alignment: .center)

            if mode.showsLoad {
                Text("lbs")
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
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(Color.secondary.opacity(0.35), lineWidth: 1)
                )
                .frame(width: Col.set, alignment: .leading)
            Spacer()
            Text(s.reps.isEmpty ? "–" : s.reps)
                .multilineTextAlignment(.center)
                .frame(width: Col.reps)
            if mode.showsLoad {
                Text(formatLoad(s.load))
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
        let rounded = (load * 10).rounded() / 10
        return rounded.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(rounded)) : String(format: "%.1f", rounded)
    }

    @ViewBuilder
    private func editableSetRow(_ set: Binding<EditableSet>, index: Int) -> some View {
        let s = set.wrappedValue
        let workingIdx = editableSets.workingSetIndex(for: s.id)
        let previousSet = previousSetFor(s)

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
                        Button(type.fullName) {
                            if let idx = editableSets.firstIndex(where: { $0.id == s.id }) {
                                editableSets[idx].setType = type
                                syncToBinding()
                            }
                        }
                    }
                } label: {
                    Text(s.displayLabel(workingSetIndex: workingIdx))
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                .stroke(Color.secondary.opacity(0.35), lineWidth: 1)
                        )
                }
                .frame(width: Col.set, alignment: .leading)

                if mode.showsPrevious {
                    Text(previousText(previousSet))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: Col.previous, alignment: .leading)
                        .padding(.leading, 12)
                        .lineLimit(1)
                }

                Spacer()

                repsField(set).frame(width: Col.reps)

                if mode.showsLoad {
                    loadField(set)
                        .frame(width: Col.load)
                        .padding(.leading, 8)
                }

                if mode.showsCheckbox {
                    checkboxButton(set)
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
        TextField("–", text: set.reps)
            .keyboardType(mode.showsLoad ? .numberPad : .default)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .background(Color.brandSecondaryLight)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            .focused($focusedField, equals: .reps(set.wrappedValue.id))
            .selectAllTextOnFocus()
            .onChange(of: set.wrappedValue.reps) { _, _ in syncToBinding() }
    }

    // MARK: - Load field

    private func loadField(_ set: Binding<EditableSet>) -> some View {
        TextField("–", value: set.load, format: .number)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .background(Color.brandSecondaryLight)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            .focused($focusedField, equals: .load(set.wrappedValue.id))
            .selectAllTextOnFocus()
            .onChange(of: set.wrappedValue.load) { _, _ in syncToBinding() }
    }

    // MARK: - Checkbox

    private func checkboxButton(_ set: Binding<EditableSet>) -> some View {
        Button {
            let wasChecked = set.wrappedValue.isChecked
            let restTime  = set.wrappedValue.rest_time
            let setId     = set.wrappedValue.id
            withAnimation { set.wrappedValue.isChecked = !wasChecked }
            syncToBinding()
            if wasChecked {
                restTimer.cancel()
            } else if let rt = restTime, rt > 0, editableSets.last?.id != setId {
                restTimer.start(seconds: rt, setId: setId)
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

    private func restTimePill(_ set: Binding<EditableSet>) -> some View {
        let s = set.wrappedValue
        let setId = s.id
        let isActive = restTimer.isRunning && restTimer.activeSetId == setId
        let displayText = isActive
            ? restTimer.formattedTimeRemaining
            : restTimer.formattedTime(s.rest_time ?? 0)

        return HStack {
            Spacer()
            ZStack {
                Capsule().fill(Color.brandBackground)

                if editingRestTimeId == setId {
                    TextField("m:ss", text: $restTimeText)
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .restTime(setId))
                        .onAppear { focusedField = .restTime(setId) }
                        .onSubmit { focusedField = nil }
                        .selectAllTextOnFocus()
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                } else {
                    Button { beginRestTimeEdit(s) } label: {
                        Text(displayText)
                            .font(.subheadline.monospacedDigit())
                            .fontWeight(isActive ? .bold : .regular)
                            .foregroundStyle(isActive ? Color.red : Color.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .fixedSize()
            Spacer()
        }
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
                    let newSet = EditableSet.defaultWorkingSet(copyingRestFrom: editableSets.last)
                    editableSets.append(newSet)
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

    // MARK: - Rest time edit helpers

    private func beginRestTimeEdit(_ set: EditableSet) {
        editingRestTimeId = set.id
    }

    private func commitRestTimeEdit(for id: UUID) {
        defer {
            restTimeText = ""
            if editingRestTimeId == id { editingRestTimeId = nil }
        }
        guard let parsed = parseRestTimeText(restTimeText),
              let idx = editableSets.firstIndex(where: { $0.id == id }) else { return }
        editableSets[idx].rest_time = parsed
        syncToBinding()
    }

    private func parseRestTimeText(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.contains(":") {
            let parts = trimmed.split(separator: ":")
            guard parts.count == 2,
                  let m = Int(parts[0]),
                  let s = Int(parts[1]) else { return nil }
            return m * 60 + s
        }
        return Int(trimmed)
    }

    // MARK: - Previous data

    private func previousSetFor(_ set: EditableSet) -> LogSet? {
        guard case .activeWorkout(let previousSets) = mode,
              let previousSets else { return nil }
        let idx = editableSets.firstIndex(where: { $0.id == set.id }) ?? 0
        guard idx < previousSets.count else { return nil }
        return previousSets[idx]
    }

    private func previousText(_ logSet: LogSet?) -> String {
        guard let s = logSet else { return "–" }
        if let load = s.load {
            let rounded = (load * 10).rounded() / 10
            let loadStr = rounded.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(rounded))
                : String(format: "%.1f", rounded)
            return "\(s.reps) × \(loadStr) lb"
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
