import Foundation
import Spyable

// MARK: - URLSessionProtocol

@Spyable
public protocol URLSessionProtocol {
  func data(from url: URL) async throws -> (Data, URLResponse)
}

// MARK: - URLSession + URLSessionProtocol

/// Extends `URLSession` to conform to the managed `URLSessionProtocol`
/// in order to enable dependency injection and facilitate unit testing.
extension URLSession: URLSessionProtocol {
  public func data(from url: URL) async throws -> (Data, URLResponse) {
    try await data(from: url, delegate: nil)
  }
}
