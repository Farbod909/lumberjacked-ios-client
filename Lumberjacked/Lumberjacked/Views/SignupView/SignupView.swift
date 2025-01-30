//
//  SignupView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct SignupView: View {
    @State var viewModel = ViewModel()
    @State var errors = LumberjackedClientErrors()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $viewModel.email)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                    .formFieldError($errors, "email")
                SecureField("Password", text: $viewModel.password1)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                    .formFieldError($errors, "password1")
                SecureField("Confirm password", text: $viewModel.password2)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                    .formFieldError($errors, "password2")

                FormErrors(errors: $errors)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            guard await viewModel.attemptSignup(errors: $errors) else {
                                return
                            }
                            dismiss()
                        }
                    } label: {
                        if viewModel.isLoadingToolbarAction {
                            ProgressView()
                        } else {
                            Text("Sign up")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SignupView()
}
