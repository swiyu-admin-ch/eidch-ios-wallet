import BITNetworking
import Factory
import Foundation
import Moya
import Spyable

// MARK: - OCARepositoryProtocol

@Spyable
public protocol OCARepositoryProtocol {
  func fetchOCABundle(from url: URL) async throws -> RawOcaBundle
}

// MARK: - OCARepository

struct OCARepository: OCARepositoryProtocol {

  func fetchOCABundle(from url: URL) async throws -> RawOcaBundle {
    try await networkService.request(OCAEndpoint.bundle(url: url)).data
  }

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
}
