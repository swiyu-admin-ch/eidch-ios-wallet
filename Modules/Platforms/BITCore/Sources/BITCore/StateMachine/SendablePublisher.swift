import Combine
import Foundation

public struct SendablePublisher<Output, Failure: Error>: Publisher {

  // MARK: Lifecycle

  public init(
    fullFill: @Sendable @escaping () async throws -> Output) where Failure == Error
  {
    var task: Task<Void, Never>?
    upstream = Deferred {
      Future { promise in
        task = Task {
          do {
            let result = try await fullFill()
            try Task.checkCancellation()
            promise(.success(result))
          } catch {
            promise(.failure(error))
          }
        }
      }
    }
    .handleEvents(receiveCancel: { task?.cancel() })
    .eraseToAnyPublisher()
  }

  public init(
    timeInterval: TimeInterval,
    fullFill: @Sendable @escaping () async throws -> Output) where Failure == Error
  {
    var task: Task<Void, Never>?
    upstream = Deferred {
      Future { promise in
        task = Task {
          do {
            let delay = UInt64(timeInterval * 1_000_000_000)
            try await Task<Never, Never>.sleep(nanoseconds: delay)

            let result = try await fullFill()
            try Task.checkCancellation()
            promise(.success(result))
          } catch {
            promise(.failure(error))
          }
        }
      }
    }
    .handleEvents(receiveCancel: { task?.cancel() })
    .eraseToAnyPublisher()
  }

  // MARK: Public

  public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    upstream.subscribe(subscriber)
  }

  // MARK: Internal

  let upstream: AnyPublisher<Output, Failure>

}
