//
//  Networking.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/22/25.
//

import Foundation
import SwiftUI

struct RemoteNetworkingError: Error {
    var statusCode: Int
    var messages: [String: Any]?
}

class Networking {
    static let shared = Networking()
        
    struct RequestOptions {
        enum HTTPMethod {
            case GET, POST, PUT, PATCH, DELETE
        }

        var url: String
        var body: Encodable?
        var method: HTTPMethod?
        var headers = [(String?, String)]()
    }
    
//    static let host = "http://192.168.0.147:8000"
    static let host = "https://lumberjacked-dev-2-1029906100530.us-west2.run.app"
    var sessionConfiguration: URLSessionConfiguration
    let decoder: JSONDecoder
    private lazy var session: URLSession = {
        URLSession(configuration: self.sessionConfiguration)
    }()
                
    init(sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        
        self.sessionConfiguration = sessionConfiguration
        self.decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // With microseconds
                "yyyy-MM-dd'T'HH:mm:ssXXXXX",        // Without microseconds
            ]
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string '\(dateString)' does not match any expected format.")
        }
    }
        
    @discardableResult
    func request(options: RequestOptions) async throws -> Data? {
        guard let url = URL(string: "\(Networking.host)\(options.url)") else {
            assertionFailure("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
            
        for headerTuple in options.headers {
            request.setValue(headerTuple.0, forHTTPHeaderField: headerTuple.1)
        }
        
        switch options.method {
        case .GET:
            request.httpMethod = "GET"
            break
        case .POST:
            request.httpMethod = "POST"
            break
        case .PUT:
            request.httpMethod = "PUT"
            break
        case .PATCH:
            request.httpMethod = "PATCH"
            break
        case .DELETE:
            request.httpMethod = "DELETE"
            break
        case .none: break // do nothing
        }
        
        if let accessToken = Keychain.standard.read(
            service: "accessToken", account: "lumberjacked", type: String.self
        ) {
            self.sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Token \(accessToken)"
            ]
        } else {
            self.sessionConfiguration.httpAdditionalHeaders?.removeValue(forKey: "Authorization")
        }
        
        let session = self.session
        
        var response = URLResponse()
        var data = Data()
                
        if let requestBody = options.body {
            do {
                let encoded = try JSONEncoder().encode(requestBody)
                do {
                    (data, response) = try await session.upload(for: request, from: encoded)
                } catch {
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                        // Expected when user switches tabs / cancels a task
                        return nil
                    }
                    throw error // rethrow unexpected errors
                }
            } catch {
                assertionFailure("Failed to encode data: \(error)")
                return nil
            }
        } else {
            do {
                (data, response) = try await session.data(for: request)
            } catch {
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    // Expected when user switches tabs / cancels a task
                    return nil
                }
                throw error // rethrow unexpected errors
            }
        }
                
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 299 {
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonDict = jsonObject as? [String: Any] {
                throw RemoteNetworkingError(statusCode: httpResponse.statusCode, messages: jsonDict)
            } else {
                throw RemoteNetworkingError(statusCode: httpResponse.statusCode, messages: nil)
            }

        }
        return data
    }
    
    func request<ResponseType: Decodable>(options: RequestOptions) async throws -> ResponseType? {
        guard let data = try await request(options: options) else {
            return nil
        }
        do {
            let decodedResponse = try decoder.decode(ResponseType.self, from: data)
            return decodedResponse
        } catch {
            assertionFailure("Failed to decode data: \(error)")
        }
        return nil
    }
}
