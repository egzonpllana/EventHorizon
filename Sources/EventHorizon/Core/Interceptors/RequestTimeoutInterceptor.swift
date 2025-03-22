import Foundation

/// A network interceptor that sets a custom timeout interval for outgoing requests.
///
/// `RequestTimeoutInterceptor` modifies the timeout interval of network requests, ensuring that
/// requests do not hang indefinitely. This is useful for enforcing strict request timing policies.
///
/// - Note: This interceptor does not modify the response.
public struct RequestTimeoutInterceptor: NetworkInterceptor, Sendable {
    private let timeout: TimeInterval

    public init(timeout: TimeInterval) {
        self.timeout = timeout
    }

    public func intercept(request: URLRequest) -> URLRequest {
        let modifiedRequest = request
        let newConfig = URLSessionConfiguration.default
        newConfig.timeoutIntervalForRequest = timeout
        newConfig.timeoutIntervalForResource = timeout
        return modifiedRequest
    }

    public func intercept(response: URLResponse?, data: Data?) -> (URLResponse?, Data?) {
        return (response, data)
    }
}
