//
//  MovementDetailView-ViewModel.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import SwiftUI

extension MovementDetailView {
    @Observable
    class ViewModel: LoadingTrackable {
        enum LoadingKey { case logs, delete }
        var loadingKeys: Set<LoadingKey> = [.logs]

        enum Destination: Identifiable, Hashable {
            case editLog(MovementLog)
            var id: String {
                switch self {
                case .editLog(let log): return "editLog-\(log.id ?? 0)"
                }
            }
        }
        var destination: Destination?

        var movement: Movement
        var movementLogs = [MovementLog]()
        var nextURL: String?
        var isLoadingMore = false
        var showDeleteConfirmationAlert = false
        var showEditSheet = false
        var alert: AppAlert?

        private let movementAPI: MovementAPIProtocol
        private let movementLogAPI: MovementLogAPIProtocol

        init(
            movement: Movement,
            movementLogs: [MovementLog] = [],
            movementAPI: MovementAPIProtocol = LiveMovementAPI(),
            movementLogAPI: MovementLogAPIProtocol = LiveMovementLogAPI()
        ) {
            self.movement = movement
            self.movementLogs = movementLogs
            self.movementAPI = movementAPI
            self.movementLogAPI = movementLogAPI
        }

        func logTapped(_ log: MovementLog) {
            destination = .editLog(log)
        }

        // MARK: - Fetch

        func attemptGetMovementLogs() async {
            guard let id = movement.id else { return }
            try? await withLoading(.logs) {
                do {
                    let response = try await self.movementLogAPI.getMovementLogs(movementId: id)
                    self.movementLogs = response.results
                    self.nextURL = response.nextPageRelativeURL
                } catch let error as RemoteNetworkingError {
                    self.handleNetworkError(error)
                } catch {
                    self.alert = AppAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        func attemptLoadMore() async {
            guard !isLoadingMore, let pageURL = nextURL else { return }
            isLoadingMore = true
            defer { isLoadingMore = false }
            do {
                let response = try await movementLogAPI.getMovementLogs(pageURL: pageURL)
                movementLogs.append(contentsOf: response.results)
                nextURL = response.nextPageRelativeURL
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
        }

        // MARK: - Log callbacks

        func logSaved(_ log: MovementLog) {
            if let idx = movementLogs.firstIndex(where: { $0.id == log.id }) {
                movementLogs[idx] = log
            }
        }

        func logDeleted(_ log: MovementLog) {
            movementLogs.removeAll { $0.id == log.id }
        }

        // MARK: - Delete movement

        @MainActor
        func attemptDeleteMovement() async -> Bool {
            guard let id = movement.id else { return false }
            loadingKeys.insert(.delete)
            defer { loadingKeys.remove(.delete) }
            do {
                try await movementAPI.deleteMovement(movementId: id)
                return true
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
            return false
        }

        func attemptGetMovementDetail(id: UInt64) async {
            do {
                movement = try await movementAPI.getMovement(movementId: id)
            } catch let error as RemoteNetworkingError {
                handleNetworkError(error)
            } catch {
                alert = AppAlert(title: "Error", message: error.localizedDescription)
            }
        }

        private func handleNetworkError(_ error: RemoteNetworkingError) {
            alert = AppAlert(title: "Error", message: error.localizedDescription)
        }
    }
}
