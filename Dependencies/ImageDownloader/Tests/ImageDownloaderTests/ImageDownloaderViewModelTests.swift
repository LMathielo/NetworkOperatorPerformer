import XCTest
import Networking
@testable import ImageDownloader

final class ImageDownloaderTests: XCTestCase {
    
    var networkServiceMock: ImageDownloaderServiceMock!
    
    var sut: ImageDownloader.View.ViewModel!
    
    override func setUp() {
        networkServiceMock = ImageDownloaderServiceMock()
        
        sut = ImageDownloader.View.ViewModel(
            networkService: networkServiceMock
        )
    }
    
    func test_startDownloadingImage_getsLoadingState() async throws {
        sut.startDownloadingImage()
        
        let task = Task {
            sut.startDownloadingImage()
            try await Task.sleep(for: .seconds(1)) // bad! smell!
        }
        
        try await task.value
        
        XCTAssertTrue(networkServiceMock.didCallDownloadImage)
        XCTAssert(sut.downloadStatus == .loading)
    }
    
    func test_startDownloadingImage_getsDelayedState() async throws {
        
        XCTAssert(sut.downloadStatus == .initial)
        print(sut.downloadStatus)
        networkServiceMock.delaySeconds = 5
        
        let task = Task {
            sut.startDownloadingImage()
            try await Task.sleep(for: .seconds(3)) // bad! smell!
        }
        try await task.value
        
        XCTAssert(sut.downloadStatus == .delayed)
    }
    
    func test_startDownloadingImage_getsSuccessWithImage() async throws {
        
        XCTAssert(sut.downloadStatus == .initial)
        
        let mockImage = UIImage()
        networkServiceMock.result = .success(mockImage)
        
        let task = Task {
            sut.startDownloadingImage()
            try await Task.sleep(for: .seconds(1)) // bad! smell!
        }
        
        try await task.value
        
        guard case let .completed(image) = sut.downloadStatus else {
            return XCTFail("request failed")
        }
        
        XCTAssert(image == mockImage)
    }
    
    func test_startDownloadingImage_getsFailureNetworkError() async throws {
        networkServiceMock.result = .failure(.timeout)
        
        let task = Task {
            sut.startDownloadingImage()
            try await Task.sleep(for: .seconds(1)) // bad! smell!
        }
        try await task.value
        
        guard case let .error(error) = sut.downloadStatus else {
            return XCTFail("request failed")
        }
        
        XCTAssert(error == "The network could not be fetched. Reason: timeout")
    }
    
    func test_setInitialState_setsInitialState() async throws {
        let task = Task {
            sut.startDownloadingImage()
            try await Task.sleep(for: .seconds(1)) // bad! smell!
        }
        try await task.value
        
        XCTAssert(sut.downloadStatus == .loading)
        sut.setInitialState()
        XCTAssert(sut.downloadStatus == .initial)
    }
    
    
    //can't really test
    func test_cancelCurrentTask_setsInitialState() async throws {
        let task = Task {
            sut.startDownloadingImage()
            sut.cancelDownloadTask()
            try await Task.sleep(for: .seconds(1)) // bad! smell!
        }
        try await task.value
        
        XCTAssert(sut.downloadStatus == .initial)
    }
    
}

extension ImageDownloaderTests {
    class ImageDownloaderServiceMock: ImageDownloader.Service {
        
        var didCallDownloadImage: Bool = false
        
        var delaySeconds = 0
        var result: Result<UIImage, Networking.NetworkError>? = nil
        
        func downloadImage(with url: String) async -> Result<UIImage, Networking.NetworkError>? {
            didCallDownloadImage = true
            try? await Task.sleep(for: .seconds(delaySeconds))
            return result
        }
    }
}
