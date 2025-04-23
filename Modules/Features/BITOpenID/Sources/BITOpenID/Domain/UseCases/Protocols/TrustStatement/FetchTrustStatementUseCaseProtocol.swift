import BITAnyCredentialFormat
import Spyable

@Spyable
public protocol FetchTrustStatementUseCaseProtocol {
  func execute(issuer: String) async throws -> TrustStatement?
}
