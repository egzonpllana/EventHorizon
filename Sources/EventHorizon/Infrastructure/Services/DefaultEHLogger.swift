import Foundation

/// A logger that conforms to `EHLoggerProtocol` for logging messages with different levels.
///
/// This logger provides methods to log messages with types such as info, error, and debug. It only logs
/// messages in the debug build configuration.
///
/// Example usage:
/// ```swift
/// let logger = DefaultEHLogger()
/// logger.log(message: "Request started", type: .info)
/// logger.log(message: "Request failed", type: .error)
/// ```
///
/// - Note: This implementation uses `print` for logging messages in the console and is only active in debug builds.
public final class DefaultEHLogger: EHLoggerProtocol {

    /// Initializes a new instance of the logger.
    public init() {}

    /// Logs a message with the specified log type.
    ///
    /// - Parameters:
    ///   - message: The message to be logged.
    ///   - type: The type of the log message (e.g., info, error, or debug).
    ///
    /// - Note: Only active in debug builds.
    public func log(message: String, type: EHLoggerType) {
        #if DEBUG
        switch type {
            case .info:
                print("ℹ️ [DefaultEHLogger][Info]: \(message)")
            case .error:
                print("❌ [DefaultEHLogger][Error]: \(message)")
            case .debug:
                print("🐞 [DefaultEHLogger][Debug]: \(message)")
        }
        #endif
    }
}
