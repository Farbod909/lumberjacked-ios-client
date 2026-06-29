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
        var showBodyPartFilterSheet = false
        var showResistanceTypeFilterSheet = false
        var alert: AppAlert?

        // Filter state
        var selectedBodyParts: Set<BodyPart> = []
        var selectedResistanceTypes: Set<ResistanceType> = []
        var sortOrder: SortOrder = .name

        enum SortOrder: String, CaseIterable {
            case name           = "Name"
            case bodyPart       = "Body Part"
            case resistanceType = "Resistance Type"
        }

        var isFiltered: Bool {
            !selectedBodyParts.isEmpty || !selectedResistanceTypes.isEmpty || sortOrder != .name
        }

        private let api: MovementAPIProtocol

        init(api: MovementAPIProtocol = LiveMovementAPI()) {
            self.api = api
        }

        func movementTapped(_ movement: Movement) {
            destination = .movementDetail(movement)
        }

        func resetFilters() {
            selectedBodyParts = []
            selectedResistanceTypes = []
            sortOrder = .name
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
            var result = movements

            if !searchText.isEmpty {
                result = result.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }

            if !selectedBodyParts.isEmpty {
                result = result.filter { movement in
                    guard let raw = movement.body_part, let bp = BodyPart(rawValue: raw) else { return false }
                    return selectedBodyParts.contains(bp)
                }
            }

            if !selectedResistanceTypes.isEmpty {
                result = result.filter { movement in
                    guard let raw = movement.resistance_type, let rt = ResistanceType(rawValue: raw) else { return false }
                    return selectedResistanceTypes.contains(rt)
                }
            }

            switch sortOrder {
            case .name:
                result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            case .bodyPart:
                result.sort { lhs, rhs in
                    let a = lhs.body_part.flatMap { BodyPart(rawValue: $0) }?.displayName ?? ""
                    let b = rhs.body_part.flatMap { BodyPart(rawValue: $0) }?.displayName ?? ""
                    return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
                }
            case .resistanceType:
                result.sort { lhs, rhs in
                    let a = lhs.resistance_type.flatMap { ResistanceType(rawValue: $0) }?.displayName ?? ""
                    let b = rhs.resistance_type.flatMap { ResistanceType(rawValue: $0) }?.displayName ?? ""
                    return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
                }
            }

            return result
        }

        private func handleNetworkError(_ error: RemoteNetworkingError) {
            alert = AppAlert(title: "Error", message: error.localizedDescription)
        }
    }
}
