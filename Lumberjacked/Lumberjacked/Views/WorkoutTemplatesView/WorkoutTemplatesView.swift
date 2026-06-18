//
//  WorkoutTemplatesView.swift
//  Lumberjacked
//

import SwiftUI

struct WorkoutTemplatesView: View {
    @State var viewModel: ViewModel

    @State private var selectedTemplate: WorkoutTemplate? = nil
    @State private var showActionMenu = false
    @State private var editingTemplate: WorkoutTemplate? = nil
    @State private var showCreateSheet = false
    @State private var showReorderSheet = false
    @State private var showDeleteAlert = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            if viewModel.isLoading(.templates) {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.orderedTemplates, id: \.id) { template in
                        WorkoutTemplateCard(template: template) {
                            selectedTemplate = template
                            showActionMenu = true
                        }
                    }
                    WorkoutTemplateCard(template: WorkoutTemplate(name: ""), isAddCard: true) {
                        showCreateSheet = true
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .confirmationDialog(
            selectedTemplate?.name ?? "",
            isPresented: $showActionMenu,
            titleVisibility: .visible
        ) {
            if let template = selectedTemplate {
                Button("Start Workout") {
                    Task { await viewModel.startWorkout(from: template) }
                }
                Button("Edit") {
                    editingTemplate = template
                }
                Button("Reorder Templates") {
                    showReorderSheet = true
                }
                Button("Delete", role: .destructive) {
                    showDeleteAlert = true
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .alert(
            "Delete \"\(selectedTemplate?.name ?? "")\"?",
            isPresented: $showDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                if let template = selectedTemplate {
                    Task { await viewModel.deleteTemplate(template) }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This cannot be undone.")
        }
        .sheet(
            isPresented: Binding(
                get: { editingTemplate != nil },
                set: { if !$0 { editingTemplate = nil } }
            )
        ) {
            if let template = editingTemplate {
                WorkoutTemplateEditorView(
                    viewModel: WorkoutTemplateEditorView.ViewModel(template: template),
                    onSave: { saved in viewModel.templateSaved(saved) }
                )
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            WorkoutTemplateEditorView(
                viewModel: WorkoutTemplateEditorView.ViewModel(template: nil),
                onSave: { saved in viewModel.templateSaved(saved) }
            )
        }
        .sheet(isPresented: $showReorderSheet) {
            TemplateReorderView(
                templates: viewModel.orderedTemplates,
                onSave: { ids in viewModel.saveOrder(ids) }
            )
        }
        .alert(item: $viewModel.alert)
        .task {
            await viewModel.attemptGetTemplates()
        }
    }
}

#if DEBUG
#Preview {
    WorkoutTemplatesView(
        viewModel: WorkoutTemplatesView.ViewModel(
            templateAPI: MockWorkoutTemplateAPI(),
            workoutAPI: MockWorkoutAPI()
        )
    )
    .environment(RestTimerEnvironment())
}
#endif
