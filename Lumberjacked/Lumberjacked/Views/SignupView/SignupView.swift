//
//  SignupView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct SignupView: View {
    @State var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $viewModel.email)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                SecureField("Password", text: $viewModel.password1)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                SecureField("Confirm password", text: $viewModel.password2)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
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
