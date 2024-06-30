//
//  TaskManager.swift
//
//
//  Created by Lucas Mathielo on 30/06/24.
//

import Foundation

protocol TaskManager {
    /// Starts an async `Task` and holds its reference until the tasks finishes`.
    ///
    /// The `TaskManager` has a one-to-one relationship with the current running `Task`. Attempting to start another Task while having a current assigned task will result in an `.alreadyRunningTask` error being throw.
    ///
    func start(_ task: @escaping () async -> Void) throws
    func cancelCurrentTask()
}

enum TaskManagerError: Error {
    case alreadyRunningTask
}

class TaskManagerImpl: TaskManager {
    var runningTask: Task<(), Never>?
    
    func start(_ task: @escaping () async -> Void) throws {
        if let _ = self.runningTask {
            throw TaskManagerError.alreadyRunningTask
        }
        
        let runningTask = Task {
            await task()
            self.runningTask = nil
        }
        
        self.runningTask = runningTask
    }
    
    func cancelCurrentTask() {
        self.runningTask?.cancel()
        self.runningTask = nil
    }
}
