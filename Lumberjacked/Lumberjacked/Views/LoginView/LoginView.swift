//
//  LoginView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    init(viewModel: ViewModel = ViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $viewModel.email)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                    .formFieldError($viewModel.errors, "email")
                    .accessibilityIdentifier("loginEmailField")
                SecureField("Password", text: $viewModel.password)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                    .formFieldError($viewModel.errors, "password")
                    .accessibilityIdentifier("loginPasswordField")

                FormErrors(errors: $viewModel.errors)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            guard await viewModel.attemptLogin() else {
                                return
                            }
                            dismiss()
                        }
                    } label: {
                        if viewModel.isLoading(.action) {
                            ProgressView()
                        } else {
                            Text("Log in")
                        }
                    }
                    .accessibilityIdentifier("loginButton")
                }
            }
        }
    }
}

#Preview {
    LoginView(viewModel: LoginView.ViewModel(api: MockAuthAPI()))
}
