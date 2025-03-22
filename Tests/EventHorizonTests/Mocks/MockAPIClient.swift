//
//  MockAPIClient.swift
//  EventHorizon
//

import Foundation
@testable import EventHorizon

/// A mock implementation of `APIClientProtocol` for unit testing API requests.
///
/// `MockAPIClient` allows you to simulate API responses, errors, and request handling,
/// making it useful for testing network-related functionality without actual network calls.
///
/// ## Usage
/// ```swift
/// let mockClient = MockAPIClient()
/// try mockClient.setMockResponse(User(name: "John Doe"), forPath: "/user")
/// let user: User = try await mockClient.request(MockAPIEndpoint(path: "/user"), decoder: JSONDecoder())
/// ```
///
/// - Note: This actor ensures thread safety for mock response management.
public actor MockAPIClient: APIClientProtocol {

    /// The list of network interceptors used in the client.
    public let interceptors: [NetworkInterceptor]

    /// The URL session used for requests (unused in the mock).
    public let session: URLSession

    /// A dictionary mapping endpoint paths to mock response data.
    private var responseMap: [String: Data] = [:]

    /// A flag indicating whether requests should throw an error.
    private var shouldThrowError: Bool = false

    /// Initializes the mock API client with optional network interceptors.
    /// - Parameter interceptors: An array of `NetworkInterceptor` instances (default: `[MockNetworkInterceptor()]`).
    public init(interceptors: [NetworkInterceptor] = [MockNetworkInterceptor()]) {
        self.interceptors = interceptors
        self.session = URLSession(configuration: .default)
    }

    /// Simulates a network request and returns a decoded response.
    /// - Parameters:
    ///   - endpoint: The API endpoint to request.
    ///   - decoder: The JSON decoder used to parse the response.
    /// - Returns: A decoded response of type `T`.
    /// - Throws: `URLError(.badServerResponse)` if no mock response is found or if `shouldThrowError` is set to `true`.
    public func request<T: Codable & Sendable>(_ endpoint: APIEndpointProtocol, decoder: JSONDecoder) async throws -> T {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        guard let data = responseMap[endpoint.path] else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(T.self, from: data)
    }

    /// Simulates a network request that does not return a response.
    /// - Parameter endpoint: The API endpoint to request.
    /// - Throws: `URLError(.badServerResponse)` if `shouldThrowError` is set to `true`.
    public func requestVoid(_ endpoint: APIEndpointProtocol) async throws {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
    }

    /// Simulates a network request that supports progress updates.
    /// - Parameters:
    ///   - endpoint: The API endpoint to request.
    ///   - progressDelegate: An optional delegate for tracking upload progress.
    /// - Returns: The mock response data if available.
    /// - Throws: `URLError(.badServerResponse)` if `shouldThrowError` is set to `true`.
    public func requestWithProgress(_ endpoint: APIEndpointProtocol, progressDelegate: UploadProgressDelegateProtocol?) async throws -> Data? {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        return responseMap[endpoint.path]
    }

    /// Sets a mock response for a specific endpoint path.
    /// - Parameters:
    ///   - response: The Codable object to be returned as mock response data.
    ///   - path: The endpoint path to associate the response with.
    /// - Throws: An error if encoding the response to JSON fails.
    public func setMockResponse<T: Codable>(_ response: T, forPath path: String) throws {
        let data = try JSONEncoder().encode(response)
        responseMap[path] = data
    }

    /// Sets whether all requests should throw an error.
    /// - Parameter value: `true` to simulate request failures, `false` to return mock responses.
    public func setShouldThrowError(_ value: Bool) {
        shouldThrowError = value
    }
}
