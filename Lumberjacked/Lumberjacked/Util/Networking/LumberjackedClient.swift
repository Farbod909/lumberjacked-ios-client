//
//  LumberjackedClient.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/29/25.
//

import SwiftUI

struct LumberjackedClientErrors {
    var messages = [String: Any]()
    
    func hasError(key: String) -> Bool {
        guard messages[key] != nil else {
            return false
        }
            
        if let errorValue = messages[key] as? [String] {
            return !errorValue.isEmpty
        }
        
        if let errorValue = messages[key] as? [String: [String]] {
            return errorValue.count > 0
        }
        
        return true
    }
    
    func errorMessage(key: String) -> String {
        guard hasError(key: key) else {
            return ""
        }
        
        if let errorValue = messages[key] as? [String] {
            return errorValue.joined(separator: "\n")
        }
        
        if let errorValue = messages[key] as? [String: [String]] {
            var childErrorStrings = [String]()
            for (_, childErrorValue) in errorValue {
                let childErrorString = childErrorValue.joined(separator: "\n")
                childErrorStrings.append(childErrorString)
            }
            return childErrorStrings.joined(separator: "\n")
        }

        return "Unknown error"
    }
}

struct LumberjackedClient {
    @Binding var errors: LumberjackedClientErrors
    
    func signup(email: String, password1: String, password2: String) async -> SignupResponse? {
        errors.messages = [:]

        let signupRequest = SignupRequest(
            email: email, password1: password1, password2: password2)
        
        let options = Networking.RequestOptions(
            url: "/auth/registration/",
            body: signupRequest,
            method: .POST,
            headers: [
                ("application/json", "Content-Type")
            ])
        
        do {
            return try await Networking.shared.request(options: options)
        } catch let error as RemoteNetworkingError {
            if let messages = error.messages {
                errors.messages = messages
            } else {
                errors.messages["detail"] = "Unknown error"
            }
        } catch {
            errors.messages["detail"] = "Unknown error"
        }
        return nil
    }
    
    func login(email: String, password: String) async -> LoginResponse? {
        errors.messages = [:]

        let loginRequest = LoginRequest(
            email: email, password: password)
        
        let options = Networking.RequestOptions(
            url: "/auth/login/",
            body: loginRequest,
            method: .POST,
            headers: [
                ("application/json", "Content-Type")
            ])
        
        do {
            return try await Networking.shared.request(options: options)
        } catch let error as RemoteNetworkingError {
            if let messages = error.messages {
                errors.messages = messages
            } else {
                errors.messages["detail"] = "Unknown error"
            }
        } catch {
            errors.messages["detail"] = "Unknown error"
        }
        return nil
    }

    
    func logout() async {
        errors.messages = [:]
        
        let options = Networking.RequestOptions(url: "/auth/logout/", method: .POST)
        do {
            try await Networking.shared.request(options: options)
        } catch let error as RemoteNetworkingError {
            if let messages = error.messages {
                errors.messages = messages
            } else {
                errors.messages["detail"] = "Unknown error"
            }
        } catch {
            errors.messages["detail"] = "Unknown error"
        }
    }
    
    func getCurrentWorkout() async -> Workout? {
        errors.messages = [:]
        
        let options = Networking.RequestOptions(url: "/api/workouts/current/", method: .GET)
        do {
            return try await Networking.shared.request(options: options)
        } catch let error as RemoteNetworkingError {
            if let messages = error.messages {
                errors.messages = messages
            } else {
                errors.messages["detail"] = "Unknown error"
            }
        } catch {
            errors.messages["detail"] = "Unknown error"
        }
        return nil
    }
    
    func endWorkout(id: UInt64) async -> Bool {
        errors.messages = [:]
        
        let options = Networking.RequestOptions(url: "/api/workouts/\(id)/end/", method: .GET)
        do {
            try await Networking.shared.request(options: options)
        } catch let error as RemoteNetworkingError {
            if let messages = error.messages {
                errors.messages = messages
            } else {
                errors.messages["detail"] = "Unknown error"
            }
            return false
        } catch {
            errors.messages["detail"] = "Unknown error"
            return false
        }
        return true
    }
    
    func getWorkouts() async -> APIResponseList<Workout>? {
        errors.messages = [:]
        
        let options = Networking.RequestOptions(url: "/api/workouts/", method: .GET)
        do {
            return try await Networking.shared.request(options: options)
        } catch let error as RemoteNetworkingError {
            if let messages = error.messages {
                errors.messages = messages
            } else {
                errors.messages["detail"] = "Unknown error"
            }
        } catch {
            errors.messages["detail"] = "Unknown error"
        }
        return nil
    }
    
    func getMovements() async -> APIResponseList<Movement>? {
        errors.messages = [:]
        
        let options = Networking.RequestOptions(url: "/api/movements/", method: .GET)
        do {
            return try await Networking.shared.request(options: options)
        } catch let error as RemoteNetworkingError {
            if let messages = error.messages {
                errors.messages = messages
            } else {
                errors.messages["detail"] = "Unknown error"
            }
        } catch {
            errors.messages["detail"] = "Unknown error"
        }
        return nil
    }

    func createWorkout(movements: [UInt64]) async -> Workout? {
        errors.messages = [:]
        
        let createWorkoutRequest = CreateWorkoutRequest(
            movements: movements)
        
        let options = Networking.RequestOptions(
            url: "/api/workouts/",
            body: createWorkoutRequest,
            method: .POST,
            headers: [
                ("application/json", "Content-Type")
            ])
        
        do {
            return try await Networking.shared.request(options: options)
        } catch let error as RemoteNetworkingError {
            if let messages = error.messages {
                errors.messages = messages
            } else {
                errors.messages["detail"] = "Unknown error"
            }
        } catch {
            errors.messages["detail"] = "Unknown error"
        }
        return nil
    }

}
