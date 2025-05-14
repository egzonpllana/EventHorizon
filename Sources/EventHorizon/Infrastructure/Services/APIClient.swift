import Foundation

public final class APIClient: APIClientProtocol {

    // MARK: - Properties -
    public let session: NetworkSessionProtocol
    public let interceptors: [any NetworkInterceptorProtocol]
    private let taskManager: APIClientTaskManagerProtocol
    private let logger: EHLoggerProtocol

    // MARK: - Initialization -
    public init(
        session: NetworkSessionProtocol = NetworkSession(),
        interceptors: [any NetworkInterceptorProtocol] = [],
        taskManager: APIClientTaskManagerProtocol = APIClientTaskManager.shared,
        logger: EHLoggerProtocol = DefaultEHLogger()
    ) {
        self.session = session
        self.interceptors = interceptors
        self.taskManager = taskManager
        self.logger = logger
    }

    // MARK: - Methods -
    public func request<T: Decodable & Sendable>(
        _ endpoint: any APIEndpointProtocol,
        decoder: JSONDecoder = JSONDecoder(),
        id: String
    ) async throws -> T {
        log(APIClientLogMessages.requestStarted(id: id))
        guard let request = endpoint.urlRequest else {
            throw APIClientError.invalidURL
        }
        log(APIClientLogMessages.startingEndpoint(endpoint: endpoint))

        switch taskManager.getTaskStatus(for: id) {
            case .finished:
                logError(APIClientLogMessages.guardFailed(reason: APIClientLogMessages.taskAlreadyFinished, id: id))
                throw APIClientError.taskFinished
            case .canceled:
                logError(APIClientLogMessages.guardFailed(reason: APIClientLogMessages.taskCanceled, id: id))
                throw APIClientError.taskCanceled
            case .inProgress, .queued:
                logError(APIClientLogMessages.guardFailed(reason: APIClientLogMessages.taskInProgressOrQueued, id: id))
                throw APIClientError.taskInProgress
            default:
                break
        }

        let task = Task {
            let data = try await performRequest(request)
            return try decoder.decode(T.self, from: data)
        }

        taskManager.addTask(task, for: id)

        defer {
            taskManager.setTaskStatus(
                for: id,
                status: .finished
            )
        }

        let result = try await task.value
        log(APIClientLogMessages.requestFinished(id: id))
        return result
    }

    public func request(
        _ endpoint: any APIEndpointProtocol,
        id: String
    ) async throws {
        log(APIClientLogMessages.requestStarted(id: id))
        guard let request = endpoint.urlRequest else {
            throw APIClientError.invalidURL
        }
        log(APIClientLogMessages.startingEndpoint(endpoint: endpoint))

        switch taskManager.getTaskStatus(for: id) {
            case .finished:
                logError(APIClientLogMessages.guardFailed(reason: APIClientLogMessages.taskAlreadyFinished, id: id))
                throw APIClientError.taskFinished
            case .canceled:
                logError(APIClientLogMessages.guardFailed(reason: APIClientLogMessages.taskCanceled, id: id))
                throw APIClientError.taskCanceled
            case .inProgress, .queued:
                logError(APIClientLogMessages.guardFailed(reason: APIClientLogMessages.taskInProgressOrQueued, id: id))
                throw APIClientError.taskInProgress
            default:
                break
        }

        let task = Task {
            try await performRequest(request)
        }

        taskManager.addTask(task, for: id)

        defer {
            taskManager.setTaskStatus(
                for: id,
                status: .finished
            )
        }

        do {
            _ = try await task.value
            log(APIClientLogMessages.requestFinished(id: id))
        } catch {
            logError(APIClientLogMessages.requestFailedWithError(id: id, error: error))
            throw error
        }
    }

    @discardableResult
    public func request(
        _ endpoint: any APIEndpointProtocol,
        progressDelegate: (any UploadProgressDelegateProtocol)?,
        id: String
    ) async throws -> Data? {
        log(APIClientLogMessages.requestStarted(id: id))
        guard let request = endpoint.urlRequest else {
            throw APIClientError.urlRequestIsEmpty
        }
        log(APIClientLogMessages.startingEndpoint(endpoint: endpoint))

        switch taskManager.getTaskStatus(for: id) {
            case .finished:
                logError(APIClientLogMessages.guardFailed(reason: APIClientLogMessages.taskAlreadyFinished, id: id))
                throw APIClientError.taskFinished
            case .canceled:
                logError(APIClientLogMessages.guardFailed(reason: APIClientLogMessages.taskCanceled, id: id))
                throw APIClientError.taskCanceled
            case .inProgress, .queued:
                logError(APIClientLogMessages.guardFailed(reason: APIClientLogMessages.taskInProgressOrQueued, id: id))
                throw APIClientError.taskInProgress
            default:
                break
        }

        let task = Task {
            let data = try await performRequest(request, progressDelegate: progressDelegate)
            return data
        }
        taskManager.addTask(task, for: id)

        defer {
            taskManager.setTaskStatus(
                for: id,
                status: .finished
            )
        }

        let result = try await task.value
        log(APIClientLogMessages.requestFinished(id: id))
        return result
    }

    public func cancelRequest(with id: String) {
        log(APIClientLogMessages.cancellingRequest(id: id))
        taskManager.cancelTask(for: id)
    }

    public func cancelAllRequests() {
        log(APIClientLogMessages.cancellingAllRequests)
        taskManager.cancelAllTasks()
    }
}

// MARK: - Private extensions -
private extension APIClient {

    @discardableResult
    private func performRequest(
        _ request: URLRequest,
        progressDelegate: (any UploadProgressDelegateProtocol)? = nil
    ) async throws -> Data {
        var mutableRequest = request
        log(APIClientLogMessages.performingRequest(request: request))

        // Apply request interceptors
        for interceptor in interceptors {
            mutableRequest = try await interceptor.interceptAsync(request: mutableRequest)
        }

        // If a progress delegate is provided, create a new session instance.
        let sessionToUse: NetworkSessionProtocol = {
            if let progressDelegate {
                return NetworkSession(session: URLSession(configuration: .default, delegate: progressDelegate, delegateQueue: nil))
            } else {
                return session
            }
        }()

        do {
            let (data, response) = try await sessionToUse.data(for: mutableRequest)
            log(APIClientLogMessages.requestSucceeded(response: response))

            // Apply response interceptors
            var modifiedData = data
            var modifiedResponse = response
            for interceptor in interceptors {
                let result = try await interceptor.interceptAsync(response: modifiedResponse, data: modifiedData)
                modifiedResponse = result.0 ?? modifiedResponse
                modifiedData = result.1 ?? modifiedData
            }

            guard let httpResponse = modifiedResponse as? HTTPURLResponse else {
                throw APIClientError.invalidResponse(modifiedData)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIClientError.statusCode(httpResponse.statusCode)
            }

            return modifiedData
        } catch {
            logError(APIClientLogMessages.requestFailed(error: error))
            logError(APIClientLogMessages.failedRequestDetails(request: request))
            if let urlError = error as? URLError {
                throw APIClientError.networkError(urlError)
            } else {
                throw APIClientError.requestFailed(error)
            }
        }
    }
}

// MARK: - Log extension -
private extension APIClient {
    func log(_ message: String) {
        logger.log(message: message, type: .debug)
    }

    func logError(_ message: String) {
        logger.log(message: message, type: .error)
    }
}

private enum APIClientLogMessages {
    static func requestStarted(id: String) -> String { "Request started with id: \(id)" }
    static func startingEndpoint(endpoint: any APIEndpointProtocol) -> String { "Starting request for endpoint: \(endpoint)" }
    static func requestFinished(id: String) -> String { "Request finished successfully for id: \(id)" }
    static func guardFailed(reason: String, id: String) -> String { "Guard condition failed: \(reason) for id: \(id)" }
    static func cancellingRequest(id: String) -> String { "Cancelling request with id: \(id)" }
    static let cancellingAllRequests = "Cancelling all requests"
    static func performingRequest(request: URLRequest) -> String { "Performing request: \(request)" }
    static func requestSucceeded(response: URLResponse) -> String { "Request succeeded with response: \(response)" }
    static func requestFailed(error: Error) -> String { "Request failed with error: \(error)" }
    static func requestFailedWithError(id: String, error: Error) -> String { "Request failed for id: \(id) with error: \(error)" }
    static func failedRequestDetails(request: URLRequest) -> String { "Failed request details - URL: \(request.url?.absoluteString ?? "nil"), Headers: \(request.allHTTPHeaderFields ?? [:])" }
    static let taskInProgressOrQueued = "Task in progress or queued"
    static let taskAlreadyFinished = "Task already finished"
    static let taskCanceled = "Task canceled"
}
