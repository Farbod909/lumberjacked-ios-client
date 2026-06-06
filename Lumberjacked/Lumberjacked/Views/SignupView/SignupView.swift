//
//  SignupView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct SignupView: View {
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
                    .fieldError(viewModel.fieldErrors["email"])
                SecureField("Password", text: $viewModel.password1)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                    .fieldError(viewModel.fieldErrors["password1"])
                SecureField("Confirm password", text: $viewModel.password2)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                    .fieldError(viewModel.fieldErrors["password2"])
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            guard await viewModel.attemptSignup() else {
                                return
                            }
                            dismiss()
                        }
                    } label: {
                        if viewModel.isLoading(.action) {
                            ProgressView()
                        } else {
                            Text("Sign up")
                        }
                    }
                }
            }
            .alert(item: $viewModel.alert)
        }
    }
}

#Preview {
    SignupView(viewModel: SignupView.ViewModel(api: MockAuthAPI()))
}
