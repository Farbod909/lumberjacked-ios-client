//
//  WorkoutTemplatesView.swift
//  Lumberjacked
//

import SwiftUI

struct WorkoutTemplatesView: View {
    @State var viewModel: ViewModel

    @State private var selectedTemplate: WorkoutTemplate? = nil
    @State private var editingTemplate: WorkoutTemplate? = nil
    @State private var showCreateSheet = false
    @State private var showReorderSheet = false
    @State private var showDeleteAlert = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var searchBarRow: some View {
        HStack(spacing: 8) {
            SearchBar(placeholder: "Search templates", text: $viewModel.searchText)

            Button {
                showCreateSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 14)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(height: 36)
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showSearchBar {
                searchBarRow
            }

            ScrollView {
                if viewModel.isLoading(.templates) {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if viewModel.filteredTemplates.isEmpty && !viewModel.searchText.isEmpty {
                    Text("No templates match \"\(viewModel.searchText)\"")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.filteredTemplates, id: \.self) { template in
                            Menu {
                                Button {
                                    Task { await viewModel.startWorkout(from: template) }
                                } label: {
                                    Label("Start Workout", systemImage: "play.fill")
                                }
                                Button {
                                    editingTemplate = template
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button {
                                    Task { await viewModel.duplicateTemplate(template) }
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                Button {
                                    showReorderSheet = true
                                } label: {
                                    Label("Reorder Templates", systemImage: "arrow.up.arrow.down")
                                }
                                Divider()
                                Button(role: .destructive) {
                                    selectedTemplate = template
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            } label: {
                                WorkoutTemplateCard(template: template)
                            }
                            .buttonStyle(.plain)
                        }

                        if !viewModel.showSearchBar {
                            Button { showCreateSheet = true } label: {
                                WorkoutTemplateCard(isAddCard: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, viewModel.showSearchBar ? 4 : 12)
                    .padding(.bottom, 12)
                }
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
