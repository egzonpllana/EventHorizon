import Foundation

/// An enumeration representing errors that can occur during API client operations.
///
/// This enum encapsulates various errors that may arise when performing network requests, handling responses, or decoding data. Each case provides information about the nature of the error.
public enum APIClientError: Error {

    /// Indicates that the URL provided for the request is invalid.
    case invalidURL

    /// Indicates that the response received is invalid.
    /// - Parameter data: The raw data received from the response.
    case invalidResponse(_ data: Data)

    /// Indicates that the request failed due to an underlying error.
    /// - Parameter error: The underlying error that caused the failure.
    case requestFailed(_ error: any Error)

    /// Indicates that decoding the received data failed.
    /// - Parameter error: The underlying error encountered during decoding.
    case decodingFailed(_ error: any Error)

    /// Indicates that the HTTP response code was not expected.
    /// - Parameter code: The unexpected HTTP response status code.
    case notExpectedHttpResponseCode(code: Int)

    /// Indicates that the URL request is empty or improperly configured.
    case urlRequestIsEmpty

    /// Indicates that the HTTP response returned a specific status code.
    /// - Parameter code: The HTTP status code received.
    case statusCode(Int)

    /// Indicates a network-related error occurred.
    /// - Parameter error: The underlying network error encountered.
    case networkError(any Error)
}
