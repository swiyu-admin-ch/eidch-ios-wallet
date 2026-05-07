import Alamofire
import BITAnalytics
import Factory
import Foundation
import Moya

public typealias ProgressHandler = ProgressBlock

// MARK: - NetworkService

public struct NetworkService {

  // MARK: Public

  public func request<D: Decodable>(
    _ target: some TargetType,
    decoder: JSONDecoder = NetworkContainer.shared.decoder(),
    plugins: [PluginType] = [],
    _ progress: ProgressBlock? = nil) async throws
    -> (D)
  {
    let response = try await fetch(target, plugins: plugins, progress: progress)
    return try decoder.decode(D.self, from: response.data)
  }

  @discardableResult
  public func request<D: Decodable>(
    _ target: some TargetType,
    decoder: JSONDecoder = NetworkContainer.shared.decoder(),
    plugins: [PluginType] = [],
    _ progress: ProgressBlock? = nil) async throws
    -> (D, Response)
  {
    let response = try await fetch(target, plugins: plugins, progress: progress)
    let decodedObject = try decoder.decode(D.self, from: response.data)
    return (decodedObject, response)
  }

  @discardableResult
  public func request(
    _ target: some TargetType,
    plugins: [PluginType] = [],
    _ progress: ProgressBlock? = nil) async throws
    -> Response
  {
    try await fetch(target, plugins: plugins, progress: progress)
  }

  // MARK: Private

  private func makeProvider<T: TargetType>(_ target: T, plugins: [PluginType] = []) -> MoyaProvider<T> {
    var registeredPlugins = NetworkContainer.shared.plugins()
    registeredPlugins.append(contentsOf: plugins)

    let timeout = target.defaultTimeoutInterval
    let session = NetworkContainer.shared.session(timeout: timeout)

    if NetworkContainer.shared.endpointByTargetClosure() != nil || NetworkContainer.shared.endpointClosure() != nil {
      let endpointClosure = { (target: T) -> Endpoint in
        Endpoint(
          url: URL(target: target).absoluteString,
          sampleResponseClosure: ({ () -> EndpointSampleResponse in
            NetworkContainer.shared.endpointByTargetClosure()?(target) ??
              NetworkContainer.shared.endpointClosure() ??
              .response(HTTPURLResponse(), target.sampleData)
          }),
          method: target.method,
          task: target.task,
          httpHeaderFields: target.headers)
      }
      return MoyaProvider<T>(
        endpointClosure: endpointClosure,
        stubClosure: NetworkContainer.shared.stubClosure(),
        session: session,
        plugins: registeredPlugins)
    }
    return MoyaProvider<T>(
      stubClosure: NetworkContainer.shared.stubClosure(),
      session: session,
      plugins: registeredPlugins)
  }

  private func fetch(_ target: some TargetType, plugins: [PluginType], progress: ProgressBlock? = nil) async throws -> Response {
    let provider = makeProvider(target, plugins: plugins)
    return try await provider.request(target, progress: progress)
  }
}

extension MoyaProvider {
  fileprivate func request(_ target: Target, progress: ProgressBlock? = nil) async throws -> Response {
    try await withCheckedThrowingContinuation { continuation in
      request(target, progress: progress) { result in
        switch result {
        case .success(let response):
          guard response.isSuccessful else {
            return continuation.resume(throwing: NetworkError(response: response))
          }
          return continuation.resume(returning: response)
        case .failure(let error):
          guard let networkError = NetworkError(moyaError: error) else { return continuation.resume(throwing: error) }
          return continuation.resume(throwing: networkError)
        }
      }
    }
  }
}
