//
//  InlineMovementTemplateView.swift
//  Lumberjacked
//

import SwiftUI

struct InlineMovementTemplateView: View {
    let movement: Movement
    @Binding var templateSets: [TemplateSet]
    var onReorderTapped: (() -> Void)? = nil
    var onReplaceTapped: (() -> Void)? = nil
    var onRemoveTapped: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack(alignment: .center) {
                Text(movement.name)
                    .font(DesignSystem.Font.cardTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Menu {
                    if let reorder = onReorderTapped {
                        Button("Reorder", systemImage: "line.3.horizontal") {
                            reorder()
                        }
                    }

                    if let replace = onReplaceTapped {
                        Button("Replace", systemImage: "arrow.left.arrow.right") {
                            replace()
                        }
                    }

                    if let remove = onRemoveTapped {
                        Button("Remove", systemImage: "minus.circle", role: .destructive) {
                            remove()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            SetLogInputView(mode: .editTemplate, templateSets: $templateSets, isEmbedded: true)
        }
    }
}
