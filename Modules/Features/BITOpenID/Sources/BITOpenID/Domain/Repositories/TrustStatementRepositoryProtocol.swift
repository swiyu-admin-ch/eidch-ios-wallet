import BITCrypto
import BITJWT
import BITNetworking
import Foundation
import Spyable

@Spyable
public protocol TrustStatementRepositoryProtocol {
  func fetchIdentityTrustStatements(from url: URL, for subjectDid: String) async throws -> [IdentityTrustStatement]
  func fetchVcSchemaTrustStatements(from url: URL, for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async throws -> [VcSchemaTrustStatement]
}
