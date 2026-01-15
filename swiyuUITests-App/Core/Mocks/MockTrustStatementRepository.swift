import BITOpenID
import BITSdJWT
import Foundation

// MARK: - MockTrustStatementRepository

struct MockTrustStatementRepository: TrustStatementRepositoryProtocol {

  func fetchIdentityTrustStatements(from url: URL, for subjectDid: String) async throws -> [IdentityTrustStatement] {
    try IdentityTrustStatementJWT.Mock.validSample()
  }

  func fetchVcSchemaTrustStatements(from url: URL, for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async throws -> [VcSchemaTrustStatement] {
    try VcSchemaTrustStatementJWT.Mock.validSample()
  }
}

// MARK: - IdentityTrustStatementJWT.Mock

extension IdentityTrustStatementJWT {
  struct Mock {
    static func validSample() throws -> [IdentityTrustStatement] {
      let trustStatementData: Data = Mocker.getData(fromFile: "identity-trust-statement-ui-mocks", ofType: "txt") ?? Data()
      let trustStatement = try SdJWSDecoder(dateDecodingStrategy: .secondsSince1970).decode(IdentityTrustStatementJWT.self, from: trustStatementData)
      return [trustStatement]
    }
  }
}

// MARK: - VcSchemaTrustStatementJWT.Mock

extension VcSchemaTrustStatementJWT {
  struct Mock {
    static func validSample() throws -> [VcSchemaTrustStatement] {
      let trustStatementData: Data = Mocker.getData(fromFile: "vc-schema-trust-statement-ui-mocks", ofType: "txt") ?? Data()
      let trustStatement = try SdJWSDecoder(dateDecodingStrategy: .secondsSince1970).decode(VcSchemaTrustStatementJWT.self, from: trustStatementData)
      return [trustStatement]
    }
  }
}
