import Foundation

/// A protocol that defines a network interceptor, allowing modifications to network requests and responses.
///
/// Conforming types can implement request and response interception logic, such as adding authentication headers,
/// logging network traffic, retrying failed requests, or modifying responses before they reach the caller.
///
/// ## Usage
/// Implement this protocol to customize network behavior. For example:
///
/// ```swift
/// struct AuthInterceptor: NetworkInterceptorProtocol {
///     private let tokenProvider: () -> String?
///
///     init(tokenProvider: @escaping () -> String?) {
///         self.tokenProvider = tokenProvider
///     }
///
///     func intercept(request: URLRequest) -> URLRequest {
///         var modifiedRequest = request
///         if let token = tokenProvider() {
///             modifiedRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
///         }
///         return modifiedRequest
///     }
///
///     func intercept(response: URLResponse?, data: Data?) -> (URLResponse?, Data?) {
///         return (response, data)
///     }
/// }
/// ```
///
/// ## Concurrency
/// - This protocol conforms to `Sendable`, meaning all conforming types must be safe to use across concurrent executions.
///
/// ## Example Use Cases
/// - **Authentication:** Add an authorization token to every request.
/// - **Logging:** Log outgoing requests and incoming responses.
/// - **Retries:** Retry failed requests under certain conditions.
/// - **Custom Headers:** Inject common headers like `User-Agent` or `Accept-Language`.
///
public protocol NetworkInterceptorProtocol: Sendable {
    /// Intercepts and potentially modifies an outgoing network request before it is sent.
    ///
    /// - Parameter request: The original `URLRequest` to be sent.
    /// - Returns: A modified `URLRequest` that will be executed.
    func intercept(request: URLRequest) -> URLRequest

    /// Intercepts and potentially modifies the response received from the network.
    ///
    /// - Parameters:
    ///   - response: The original `URLResponse` received from the server.
    ///   - data: The raw `Data` returned from the request.
    /// - Returns: A tuple containing the modified response and data.
    func intercept(
        response: URLResponse?,
        data: Data?
    ) -> (URLResponse?, Data?)
    
    /// Asynchronously intercepts and potentially modifies an outgoing network request before it is sent.
    ///
    /// - Parameter request: The original `URLRequest` to be sent.
    /// - Returns: A modified `URLRequest` that will be executed.
    /// - Throws: An error if interception fails.
    func interceptAsync(request: URLRequest) async throws -> URLRequest
    /// Asynchronously intercepts and potentially modifies the response received from the network.
    ///
    /// - Parameters:
    ///   - response: The original `URLResponse` received from the server.
    ///   - data: The raw `Data` returned from the request.
    /// - Returns: A tuple containing the modified response and data.
    /// - Throws: An error if interception fails.
    func interceptAsync(response: URLResponse?, data: Data?) async throws -> (URLResponse?, Data?)
}

// Default async implementations that just call the sync versions
public extension NetworkInterceptorProtocol {
    func interceptAsync(request: URLRequest) async throws -> URLRequest {
        intercept(request: request)
    }

    /// Provides a default asynchronous implementation of response interception
    /// by delegating to the synchronous `intercept(response:data:)` method.
    ///
    /// - Parameters:
    ///   - response: The original `URLResponse` received from the server.
    ///   - data: The raw `Data` returned from the request.
    /// - Returns: A tuple containing the modified response and data.
    /// Provides a default asynchronous implementation of response interception
    /// by delegating to the synchronous `intercept(response:data:)` method.
    ///
    /// - Parameters:
    ///   - response: The original `URLResponse` received from the server.
    ///   - data: The raw `Data` returned from the request.
    /// - Returns: A tuple containing the modified response and data.
    func interceptAsync(response: URLResponse?, data: Data?) async throws -> (URLResponse?, Data?) {
        intercept(response: response, data: data)
    }
}
