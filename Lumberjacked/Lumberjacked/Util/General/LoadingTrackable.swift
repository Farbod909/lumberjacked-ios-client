//
//  LoadingTrackable.swift
//  Lumberjacked
//

protocol LoadingTrackable: AnyObject {
    associatedtype LoadingKey: Hashable
    var loadingKeys: Set<LoadingKey> { get set }
}

extension LoadingTrackable {
    func isLoading(_ key: LoadingKey) -> Bool {
        loadingKeys.contains(key)
    }

    func withLoading(_ key: LoadingKey, action: () async throws -> Void) async throws {
        loadingKeys.insert(key)
        defer { loadingKeys.remove(key) }
        try await action()
    }
}
