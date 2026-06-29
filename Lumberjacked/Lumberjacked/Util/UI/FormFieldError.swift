//
//  FieldErrorModifier.swift
//  Lumberjacked
//

import SwiftUI

struct FieldErrorModifier: ViewModifier {
    let message: String?

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            content
            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 16)
                    .padding(.bottom, 8)
            }
        }
    }
}

extension View {
    func fieldError(_ message: String?) -> some View {
        modifier(FieldErrorModifier(message: message))
    }
}
