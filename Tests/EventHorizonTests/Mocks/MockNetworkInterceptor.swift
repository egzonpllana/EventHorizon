//
//  MockNetworkInterceptor.swift
//  EventHorizon
//

import Foundation
@testable import EventHorizon

/// A mock implementation of `NetworkInterceptor` for testing network request and response modifications.
///
/// `MockNetworkInterceptor` allows customization of request and response handling
/// through closures, making it useful for testing network behavior in unit tests.
///
/// ## Usage
/// ```swift
/// let interceptor = MockNetworkInterceptor(
///     requestModifier: { request in
///         var modifiedRequest = request
///         modifiedRequest.addValue("Mock-Header", forHTTPHeaderField: "Authorization")
///         return modifiedRequest
///     },
///     responseModifier: { response, data in
///         return (response, mockData)
///     }
/// )
/// let modifiedRequest = interceptor.intercept(request: originalRequest)
/// ```
///
/// - Note: This class is designed for testing and should not be used in production.
public final class MockNetworkInterceptor: NetworkInterceptor {

    private let requestModifier: (@Sendable (URLRequest) -> URLRequest)?
    private let responseModifier: (@Sendable (URLResponse?, Data?) -> (URLResponse?, Data?))?

    /// Initializes the mock interceptor with optional request and response modifiers.
    /// - Parameters:
    ///   - requestModifier: A closure that modifies the outgoing `URLRequest`.
    ///   - responseModifier: A closure that modifies the incoming `URLResponse` and `Data?`.
    public init(
        requestModifier: (@Sendable (URLRequest) -> URLRequest)? = nil,
        responseModifier: (@Sendable (URLResponse?, Data?) -> (URLResponse?, Data?))? = nil
    ) {
        self.requestModifier = requestModifier
        self.responseModifier = responseModifier
    }

    /// Intercepts and modifies an outgoing request.
    /// - Parameter request: The original request.
    /// - Returns: The modified request if a `requestModifier` is provided, otherwise returns the original request.
    public func intercept(request: URLRequest) -> URLRequest {
        return requestModifier?(request) ?? request
    }

    /// Intercepts and modifies an incoming response.
    /// - Parameters:
    ///   - response: The original response.
    ///   - data: The original response data.
    /// - Returns: The modified response and data if a `responseModifier` is provided, otherwise returns the original response and data.
    public func intercept(
        response: URLResponse?,
        data: Data?
    ) -> (URLResponse?, Data?) {
        return responseModifier?(response, data) ?? (response, data)
    }
}
