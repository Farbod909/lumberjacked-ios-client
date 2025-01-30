//
//  FormFieldError.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/29/25.
//

import SwiftUI

extension View {
    func formFieldError(_ errors: Binding<LumberjackedClientErrors>, _ key: String) -> some View {
        return modifier(FormFieldError(errors: errors, key: key))
    }
}

struct FormFieldError: ViewModifier {
    @Binding var errors: LumberjackedClientErrors
    var key: String
    
    func body(content: Content) -> some View {
        Group {
            content
            if errors.hasError(key: key) {
                Label(errors.errorMessage(key: key), systemImage: "x.circle.fill")
                    .labelStyle(CustomLabelSpacing(spacing: 4))
                    .foregroundStyle(.red)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                    .font(.caption)
                    .padding(.bottom)
            }
        }
    }
}
