import BITOpenID
import BITSdJWT
import Foundation

// MARK: - MockTrustStatementRepository

struct MockTrustStatementRepository: TrustStatementRepositoryProtocol {

  func fetchMetadataTrustStatements(from url: URL, for subjectDid: String) async throws -> [MetadataTrustStatement] {
    try MetadataTrustStatementPayload.Mock.validSample()
  }

  func fetchIdentityTrustStatements(from url: URL, for subjectDid: String) async throws -> [IdentityTrustStatement] {
    try IdentityTrustStatementPayload.Mock.validSample()
  }

  func fetchVcSchemaTrustStatements(from url: URL, for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async throws -> [VcSchemaTrustStatement] {
    try VcSchemaTrustStatementPayload.Mock.validSample()
  }
}

// MARK: - IdentityTrustStatementPayload.Mock

extension IdentityTrustStatementPayload {
  struct Mock {
    static func validSample() throws -> [IdentityTrustStatement] {
      let trustStatementData: Data = Mocker.getData(fromFile: "identity-trust-statement-ui-mocks", ofType: "txt") ?? Data()
      let trustStatement = try SdJWSDecoder(dateDecodingStrategy: .secondsSince1970).decode(IdentityTrustStatementPayload.self, from: trustStatementData)
      return [trustStatement]
    }
  }
}

// MARK: - MetadataTrustStatementPayload.Mock

extension MetadataTrustStatementPayload {
  struct Mock {
    static func validSample() throws -> [MetadataTrustStatement] {
      let trustStatementData: Data = Mocker.getData(fromFile: "metadata-trust-statement-ui-mocks", ofType: "txt") ?? Data()
      let trustStatement = try SdJWSDecoder(dateDecodingStrategy: .secondsSince1970).decode(MetadataTrustStatementPayload.self, from: trustStatementData)
      return [trustStatement]
    }
  }
}

// MARK: - VcSchemaTrustStatementPayload.Mock

extension VcSchemaTrustStatementPayload {
  struct Mock {
    static func validSample() throws -> [VcSchemaTrustStatement] {
      let trustStatementData: Data = Mocker.getData(fromFile: "vc-schema-trust-statement-ui-mocks", ofType: "txt") ?? Data()
      let trustStatement = try SdJWSDecoder(dateDecodingStrategy: .secondsSince1970).decode(VcSchemaTrustStatementPayload.self, from: trustStatementData)
      return [trustStatement]
    }
  }
}
