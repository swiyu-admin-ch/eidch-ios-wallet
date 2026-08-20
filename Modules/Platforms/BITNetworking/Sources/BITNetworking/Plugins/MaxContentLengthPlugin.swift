import Factory
import Foundation
import Moya

// MARK: - MaxContentLengthPlugin

public struct MaxContentLengthPlugin: PluginType {

  // MARK: Lifecycle

  public init(
    maxResponseSize: Int = 25 * 1024 * 1024 // 25MB
  ) {
    self.maxResponseSize = maxResponseSize
  }

  // MARK: Public

  public func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
    if case .success(let response) = result {
      let length = response.contentLength ?? response.data.count
      guard length < maxResponseSize else {
        logger.error("Stopped processing request because payload was too large. (size: \(length) bytes, allowed: \(maxResponseSize) bytes)")
        let error = NetworkError(status: .payloadTooLarge, response: response)
        return .failure(.underlying(error, response))
      }
    }
    return result
  }

  // MARK: Private

  private let maxResponseSize: Int
  @Injected(\NetworkContainer.logger) private var logger
}

extension Response {
  fileprivate var contentLength: Int? {
    if let contentLength = response?.headers.value(for: "Content-Length") {
      Int(contentLength)
    } else {
      nil
    }
  }
}
