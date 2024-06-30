# NetworkOperatorPerformer
Given the Code Snippet in [Coding Exercise](https://github.com/user-attachments/files/16045744/Coding.Exercise.pdf),<br />
Some problems can be perceived with the provided approach:

### 1 - Scalability Issues with NotificationCenter:
- NotificationCenter operates as a global app-level event handler, making it challenging to manage as the app grows. It becomes difficult to track which components are triggering notifications and which are consuming them, especially with multiple running instances of the `NetworkPerformer`.

- As the app scales and multiple instances of NetworkPerformerOperator are created, many notifications will be observed and triggered. Since they all observe the same notification post, notifications can interfere with different `NetworkPerformer` contexts, leading to unexpected behaviors.

### 2 - Inefficient Monitoring:
- The monitoring process continues until a timeout occurs, even if the closure is called. This can result in the closure method being called multiple times accidentally, potentially causing unexpected behaviors like triggering multiple download calls, wasting processing and network resources.

### 3 - Issues with Timer:
- Using a `Timer` can be problematic as it may not function correctly on background threads. While running in the main thread, the `Timer` can be blocked by user interactions, as user events take priority and can lock the main thread. It can also indefinitely hold strong references to the run loops in memory, potentially re-triggering the run loops if its lifecycle is not managed properly.

### 4 - Lack of Dependency Injection:
- The code functions as a black box. It holds concrete object dependencies without providing proper injection mechanisms. This makes it difficult to manipulate dependencies for testing various scenarios.

# Solution:
The solution project was divided in three main modules:

### 1 - Networking
The `NetworkPerformerOperator` and `NetworkMonitor` were refactored to run asynchronously under structured concurrency.

- `NetworkMonitor`: Listens to `NWPath` changes and broadcasts through an `AsyncStream`, which is observed by the `NetworkPerformerOperator`. When the first `.satisfied` status is received, it signals to release the `await` observation and start the download process. <br />
It has a one-to-one relationship with the `NetworkPerformerOperator`. We can scale the solution to run many Performers-Monitors concurrently, and they will not interact with each other.

- `NetworkPerformerOperator`: Serves as the `Networking` interface entry point, providing fetched responses as an abstract `Result<Success, Failure>`. 
It mainly operates dispatching two concurrent Tasks`:

- - `NetworkMonitor` listener `Task`:
Waits for a satisfied status from the monitor and, if satisfied, proceeds with the download, returning `.success()` if successful.

- - Timeout `Task`: 
Monitors for a timeout and returns a timeout `.failure() if the deadline is reached.

**The first task to complete determines the Result response, canceling the remaining task and finalizing the concurrent code execution.**

**Testing:** 
- It also holds an abstract interface of NetworkMonitor, facilitating easy injection of mocks for unit testing.
- Unit Tests are included in the project!

### 2. ImageDownloader
- This module acts as the downloader feature in the app. It is completely decoupled from the mainApp and exposes only the entry point to the module.
It can run independently and it was made app-agnostic to be consumed across different apps.
It follows the MVVM pattern, where the View reacts to changes in the ViewModel status.
In the ViewModel, two main dependencies are present:

- - `Service` Layer: 
Acts as the communication layer with Networking, providing the concrete types that will be fetched by NetworkPerformerOperator, and propagates the Result<Success, Error> to the ViewModel.

- - `TaskManager`: 
Responsible to hold the instance of the associated download `Task` and controls the lifecyle of the `Task`, including cancelation, if provided by the user.
It maintains a one-to-one relashionship with the running `Task`, and does not permit overrides with a new `Task` instance if the active task has not finished.

**Testing:**
- The `ViewModel` is throgouly tested, by also providing abstract interfaces of `Service` and `TaskManager`.
- The lifecycle of the Task is tested by the `TaskManager`.
- Unit Tests were also included here!

### 3. CommonUI
- This module decouples all UI components from the mainApp and other modules, making them highly reusable.
- In the same fashion, it operates independently from the mainApp and is meant to be app-agnostic.
- It uses Design System Tokens to provide dynamic style to the components, allowing the style to be manipulated across different apps styles.
