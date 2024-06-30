//
//  TaskManagerTests.swift
//  
//
//  Created by Lucas Mathielo on 30/06/24.
//

import XCTest
@testable import ImageDownloader

final class TaskManagerTests: XCTestCase {
    var sut: TaskManagerImpl!
    
    override func setUp() {
        sut = TaskManagerImpl()
    }
    
    func test_start_holdsTaskReference() async throws {
        // Given
        XCTAssertEqual(sut.runningTask, nil)
        
        // When
        try sut.start({ try? await Task.sleep(for: .seconds(1)) })
        
        // Then
        XCTAssertNotNil(sut.runningTask)
    }
    
    func test_start_withRunningTask_throwsException() async throws {
        // Given
        sut.runningTask = Task { try? await Task.sleep(for: .seconds(1)) }
        
        // When
        do {
            try sut.start({ try? await Task.sleep(for: .seconds(1)) })
            XCTFail("can't have more than 1 task running per manager!")
        } catch {
            // Then
            XCTAssertEqual(error as? TaskManagerError, TaskManagerError.alreadyRunning)
        }
    }
    
    func test_start_releasesTaskReferenceUponCompetion() async throws {
        // Given
        XCTAssertEqual(sut.runningTask, nil)
        
        // When
        try sut.start({ try? await Task.sleep(for: .seconds(0.5)) })
        try await Task.sleep(for: .seconds(1))
        
        // Then
        XCTAssertNil(sut.runningTask)
    }
    
    func test_cancel_cancelsTaskAndRemoveReference() async throws {
        // Given
        let task = Task { }
        sut.runningTask = task
        
        // When
        sut.cancelCurrentTask()
        
       // Then
        XCTAssertTrue(task.isCancelled)
        XCTAssertNil(sut.runningTask)
    }
}
