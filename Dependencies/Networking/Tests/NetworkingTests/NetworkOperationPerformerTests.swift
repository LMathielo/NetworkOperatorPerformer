import XCTest
import Network
@testable import Networking

final class NetworkOperationPerformerTests: XCTestCase {
    var networkMonitorMock: NetworkMonitorMock!
    var networkSessionMock: NetworkSessionMock!
    var sut: NetworkOperationPerformer!
    
    override func setUp() {
        networkMonitorMock = NetworkMonitorMock()
        networkSessionMock = NetworkSessionMock()
        
        sut = NetworkOperationPerformerImpl(
            networkMonitor: networkMonitorMock,
            session: networkSessionMock
        )
    }
    
    func test_networkReachable_downloadContent() async {
        // Given
        networkMonitorMock.isReachable = true
        
        // When
        let result: Result<DownloadableContentMock, NetworkError>? = await sut.performNetworkOperation(for: "https://google.com", within: 0.1)
        
        // Then
        guard case .success(_) = result else {
            return XCTFail("request failed")
        }
        
        XCTAssertTrue(networkSessionMock.fetchDataCalled)
    }
    
    func test_networkReachable_invalidUrl() async {
        // Given
        networkMonitorMock.isReachable = true
        
        // When
        let result: Result<DownloadableContentMock, NetworkError>? = await sut.performNetworkOperation(for: "", within: 0.1)
        
        // Then
        guard case let .failure(error) = result else {
            return XCTFail("request succeded")
        }
        
        XCTAssert(error == .invalidUrl)
        XCTAssertFalse(networkSessionMock.fetchDataCalled)
    }
    
    func test_networkReachable_parsingFailed() async {
        // Given
        networkMonitorMock.isReachable = true
        
        // When
        let result: Result<FailableParsingContentMock, NetworkError>? = await sut.performNetworkOperation(for: "https://google.com", within: 0.1)
        
        // Then
        guard case let .failure(error) = result else {
            return XCTFail("request succeded")
        }
        
        XCTAssert(error == .parsingFailure)
        XCTAssertTrue(networkSessionMock.fetchDataCalled)
    }
    
    func test_networkReachable_downloadFailed() async {
        // Given
        networkMonitorMock.isReachable = true
        networkSessionMock.fetchDataFailure = true
        
        // When
        let result: Result<DownloadableContentMock, NetworkError>? = await sut.performNetworkOperation(for: "https://google.com", within: 0.1)
        
        // Then
        guard case let .failure(error) = result else {
            return XCTFail("request succeded")
        }
        
        XCTAssert(error == .downloadFailed)
        XCTAssertTrue(networkSessionMock.fetchDataCalled)
    }
    
    func test_networkUnreachable_timeout() async {
        // Given
        networkMonitorMock.isReachable = false
        
        // When
        let result: Result<DownloadableContentMock, NetworkError>? = await sut.performNetworkOperation(for: "https://google.com", within: 0.1)
        
        // Then
        guard case let .failure(error) = result else {
            return XCTFail("request succeded")
        }
        
        XCTAssert(error == .timeout)
        XCTAssertFalse(networkSessionMock.fetchDataCalled)
    }
    
    func test_networkDelayedReachable_timelyDownloads() async {
        // Given
        networkMonitorMock.isReachable = false
        
        // When
        let result: Result<DownloadableContentMock, NetworkError>? = await sut.performNetworkOperation(for: "https://google.com", within: 0.3)
        
        // Then
        guard case .success(_) = result else {
            return XCTFail("request failed")
        }
        
        XCTAssertTrue(networkSessionMock.fetchDataCalled)
    }
}

// MARK: - Mocks
extension NetworkOperationPerformerTests {
    class NetworkSessionMock: NetworkSession {
        var fetchDataCalled = false
        var fetchDataFailure = false
        
        func fetchData(from url: URL) async throws -> (Data, URLResponse) {
            fetchDataCalled = true
            
            if fetchDataFailure { throw NetworkError.unknown("mock throw!") }
            
            return (Data(), URLResponse())
        }
    }
    
    struct DownloadableContentMock: DownloadableContent {
        init?(data: Data) {
            
        }
    }
    
    struct FailableParsingContentMock: DownloadableContent {
        init?(data: Data) {
            return nil
        }
    }

    class NetworkMonitorMock: NetworkMonitor {
        var isReachable: Bool = false
        
        func signalNetworkReachable() async {
            if !isReachable {
                try? await Task.sleep(for: .seconds(0.2))
            } else {
                return
            }
        }
    }
}
