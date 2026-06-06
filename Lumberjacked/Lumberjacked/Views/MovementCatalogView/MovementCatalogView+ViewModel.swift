//
//  MovementCatalogView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension MovementCatalogView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case load }
        var loadingKeys: Set<LoadingKey> = [.load]

        var movements = [Movement]()
        var searchText = ""
        var showCreateMovementSheet = false
        var alert: AppAlert?

        private let api: MovementAPIProtocol

        init(api: MovementAPIProtocol = LiveMovementAPI()) {
            self.api = api
        }

        func attemptGetMovements() async {
            try? await withLoading(.load) {
                do {
                    let response = try await self.api.getMovements()
                    self.movements = response.results
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        var filteredMovements: [Movement] {
            if searchText.isEmpty {
                return movements
            } else {
                return movements.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
        }

        private func handleNetworkError(_ error: RemoteNetworkingError) {
            guard let messages = error.messages else {
                alert = AppAlert(title: "Error", message: "Unknown error")
                return
            }
            let msg = messages.values.compactMap { value -> String? in
                if let arr = value as? NSArray {
                    return arr.compactMap { $0 as? String }.joined(separator: "\n")
                }
                return value as? String
            }.joined(separator: "\n")
            alert = AppAlert(title: "Error", message: msg.isEmpty ? "Unknown error" : msg)
        }
    }
}
