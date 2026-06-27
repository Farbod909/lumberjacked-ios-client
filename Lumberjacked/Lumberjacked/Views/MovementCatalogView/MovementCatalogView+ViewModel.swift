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

        enum Destination: Identifiable, Hashable {
            case movementDetail(Movement)
            var id: String {
                switch self {
                case .movementDetail(let m): return "movementDetail-\(m.id ?? 0)"
                }
            }
        }
        var destination: Destination?

        var movements = [Movement]()
        var searchText = ""
        var showCreateMovementSheet = false
        var alert: AppAlert?

        private let api: MovementAPIProtocol

        init(api: MovementAPIProtocol = LiveMovementAPI()) {
            self.api = api
        }

        func movementTapped(_ movement: Movement) {
            destination = .movementDetail(movement)
        }

        func attemptRefresh() async {
            do {
                let response = try await api.getMovements()
                movements = response.results
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
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
            alert = AppAlert(title: "Error", message: error.localizedDescription)
        }
    }
}
