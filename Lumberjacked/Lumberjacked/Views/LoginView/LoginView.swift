//
//  LoginView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $viewModel.email)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
                SecureField("Password", text: $viewModel.password)
                    .listRowBackground(Color.init(uiColor: .systemGray6))
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
                        if viewModel.isLoadingToolbarAction {
                            ProgressView()
                        } else {
                            Text("Log in")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
