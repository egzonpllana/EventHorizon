//
//  MockProgressDelegate.swift
//  EventHorizon
//

import Foundation
@testable import EventHorizon

/// A mock implementation of `UploadProgressDelegateProtocol` for testing upload progress updates.
///
/// `MockProgressDelegate` is an actor that collects progress updates,
/// allowing verification of progress reporting in unit tests.
///
/// ## Usage
/// ```swift
/// let mockDelegate = MockProgressDelegate()
/// mockDelegate.updateProgress(0.5)
/// XCTAssertEqual(mockDelegate.progressValues, [0.5])
/// ```
///
/// - Note: This actor ensures thread safety when handling progress updates.
public actor MockProgressDelegate: NSObject, UploadProgressDelegateProtocol {

    /// Stores the reported progress values in sequence.
    public private(set) var progressValues: [Double] = []

    /// Captures the upload progress updates.
    /// - Parameter progress: The current upload progress value (0.0 - 1.0).
    public func updateProgress(_ progress: Double) {
        progressValues.append(progress)
    }
}
