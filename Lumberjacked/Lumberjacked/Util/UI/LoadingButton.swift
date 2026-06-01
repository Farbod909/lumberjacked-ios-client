//
//  LoadingButton.swift
//  Lumberjacked
//

import SwiftUI

struct LoadingButton: View {
    let label: String
    let isLoading: Bool
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            ZStack {
                Text(label).opacity(isLoading ? 0 : 1)
                if isLoading { ProgressView() }
            }
        }
        .disabled(isLoading)
    }
}
