import BITCredentialShared
import Foundation
import Spyable

@Spyable
public protocol CheckAndUpdateCredentialStatusUseCaseProtocol {
  @discardableResult
  func execute(_ credentials: [VerifiableCredential]) async throws -> [VerifiableCredential]
  func execute(for credential: VerifiableCredential) async throws -> VerifiableCredential
}
