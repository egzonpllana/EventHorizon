import Foundation

/// A mock URL protocol used for unit testing network requests.
///
/// `MockURLProtocol` allows you to intercept network requests made with `URLSession`
/// and provide predefined responses, making it useful for testing network-dependent functionality.
///
/// ## Usage
/// 1. Set the `mockResponse` property with the desired `Data`, `HTTPURLResponse`, and `Error?`.
/// 2. Configure a `URLSession` with a `URLSessionConfiguration` that uses `MockURLProtocol`.
///
/// ```swift
/// let config = URLSessionConfiguration.ephemeral
/// config.protocolClasses = [MockURLProtocol.self]
/// let session = URLSession(configuration: config)
///
/// MockURLProtocol.mockResponse = (mockData, mockResponse, nil)
///
/// let task = session.dataTask(with: url) { data, response, error in
///     // Handle response
/// }
/// task.resume()
/// ```
public final class MockURLProtocol: URLProtocol {

    /// The mock response to be returned when a request is intercepted.
    /// - Parameters:
    ///   - `Data?`: The mock data to be returned in the response body.
    ///   - `HTTPURLResponse?`: The HTTP response to be returned.
    ///   - `Error?`: An optional error to simulate a failed request.
    public static var mockResponse: (Data?, HTTPURLResponse?, Error?) = (nil, nil, nil)

    /// Determines whether this protocol can handle the given request.
    /// - Parameter request: The request to evaluate.
    /// - Returns: Always returns `true`, as all requests are handled by this protocol.
    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    /// Returns the canonical version of the given request.
    /// - Parameter request: The request to standardize.
    /// - Returns: The original request, unchanged.
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    /// Starts loading the request by returning the mock response.
    public override func startLoading() {
        if let error = MockURLProtocol.mockResponse.2 {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.mockResponse.1 {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data = MockURLProtocol.mockResponse.0 {
                let chunkSize = max(1, data.count / 3)
                for start in stride(from: 0, to: data.count, by: chunkSize) {
                    let end = min(start + chunkSize, data.count)
                    client?.urlProtocol(self, didLoad: data[start..<end])
                }
            }

            client?.urlProtocolDidFinishLoading(self)
        }
    }

    /// Stops loading the request. This implementation does nothing.
    public override func stopLoading() {}
}
