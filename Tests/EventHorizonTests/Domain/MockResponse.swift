//
//  MockResponse.swift
//  EventHorizon
//

/// A mock response model for testing API responses.
///
/// `MockResponse` is a simple Codable and Sendable struct that represents a standard API response
/// with a message and status, making it useful for unit tests.
///
/// ## Usage
/// ```swift
/// let mock = MockResponse(message: "Success", status: "OK")
/// let encodedData = try JSONEncoder().encode(mock)
/// let decodedMock = try JSONDecoder().decode(MockResponse.self, from: encodedData)
/// ```
///
/// - Note: This struct is primarily for testing and mocking network responses.
public struct MockResponse: Codable, Sendable {

    /// The response message.
    public let message: String

    /// The response status.
    public let status: String

    /// Initializes a mock response with default values.
    /// - Parameters:
    ///   - message: The response message (default: `""`).
    ///   - status: The response status (default: `""`).
    public init(message: String = "", status: String = "") {
        self.message = message
        self.status = status
    }
}
