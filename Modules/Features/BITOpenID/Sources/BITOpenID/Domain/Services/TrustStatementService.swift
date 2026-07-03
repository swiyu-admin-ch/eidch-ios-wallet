import BITAnyCredentialFormat
import BITCore
import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - TrustStatementServiceProtocol

@Spyable
public protocol TrustStatementServiceProtocol {
  func fetchIdentity(for subjectDid: String) async throws -> IdentityTrustStatement
  func fetchVcSchema(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async throws -> VcSchemaTrustStatement?
}

// MARK: - TrustStatementServiceError

public enum TrustStatementServiceError: Error {
  case validationFailed
}

// MARK: - TrustStatementService

struct TrustStatementService: TrustStatementServiceProtocol {

  // MARK: Internal

  func fetchIdentity(for subjectDid: String) async throws -> IdentityTrustStatement {
    let trustRegistryURL = try urlMapper.map(did: subjectDid)
    let trustStatements = try await trustStatementRepository.fetchIdentityTrustStatements(from: trustRegistryURL, for: subjectDid)
      .filter { trustStatement in
        trustStatement.payload.vct == Self.trustStatementIdentityVct && isTrustedDid(trustStatement.header.keyIdentifier, for: trustRegistryURL)
      }
    let validTrustStatements = await trustStatements.asyncFilter { trustStatement in
      await trustStatementValidator.validate(trustStatement, for: subjectDid)
    }
    guard validTrustStatements.count == 1, let statement = validTrustStatements.first else { throw TrustStatementServiceError.validationFailed }
    return statement
  }

  func fetchVcSchema(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async throws -> VcSchemaTrustStatement? {
    let trustRegistryURL = try urlMapper.map(did: subjectDid)
    let trustStatements = try await trustStatementRepository.fetchVcSchemaTrustStatements(from: trustRegistryURL, for: subjectDid, type: type, vcSchemaId: vcSchemaId)
      .filter { trustStatement in
        trustStatement.payload.vct == type.vct && isTrustedDid(trustStatement.header.keyIdentifier, for: trustRegistryURL)
      }
    guard !trustStatements.isEmpty else { return nil }
    let validTrustStatements = await trustStatements.asyncFilter { trustStatement in
      await trustStatementValidator.validate(trustStatement, for: subjectDid) &&
        trustStatement.resolvedPayload.vcSchemaId?.absoluteString == vcSchemaId
    }
    guard validTrustStatements.count == 1, let statement = validTrustStatements.first else { throw TrustStatementServiceError.validationFailed }
    return statement
  }

  // MARK: Private

  private static let trustStatementIdentityVct = "TrustStatementIdentityV1"

  @Injected(\.trustRegistryUrlMapper) private var urlMapper
  @Injected(\.trustStatementRepository) private var trustStatementRepository
  @Injected(\.trustRegistryTrustedDidsV1) private var trustedDids: TrustRegistryTrustedDidsV1
  @Injected(\.trustStatementValidator) private var trustStatementValidator
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol

  private func isTrustedDid(_ kid: String?, for url: URL) -> Bool {
    guard let did = try? didResolverHelper.getDid(from: kid) else { return false }
    let baseUrl = url.absoluteString.replacing("https://", with: "")
    return trustedDids[baseUrl]?.contains(did) ?? false
  }
}

extension VcSchemaTrustStatementType {
  var vct: String {
    switch self {
    case .issuance:
      "TrustStatementIssuanceV1"
    case .verification:
      "TrustStatementVerificationV1"
    }
  }
}
