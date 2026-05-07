import Foundation
import XCTest

extension AsyncThrowingStream where Failure == Error {

  /// Creates a stream that synchronously yields the provided elements and then finishes.
  ///
  /// Intended for unit tests where you want a deterministic stream with a fixed sequence of events.
  ///
  /// Example:
  /// ```swift
  /// let stream: AsyncThrowingStream<MyEvent, MyError> = .just(.started, .success)
  /// ```
  static func just(_ elements: Element...) -> Self {
    AsyncThrowingStream<Element, Failure> { continuation in
      for element in elements {
        continuation.yield(element)
      }
      continuation.finish()
    }
  }

  /// Creates a stream that immediately terminates by throwing `error`.
  ///
  /// Example:
  /// ```swift
  /// let stream: AsyncThrowingStream<MyEvent, MyError> = .fail(.network)
  /// ```
  static func fail(_ error: Failure) -> Self {
    AsyncThrowingStream<Element, Failure> { continuation in
      continuation.finish(throwing: error)
    }
  }

  /// Creates a stream that synchronously yields the provided elements and then terminates by throwing `error`.
  ///
  /// Example:
  /// ```swift
  /// let stream: AsyncThrowingStream<MyEvent, MyError> =
  ///   .thenFail(.progress(0.2), error: .timeout)
  /// ```
  static func thenFail(_ elements: Element..., error: Failure) -> Self {
    AsyncThrowingStream<Element, Failure> { continuation in
      for element in elements {
        continuation.yield(element)
      }
      continuation.finish(throwing: error)
    }
  }
}

extension AsyncSequence {

  /// Collects all elements from the sequence into an array.
  ///
  /// - Note: If `Self` is an `AsyncThrowingStream`, this will throw if the stream fails.
  @discardableResult
  func collect() async throws -> [Element] {
    var result = [Element]()
    for try await element in self {
      result.append(element)
    }
    return result
  }
}

extension AsyncSequence where Element: Equatable {

  /// Collects all elements and throws if they don't match `expected`.
  ///
  /// This is the “collect all events and fail otherwise” helper.
  @discardableResult
  func collectAndAssertEquals(_ expected: [Element]) async throws -> [Element] {
    let actual = try await collect()
    if actual != expected {
      XCTFail("elements do not match \(actual) != \(expected)")
    }
    return actual
  }
}
