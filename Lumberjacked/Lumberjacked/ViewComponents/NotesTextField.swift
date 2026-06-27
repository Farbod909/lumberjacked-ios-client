//
//  NotesTextField.swift
//  Lumberjacked
//

import SwiftUI

struct NotesTextField: View {
    enum Style {
        case standard
        case accent
    }

    @Binding var text: String
    let prompt: String
    var style: Style = .standard

    private var backgroundColor: Color {
        style == .accent ? Color.accentColor.opacity(0.12) : Color.brandSecondary
    }

    private var promptColor: Color {
        style == .accent ? Color.accentColor.opacity(0.5) : Color.brandPlaceholderText
    }

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(prompt).foregroundStyle(promptColor),
            axis: .vertical
        )
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(.primary)
        .tint(style == .accent ? .accentColor : .primary)
        .lineLimit(1...5)
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .padding(.horizontal, 10)
        .padding(.bottom, 4)
    }
}
