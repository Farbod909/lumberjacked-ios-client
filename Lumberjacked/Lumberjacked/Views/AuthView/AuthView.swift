//
//  AuthView.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

struct AuthView: View {
    @State var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            if viewModel.showSignup {
                SignupView()
                Button("Already have an account? Log in") {
                    viewModel.showSignup = false
                }
            } else {
                LoginView()
                Button("No account? Sign up") {
                    viewModel.showSignup = true
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    AuthView()
}
