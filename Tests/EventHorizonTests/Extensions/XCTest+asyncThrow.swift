//
//  XCTest+asyncThrow.swift
//  EventHorizon
//

import XCTest

public extension XCTestCase {
    /// Asserts that an asynchronous expression throws an error.
    ///
    /// This function executes the provided asynchronous expression and verifies that it throws an error.
    /// If no error is thrown, the test fails.
    ///
    /// ## Usage
    /// ```swift
    /// await XCTAssertThrowsErrorAsync(try await someAsyncThrowingFunction()) { error in
    ///     XCTAssertEqual(error as? MyError, MyError.expectedError)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - expression: An asynchronous throwing expression to evaluate.
    ///   - message: A message to include in the failure description if the expression does not throw (default: `""`).
    ///   - file: The file where the failure occurs (default: `#filePath`).
    ///   - line: The line number where the failure occurs (default: `#line`).
    ///   - errorHandler: An optional closure to handle the thrown error.
    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @escaping @autoclosure () async throws -> T,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: ((Error) -> Void)? = nil
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error but got success. \(message)", file: file, line: line)
        } catch {
            errorHandler?(error)
        }
    }
}
