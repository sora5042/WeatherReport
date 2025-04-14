//
//  APIClient.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/14.
//

import Foundation

public typealias Parameters = any Encodable

public struct APIClient {
    private var session: URLSessionProtocol
    private var decoder: JSONDecoder
    private var baseURL: String

    public init(
        session: URLSessionProtocol = URLSession.shared,
        decoder: JSONDecoder = .init(),
        baseURL: String = "https://api.openweathermap.org/data/2.5/"
    ) {
        self.session = session
        self.decoder = decoder
        self.baseURL = baseURL
    }

    public func response<Response: Decodable>(method: HTTPMethod, path: String?, parameters: Parameters?) async throws -> Response {
        do {
            let data = try await data(method: method, path: path, parameters: parameters)
            return try decode(data)
        } catch {
            throw error
        }
    }

    private func data(method: HTTPMethod, path: String? = nil, parameters: Parameters? = nil) async throws -> Data {
        let dictionary = try (parameters?.convertToDictionary() ?? [:])

        var request = createRequest(method: method, path: path, parameters: dictionary)
        request.setValue("application/json", forHTTPHeaderField: "accept")

        return try await performRequest(request)
    }

    private func performRequest(_ request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    return data
                case 400:
                    throw APIError.unauthorized(data)
                default:
                    throw APIError.data(data, httpResponse.statusCode)
                }
            } else {
                throw APIError.invalidResponse
            }
        } catch {
            switch error {
            case URLError.cancelled:
                throw APIError.cancelled
            default:
                throw error as? APIError ?? APIError.unknown(error)
            }
        }
    }

    private func createRequest(method: HTTPMethod, path: String? = nil, parameters: [String: Any]? = nil) -> URLRequest {
        let query = URLQueryBuilder(dictionary: parameters ?? [:]).build()

        var url = URL(string: baseURL)!
        if let path {
            url = url.appendingPathComponent(path)
        }
        if method == .get, !query.isEmpty {
            url = URL(string: url.absoluteString + "?" + query)!
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        if method != .get, !query.isEmpty {
            request.httpBody = query.data(using: .utf8)
        }

        return request
    }

    private func decode<Response: Decodable>(_ data: Data) throws -> Response {
        do {
            let decoded = try decoder.decode(Response.self, from: data)
            return decoded
        } catch {
            if let error = try? decoder.decode(OpenWeatherError.self, from: data) {
                throw APIError.message(error.message)
            } else {
                throw APIError.decodeError(data, error)
            }
        }
    }
}
