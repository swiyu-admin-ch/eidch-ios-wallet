import BITAnyCredentialFormat
import BITCore
import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - TrustStatementServiceProtocol

@Spyable
public protocol TrustStatementServiceProtocol {
  func fetchMetadata(for subjectDid: String) async throws -> MetadataTrustStatement
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

  func fetchMetadata(for subjectDid: String) async throws -> MetadataTrustStatement {
    let trustStatementURL = try urlMapper.map(did: subjectDid)
    let trustStatements = try await trustStatementRepository.fetchMetadataTrustStatements(from: trustStatementURL, for: subjectDid)
      .filter { trustStatement in
        trustStatement.payload.vct == Self.trustStatementMetadataVct && trustedDids.contains(trustStatement.payload.issuer)
      }
    let validTrustStatements = await trustStatements.asyncFilter { trustStatement in
      await trustStatementValidator.validate(trustStatement, for: subjectDid)
    }
    guard validTrustStatements.count == 1, let statement = validTrustStatements.first else { throw TrustStatementServiceError.validationFailed }
    return statement
  }

  func fetchIdentity(for subjectDid: String) async throws -> IdentityTrustStatement {
    let trustStatementURL = try urlMapper.map(did: subjectDid)
    let trustStatements = try await trustStatementRepository.fetchIdentityTrustStatements(from: trustStatementURL, for: subjectDid)
      .filter { trustStatement in
        trustStatement.payload.vct == Self.trustStatementIdentityVct && trustedDids.contains(trustStatement.payload.issuer)
      }
    let validTrustStatements = await trustStatements.asyncFilter { trustStatement in
      await trustStatementValidator.validate(trustStatement, for: subjectDid)
    }
    guard validTrustStatements.count == 1, let statement = validTrustStatements.first else { throw TrustStatementServiceError.validationFailed }
    return statement
  }

  func fetchVcSchema(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async throws -> VcSchemaTrustStatement? {
    let trustStatementURL = try urlMapper.map(did: subjectDid)
    let trustStatements = try await trustStatementRepository.fetchVcSchemaTrustStatements(from: trustStatementURL, for: subjectDid, type: type, vcSchemaId: vcSchemaId)
      .filter { trustStatement in
        trustStatement.payload.vct == type.vct && trustedDids.contains(trustStatement.payload.issuer)
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

  private static let trustStatementMetadataVct = "TrustStatementMetadataV1"
  private static let trustStatementIdentityVct = "TrustStatementIdentityV1"

  @Injected(\.trustStatementUrlMapper) private var urlMapper
  @Injected(\.trustStatementRepository) private var trustStatementRepository
  @Injected(\.trustRegistryTrustedDids) private var trustedDids: [String]
  @Injected(\.trustStatementValidator) private var trustStatementValidator
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
