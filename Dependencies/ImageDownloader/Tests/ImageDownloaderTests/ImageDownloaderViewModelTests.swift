import XCTest
import Networking
@testable import ImageDownloader

final class ImageDownloaderTests: XCTestCase {
    var networkServiceMock: ImageDownloaderServiceMock!
    var taskManagerMock: TaskManagerMock!
    
    var sut: ImageDownloader.View.ViewModel!
    
    override func setUp() async throws {
        networkServiceMock = ImageDownloaderServiceMock()
        taskManagerMock = TaskManagerMock()
        
        sut = await ImageDownloader.View.ViewModel(
            networkService: networkServiceMock,
            taskManager: taskManagerMock
        )
    }
    
    func test_startDownloadingImage_getsLoadingState() async throws {
        // Given
        var status = await sut.downloadStatus
        XCTAssertEqual(status, .initial)
        
        // When
        await sut.startDownloadingImage()
        
        // Then
        status = await sut.downloadStatus
        XCTAssertTrue(taskManagerMock.startCalled)
        XCTAssertEqual(status, .loading)
    }
    
    func test_startDownloadingImage_getsDelayedState() async throws {
        // Given
        var status = await sut.downloadStatus
        XCTAssert(status == .initial)
        networkServiceMock.delaySeconds = 5
        
        // When
        await sut.startDownloadingImage()
        await taskManagerMock.awaitTaskCompletion()
        
        // Then
        status = await sut.downloadStatus
        XCTAssertTrue(taskManagerMock.startCalled)
        XCTAssert(status == .delayed)
    }
    
    func test_startDownloadingImage_getsSuccessWithImage() async throws {
        // Given
        let status = await sut.downloadStatus
        XCTAssert(status == .initial)
        let mockImage = UIImage()
        networkServiceMock.result = .success(mockImage)
        
        // When
        await sut.startDownloadingImage()
        await taskManagerMock.awaitTaskCompletion()
        
        // Then
        guard case let .completed(image) = await sut.downloadStatus else {
            return XCTFail("request failed")
        }
        
        XCTAssertTrue(taskManagerMock.startCalled)
        XCTAssert(image == mockImage)
    }
    
    func test_startDownloadingImage_getsFailureNetworkError() async throws {
        // Given
        networkServiceMock.result = .failure(.timeout)
        
        // When
        await sut.startDownloadingImage()
        await taskManagerMock.awaitTaskCompletion()
        
        // Then
        guard case let .error(error) = await sut.downloadStatus else {
            return XCTFail("request failed")
        }
        
        XCTAssertTrue(taskManagerMock.startCalled)
        XCTAssert(error == "The network could not be fetched. Reason: timeout")
    }
    
    func test_setInitialState_setsInitialState() async throws {
        // Given
        await sut.startDownloadingImage()
        var status = await sut.downloadStatus
        XCTAssert(status == .loading)
        
        // When
        await sut.setInitialState()
        
        // Then
        status = await sut.downloadStatus
        XCTAssert(status == .initial)
    }
    
    
    func test_cancelDownloadTask_setsInitialState() async throws {
        // Given
        await sut.startDownloadingImage()
        
        // When
        await sut.cancelDownloadTask()
        
        // Then
        let status = await sut.downloadStatus
        XCTAssert(status == .initial)
        XCTAssertTrue(taskManagerMock.startCalled)
        XCTAssertTrue(taskManagerMock.cancelCalled)
    }
    
}

// MARK: Mocks
extension ImageDownloaderTests {
    class TaskManagerMock: TaskManagerImpl {
        var startCalled = false
        var cancelCalled = false
        
        func awaitTaskCompletion() async {
            await runningTask?.value
        }
        
        override func start(_ task: @escaping () async -> Void) throws {
            startCalled = true
            try super.start(task)
        }
        
        override func cancelCurrentTask() {
            cancelCalled = true
            super.cancelCurrentTask()
        }
    }
    
    class ImageDownloaderServiceMock: ImageDownloader.Service {
        var didCallDownloadImage: Bool = false
        var delaySeconds = 1
        var result: Result<UIImage, Networking.NetworkError>? = nil
        
        func downloadImage(with url: String) async -> Result<UIImage, Networking.NetworkError>? {
            didCallDownloadImage = true
            try? await Task.sleep(for: .seconds(delaySeconds))
            return result
        }
    }
}
