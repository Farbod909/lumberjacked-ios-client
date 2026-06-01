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
        var errors = LumberjackedClientErrors()

        private let api: MovementAPIProtocol

        init(api: MovementAPIProtocol = LiveMovementAPI()) {
            self.api = api
        }

        func attemptGetMovements() async {
            try? await withLoading(.load) {
                self.errors.messages = [:]
                do {
                    let response = try await self.api.getMovements()
                    self.movements = response.results
                } catch let error as RemoteNetworkingError {
                    if let messages = error.messages {
                        self.errors.messages = messages
                    } else {
                        self.errors.messages["detail"] = "Unknown error"
                    }
                } catch {
                    self.errors.messages["detail"] = "Unknown error"
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
    }
}
