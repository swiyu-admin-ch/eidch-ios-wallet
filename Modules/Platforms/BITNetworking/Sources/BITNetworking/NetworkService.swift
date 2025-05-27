import Alamofire
import Factory
import Foundation
import Moya

public struct NetworkService {

  // MARK: Public

  public func request<D>(_ target: some TargetType, decoder: JSONDecoder = NetworkContainer.shared.decoder()) async throws -> (D) where D: Decodable {
    try await withCheckedThrowingContinuation({ continuation in
      fetch(target) { result in
        switch result {
        case .success(let response):
          do {
            let decodedObject = try decoder.decode(D.self, from: response.data)
            continuation.resume(returning: decodedObject)
          } catch {
            continuation.resume(throwing: error)
          }
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    })
  }

  public func request<D>(_ target: some TargetType, decoder: JSONDecoder = NetworkContainer.shared.decoder()) async throws -> (D, Response) where D: Decodable {
    try await withCheckedThrowingContinuation({ continuation in
      fetch(target) { result in
        switch result {
        case .success(let response):
          do {
            let decodedObject = try decoder.decode(D.self, from: response.data)
            continuation.resume(returning: (decodedObject, response))
          } catch {
            continuation.resume(throwing: error)
          }
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    })
  }

  @discardableResult
  public func request(_ target: some TargetType) async throws -> Response {
    try await withCheckedThrowingContinuation({ continuation in
      fetch(target) { result in
        switch result {
        case .success(let response):
          continuation.resume(returning: response)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    })
  }

  // MARK: Private

  private func makeProvider<T>(_ target: T) -> MoyaProvider<T> where T: TargetType {
    if NetworkContainer.shared.endpointClosure() != nil {
      let endpointClosure = { (target: T) -> Endpoint in
        Endpoint(
          url: URL(target: target).absoluteString,
          sampleResponseClosure: ({ () -> EndpointSampleResponse in NetworkContainer.shared.endpointClosure() ?? .response(HTTPURLResponse(), target.sampleData) }),
          method: target.method,
          task: target.task,
          httpHeaderFields: target.headers)
      }
      return MoyaProvider<T>(
        endpointClosure: endpointClosure,
        stubClosure: NetworkContainer.shared.stubClosure(),
        session: NetworkContainer.shared.session(),
        plugins: NetworkContainer.shared.plugins())
    }
    return MoyaProvider<T>(
      stubClosure: NetworkContainer.shared.stubClosure(),
      session: NetworkContainer.shared.session(),
      plugins: NetworkContainer.shared.plugins())
  }

  private func fetch(_ target: some TargetType, _ completion: @escaping (Result<Response, Error>) -> Void) {
    let provider = makeProvider(target)

    provider.request(target) { result in
      switch result {
      case .success(let response):
        guard response.isSuccessful else { return completion(.failure(NetworkError(response: response))) }
        return completion(.success(response))
      case .failure(let error):
        guard let networkError = NetworkError(moyaError: error) else { return completion(.failure(error)) }
        return completion(.failure(networkError))
      }
    }
  }

}
