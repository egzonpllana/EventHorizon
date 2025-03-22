//
//  MockAPIEndpoint.swift
//  EventHorizon
//

import Foundation
@testable import EventHorizon

/// A mock implementation of `APIEndpointProtocol` for testing API request configurations.
///
/// `MockAPIEndpoint` allows developers to define custom API endpoints with various properties,
/// making it useful for unit tests and mocking network requests.
///
/// ## Usage
/// ```swift
/// let endpoint = MockAPIEndpoint(
///     method: .post,
///     path: "/login",
///     headers: ["Authorization": "Bearer token"],
///     urlParams: ["userId": 123]
/// )
/// print(endpoint.fullURL) // "https://example.com/v1/login?userId=123"
/// ```
///
/// - Note: This struct is designed for testing purposes and should not be used in production.
public struct MockAPIEndpoint: APIEndpointProtocol {

    /// The HTTP method for the request.
    public var method: HTTPMethod

    /// The relative path for the API endpoint.
    public var path: String

    /// The base URL for the API request.
    public var baseURL: String

    /// The headers included in the API request.
    public var headers: [String: String]

    /// The URL parameters included in the API request.
    public var urlParams: [String: CustomStringConvertible]

    /// The optional request body data.
    public var body: Data?

    /// The API version prefix for the endpoint.
    public var apiVersion: String

    /// Initializes a mock API endpoint with configurable properties.
    /// - Parameters:
    ///   - method: The HTTP method (default: `.get`).
    ///   - path: The endpoint path (default: `"/mock"`).
    ///   - baseURL: The base URL (default: `"https://example.com"`).
    ///   - headers: The request headers (default: `[:]`).
    ///   - urlParams: The URL query parameters (default: `[:]`).
    ///   - body: The request body data (default: `nil`).
    ///   - apiVersion: The API version prefix (default: `"/v1"`).
    public init(
        method: HTTPMethod = .get,
        path: String = "/mock",
        baseURL: String = "https://example.com",
        headers: [String: String] = [:],
        urlParams: [String: CustomStringConvertible] = [:],
        body: Data? = nil,
        apiVersion: String = "/v1"
    ) {
        self.method = method
        self.path = path
        self.baseURL = baseURL
        self.headers = headers
        self.urlParams = urlParams
        self.body = body
        self.apiVersion = apiVersion
    }

    /// Computes the full URL string by appending `apiVersion`, `path`, and `urlParams` to `baseURL`.
    /// - Returns: The complete URL as a string.
    public var fullURL: String {
        var components = URLComponents(string: baseURL + apiVersion + path)
        components?.queryItems = urlParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        return components?.url?.absoluteString ?? baseURL + apiVersion + path
    }
}
