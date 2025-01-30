//
//  FormErrors.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/29/25.
//

import SwiftUI

struct FormErrors: View {
    @Binding var errors: LumberjackedClientErrors
    
    var body: some View {
        if errors.hasError(key: "detail") {
            Label(errors.errorMessage(key: "detail"), systemImage: "x.circle.fill")
                .labelStyle(CustomLabelSpacing(spacing: 4))
                .foregroundStyle(.red)
                .listRowBackground(Color.init(uiColor: .systemGray6))
                .font(.caption)
                .padding(.bottom)
        }
        if errors.hasError(key: "non_field_errors") {
            Label(errors.errorMessage(key: "non_field_errors"), systemImage: "x.circle.fill")
                .labelStyle(CustomLabelSpacing(spacing: 4))
                .foregroundStyle(.red)
                .listRowBackground(Color.init(uiColor: .systemGray6))
                .font(.caption)
                .padding(.bottom)
        }
    }
}
