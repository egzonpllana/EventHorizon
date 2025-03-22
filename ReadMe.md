# EventHorizon

EventHorizon is a lightweight, thread-safe package designed to build a clean and organized network communication layer in Swift. It offers a type-safe and customizable approach to handling network requests with modern Swift features.

![EventHorizonSwiftiOSPackageHeaderImage](https://github.com/egzonpllana/EventHorizon/blob/main/event-horizon-header-image.png)
> The name **EventHorizon** represents the package's role as the ultimate control point for network requests. Just as an event horizon marks the boundary of a black hole, where nothing escapes its pull, this package captures, shapes, and directs network communication with precision. It ensures that every request and response passes through a structured and seamless pipeline, making network communication both reliable and efficient.

#### Elegant and type-safe API
```swift
let posts: [PostDTO] = try await apiClient.request(APIEndpoint.getPosts)
```

## Features
- **Type-safe** network requests using Swift's generics.
- **Asynchronous** execution with Swift's async/await.
- **Multi-part request support** with progress tracking.
- **Interceptor-based customization** for request and response handling.
- **Direct access to URLSession** for low-level operations, SSL pining, mocking, caching rules, unit testing, and more.

## Requirements
- iOS 15.0+
- macOS 12.0+
- watchOS 8.0+
- tvOS 15.0+
- Swift 5.5+

## Interceptors
EventHorizon includes a set of built-in interceptors, but you can create and inject your custom interceptors as needed.

- `AuthInterceptor` - Injects an authorization token into network requests.
- `LoggingInterceptor` - Logs request and response details for debugging.
- `RequestTimeoutInterceptor` - Configures custom timeout intervals for requests.
- `HeaderInjectorInterceptor` - Adds custom headers to outgoing requests.
- `RetryInterceptor` - Automatically retries failed requests based on status codes.

## Networking Layer - Data Flow
![EventHorizonSwiftiOSPackageDataFlowImage](https://github.com/egzonpllana/EventHorizon/blob/main/event-horizon-networking-data-flow.png)

### API Layer
- **Components**:
  - `APIEndpoint`: Defines API routes and configurations.
  - `APIClient`: Manages network requests and responses.
  - `Network Interceptor`: Handles request modifications (e.g., authentication, logging).
- **Role**: This layer abstracts networking details, ensuring maintainability and separation of concerns.
- **Flow**: The repository calls `APIEndpoint` → passes it to `APIClient` → processed through `Network Interceptor` before sending the request.

### URLSession
- **Role**: The final networking component that executes HTTP requests and retrieves responses.
- **Flow**: `APIClient` sends the request via `URLSession`, receives the response, and decodes it using `JSONDecoder`.

### Data Flow
1. **Repository interacts** with `APIEndpoint` and `APIClient`.
2. **Network Interceptor** modifies the request (if needed) before reaching `URLSession`.
3. **URLSession fetches** data from the remote server.
4. **Response data** is decoded and propagated back through the layers.

## Mocking URL Session
You can use a custom URL Session and Interceptors to inject into the APIClient.
```swift
let apiClient = APIClient(
    session: URLSession,
    interceptors: [any NetworkInterceptor]
)
```

## Installation
To integrate EventHorizon into your project, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/egzonpllana/EventHorizon", from: "1.0.0")
]
```

## Usage
1. Import the EventHorizon module into your Swift files.
2. Create an instance of `APIClient` and configure it with the desired interceptors.
3. Use the `APIClient` instance to perform network requests.

### Example
#### Create an APIClient instance with interceptors:
```swift
import EventHorizon

let apiClient = APIClient(interceptors: [
    AuthInterceptor(tokenProvider: { "your_access_token" }),
    LoggingInterceptor(),
    RequestTimeoutInterceptor(timeout: 30),
    HeaderInjectorInterceptor(headers: ["Custom-Header": "Value"]),
    RetryInterceptor(maxRetries: 3)
])
```

#### Make network requests using APIClient:
```swift
// GET Posts request
let posts: [PostDTO] = try await apiClient.request(APIEndpoint.getPosts)

// POST a post request
try await apiClient.requestVoid(APIEndpoint.createPost(newPost))

// Multi-part request
try await apiClient.requestWithProgress(
    APIEndpoint.uploadImage(...),
    progressDelegate: UploadProgressDelegateProtocol
)
```

### Unit Testing with MockAPIClient
You can use `MockAPIClient` to mock network requests while unit testing your `ViewModel`.

```swift
import XCTest
@testable import EventHorizon

final class MyViewModelTests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var viewModel: MyViewModel!

    override func setUp() async throws {
        mockAPIClient = MockAPIClient()
        viewModel = MyViewModel(apiClient: mockAPIClient)
    }

    func testFetchData_Success() async throws {
        let mockResponse = MockResponse(message: "Success", status: "OK")
        try mockAPIClient.setMockResponse(mockResponse, forPath: "/mock")
        
        try await viewModel.fetchData()
        
        XCTAssertEqual(viewModel.message, "Success")
    }

    func testFetchData_Failure() async throws {
        mockAPIClient.setShouldThrowError(true)
        
        do {
            try await viewModel.fetchData()
            XCTFail("Expected error but got success.")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
```

### Real app example:
https://github.com/egzonpllana/NetworkLayerSwift6

### The meaning behind this package name EventHorizon
https://www.space.com/black-holes-event-horizon-explained.html

## License
EventHorizon is released under the MIT license. See LICENSE for details.

