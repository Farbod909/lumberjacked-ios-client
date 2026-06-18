//
//  WorkoutTemplateCard.swift
//  Lumberjacked
//

import SwiftUI

struct WorkoutTemplateCard: View {
    var template: WorkoutTemplate = WorkoutTemplate(name: "")
    var isAddCard: Bool = false

    var body: some View {
        if isAddCard {
            addCardContent
        } else {
            templateCardContent
        }
    }

    private var templateCardContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(template.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            let movements = template.movements_details ?? []
            if movements.isEmpty {
                Text("No movements")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(movements, id: \.id) { m in
                        Text(m.movement_detail?.name ?? "–")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var addCardContent: some View {
        VStack(spacing: 6) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("New Template")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
        )
    }
}

#if DEBUG
#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        WorkoutTemplateCard(template: PreviewData.workoutTemplate_pushDay)
        WorkoutTemplateCard(template: PreviewData.workoutTemplate_legDay)
        WorkoutTemplateCard(isAddCard: true)
    }
    .padding()
}
#endif
