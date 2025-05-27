import Foundation
import Spyable

@Spyable
public protocol DidResolverRepositoryProtocol {
  func fetchDidLog(from url: URL) async throws -> String
}
