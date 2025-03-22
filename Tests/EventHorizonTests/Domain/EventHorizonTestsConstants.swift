//
//  EventHorizonTestsConstants.swift
//  EventHorizon
//

/// A collection of constants used in `EventHorizon` unit tests.
///
/// `EventHorizonTestsConstants` provides predefined values such as success messages, test URLs, and HTTP status codes
/// to simplify and standardize test cases.
///
/// ## Usage
/// ```swift
/// XCTAssertEqual(response.status, EventHorizonTestsConstants.successMessage)
/// XCTAssertEqual(mockURL, EventHorizonTestsConstants.testURL)
/// XCTAssertEqual(httpResponse.statusCode, EventHorizonTestsConstants.httpStatusOk)
/// ```
public enum EventHorizonTestsConstants {

    /// A generic success message used in tests.
    public static let successMessage = "Success"

    /// A sample test URL used for network-related tests.
    public static let testURL = "https://example.com/test"

    /// The HTTP status code for a successful request (200 OK).
    public static let httpStatusOk = 200
}
