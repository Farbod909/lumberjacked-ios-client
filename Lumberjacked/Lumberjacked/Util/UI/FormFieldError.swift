//
//  FieldErrorModifier.swift
//  Lumberjacked
//

import SwiftUI

struct FieldErrorModifier: ViewModifier {
    let message: String?

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(message != nil ? Color.red : Color.clear, lineWidth: 1)
                )
            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

extension View {
    func fieldError(_ message: String?) -> some View {
        modifier(FieldErrorModifier(message: message))
    }
}
