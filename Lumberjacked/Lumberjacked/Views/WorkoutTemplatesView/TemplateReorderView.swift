//
//  TemplateReorderView.swift
//  Lumberjacked
//

import SwiftUI

struct TemplateReorderView: View {
    @State private var templates: [WorkoutTemplate]
    @State private var editMode = EditMode.active
    let onSave: ([UInt64]) -> Void
    @Environment(\.dismiss) var dismiss

    init(templates: [WorkoutTemplate], onSave: @escaping ([UInt64]) -> Void) {
        _templates = State(initialValue: templates)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(templates, id: \.self) { template in
                    Text(template.name)
                }
                .onMove { templates.move(fromOffsets: $0, toOffset: $1) }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Reorder Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave(templates.compactMap { $0.id })
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    TemplateReorderView(templates: PreviewData.workoutTemplates) { _ in }
}
#endif
