import Foundation
import Spyable

@Spyable
public protocol DidResolverRepositoryProtocol: Sendable {
  func fetchDidLog(from url: URL) async throws -> String
}
