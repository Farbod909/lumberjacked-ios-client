//
//  MovementCatalogView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/21/25.
//

import SwiftUI

extension MovementCatalogView {
    @Observable
    class ViewModel {
        var movements = [Movement]()
        var isLoading = true
        var searchText = ""
        var showCreateMovementSheet = false
        var errors = LumberjackedClientErrors()

        private let api: MovementAPIProtocol

        init(api: MovementAPIProtocol = LiveMovementAPI()) {
            self.api = api
        }

        func attemptGetMovements() async {
            isLoading = true
            errors.messages = [:]
            do {
                let response = try await api.getMovements()
                movements = response.results
            } catch let error as RemoteNetworkingError {
                if let messages = error.messages {
                    errors.messages = messages
                } else {
                    errors.messages["detail"] = "Unknown error"
                }
            } catch {
                errors.messages["detail"] = "Unknown error"
            }
            isLoading = false
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
