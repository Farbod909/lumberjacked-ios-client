//
//  WorkoutTemplateEditorView.swift
//

import SwiftUI

private struct FloatingButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }
}

struct WorkoutTemplateEditorView: View {
    @State var viewModel: ViewModel
    let onSave: (WorkoutTemplate) -> Void
    @Environment(\.dismiss) var dismiss
    @FocusState private var searchFieldFocused: Bool
    @State private var restTimerEnvironment = RestTimerEnvironment()

    @State private var isReordering = false
    @State private var reorderDraggingIndex: Int? = nil
    @State private var reorderDragStartIndex: Int = 0
    private let reorderRowHeight: CGFloat = 52

    @State private var replacingMovementId: UInt64? = nil

    func dismissAddMovementOverlay() {
        searchFieldFocused = false
        viewModel.showAddMovementOverlay = false
        viewModel.searchText = ""
        replacingMovementId = nil
    }

    // MARK: - Name field

    var nameField: some View {
        TextField("Template name", text: $viewModel.name)
            .autocorrectionDisabled()
            .font(DesignSystem.Font.cardTitle)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .brandCard()
            .padding(.horizontal, 16)
            .padding(.top, 16)
    }

    // MARK: - Compact reorder row

    private func compactReorderRow(_ entry: EditableTemplateMovementEntry, index: Int) -> some View {
        HStack(spacing: 12) {
            Text(entry.movement.name)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .brandCard()
        .shadow(
            color: .black.opacity(reorderDraggingIndex == index ? 0.18 : 0),
            radius: 6, y: 3
        )
        .gesture(
            DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged { value in
                    if reorderDraggingIndex == nil {
                        reorderDraggingIndex = index
                        reorderDragStartIndex = index
                    }
                    performMovementReorder(offset: value.translation.height)
                }
                .onEnded { _ in
                    reorderDraggingIndex = nil
                }
        )
    }

    private func performMovementReorder(offset: CGFloat) {
        guard let curIdx = reorderDraggingIndex else { return }
        let steps = Int((offset / reorderRowHeight).rounded())
        let targetIdx = max(0, min(viewModel.entries.count - 1, reorderDragStartIndex + steps))
        guard targetIdx != curIdx else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            viewModel.entries.move(
                fromOffsets: IndexSet(integer: curIdx),
                toOffset: targetIdx > curIdx ? targetIdx + 1 : targetIdx
            )
        }
        reorderDraggingIndex = targetIdx
    }

    // MARK: - Add movement button

    var addMovementButton: some View {
        Button {
            Task {
                viewModel.searchText = ""
                viewModel.showAddMovementOverlay = true
                await viewModel.attemptGetMovements()
            }
        } label: {
            Label("Add Movement", systemImage: "plus")
                .font(.headline)
        }
        .padding()
        .modifier(FloatingButtonStyle())
        .foregroundStyle(Color.brandPrimaryText)
    }

    // MARK: - Add movement overlay

    var addMovementSearchFieldView: some View {
        HStack {
            TextField(
                "",
                text: $viewModel.searchText,
                prompt: Text(replacingMovementId != nil ? "Replace with..." : "Enter movement name...")
                    .foregroundStyle(.brandPrimaryText.opacity(0.6))
            )
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .keyboardType(.alphabet)
            .focused($searchFieldFocused)
            .foregroundStyle(Color.brandPrimaryText)
            .frame(height: 44)
            .padding(.horizontal, 16)

            if viewModel.isLoading(.movements) {
                ProgressView()
            }
            Button {
                viewModel.searchText = ""
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.brandPrimaryText.opacity(0.6))
                    .padding()
            }
            .opacity(viewModel.searchText.isEmpty ? 0 : 1)
        }
        .brandCard(cornerRadius: DesignSystem.CornerRadius.small)
        .padding(.horizontal, 16)
    }

    var addMovementSearchResults: [Movement] {
        viewModel.searchText.isEmpty ? [] : viewModel.allMovements.filter {
            $0.name.lowercased().contains(viewModel.searchText.lowercased())
        }
    }

    var addMovementOverlay: some View {
        VStack {
            addMovementSearchFieldView
            if viewModel.searchText.isEmpty {
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                if value.translation.height > 0 {
                                    dismissAddMovementOverlay()
                                }
                            }
                    )
            } else {
                let currentIds = Set(viewModel.entries.compactMap { $0.movement.id })
                List {
                    Section {
                        ForEach(addMovementSearchResults, id: \.self) { movement in
                            let alreadyAdded = currentIds.contains(movement.id ?? 0)
                            Button {
                                guard !alreadyAdded else { return }
                                if let replaceId = replacingMovementId {
                                    viewModel.replaceMovement(id: replaceId, with: movement)
                                } else {
                                    viewModel.addMovement(movement)
                                }
                                dismissAddMovementOverlay()
                            } label: {
                                HStack {
                                    Text(movement.name)
                                    Spacer()
                                    if alreadyAdded {
                                        Text("Added").font(.caption2).textCase(.uppercase)
                                    }
                                }
                            }
                            .foregroundColor(alreadyAdded ? .secondary : .primary)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listSectionSpacing(.compact)
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                VStack {
                    ScrollView {
                        nameField

                        if isReordering {
                            VStack(spacing: 8) {
                                ForEach(
                                    Array(viewModel.entries.enumerated()),
                                    id: \.element.id
                                ) { index, entry in
                                    compactReorderRow(entry, index: index)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        } else {
                            ForEach($viewModel.entries) { $entry in
                                InlineMovementTemplateView(
                                    movement: entry.movement,
                                    templateSets: $entry.templateSets,
                                    onReorderTapped: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isReordering = true
                                        }
                                    },
                                    onReplaceTapped: {
                                        replacingMovementId = entry.movement.id
                                        viewModel.showAddMovementOverlay = true
                                    },
                                    onRemoveTapped: {
                                        if let id = entry.movement.id {
                                            viewModel.removeMovement(id: id)
                                        }
                                    }
                                )
                            }
                        }

                        Spacer().frame(height: 80)
                    }
                    .scrollIndicators(.hidden)
                }

                if !viewModel.showAddMovementOverlay && !isReordering {
                    VStack {
                        Spacer()
                        HStack {
                            addMovementButton
                                .padding(.leading, 25)
                                .padding(.bottom, 20)
                            Spacer()
                        }
                    }
                }

                if viewModel.showAddMovementOverlay {
                    addMovementOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .background(
                            .ultraThinMaterial.opacity(viewModel.showAddMovementOverlay ? 1 : 0)
                        )
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Edit Template" : "New Template")
            .navigationBarTitleDisplayMode(.inline)
            .animation(
                .spring(duration: 0.3, bounce: 0.05),
                value: viewModel.showAddMovementOverlay
            )
            .onChange(of: viewModel.showAddMovementOverlay) { _, isShowing in
                if isShowing { searchFieldFocused = true }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !isReordering && !viewModel.showAddMovementOverlay {
                        Button("Cancel") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isReordering {
                        Button("Done") {
                            withAnimation(.easeInOut(duration: 0.2)) { isReordering = false }
                        }
                        .fontWeight(.semibold)
                    } else if viewModel.showAddMovementOverlay {
                        Button("Dismiss") { dismissAddMovementOverlay() }
                    } else if viewModel.isLoading(.action) {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                await viewModel.save { saved in
                                    onSave(saved)
                                    dismiss()
                                }
                            }
                        }
                        .disabled(!viewModel.canSave)
                        .fontWeight(.semibold)
                    }
                }
            }
            .alert(item: $viewModel.alert)
            .task { await viewModel.attemptGetMovements() }
        }
        .environment(restTimerEnvironment)
    }
}

#if DEBUG
#Preview("Create") {
    WorkoutTemplateEditorView(
        viewModel: WorkoutTemplateEditorView.ViewModel(
            template: nil,
            templateAPI: MockWorkoutTemplateAPI(),
            movementAPI: MockMovementAPI()
        ),
        onSave: { _ in }
    )
}

#Preview("Edit") {
    WorkoutTemplateEditorView(
        viewModel: WorkoutTemplateEditorView.ViewModel(
            template: PreviewData.workoutTemplate_pushDay,
            templateAPI: MockWorkoutTemplateAPI(),
            movementAPI: MockMovementAPI()
        ),
        onSave: { _ in }
    )
}
#endif
