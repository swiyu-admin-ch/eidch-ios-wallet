import BITCredentialShared
import BITCrypto
import BITJWT
import BITOpenID
import BITSdJWT
import Foundation

// MARK: - MockOpenIDRepository

struct MockOpenIDRepository: OpenIDRepositoryProtocol {
  func fetchVcSchemaData(from url: URL) async throws -> VcSchema {
    TypeMetadata.Mock.vcSchemaData
  }

  func fetchTypeMetadata(from url: URL) async throws -> (TypeMetadata, Data) {
    (TypeMetadata.Mock.sample, TypeMetadata.Mock.sampleData)
  }

  func fetchMetadata(from issuerUrl: URL) async throws -> CredentialMetadata {
    CredentialMetadata.Mock.sample
  }

  func fetchOpenIdConfiguration(from issuerURL: URL) async throws -> OpenIdConfiguration {
    OpenIdConfiguration.Mock.sample
  }

  func fetchIssuerPublicKeyInfo(from jwksUrl: URL) async throws -> PublicKeyInfo {
    PublicKeyInfo.Mock.sample
  }

  func fetchAccessToken(from url: URL, preAuthorizedCode: String) async throws -> AccessToken {
    AccessToken.Mock.sample
  }

  func fetchCredential(from url: URL, credentialRequestBody: CredentialRequestBody, acccessToken: AccessToken) async throws -> CredentialResponse {
    CredentialResponse.Mock.sample
  }

  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList> {
    try TokenStatusList.Mock.credentialStatusSample()
  }

  func fetchRequestObject(from url: URL) async throws -> Data {
    RequestObject.Mock.sampleData
  }

  func fetchTrustStatements(from url: URL, issuerDid: String) async throws -> [TrustStatement] {
    try TrustStatement.Mock.trustStatementValidSample()
  }

}

// MARK: - CredentialMetadata.Mock

extension CredentialMetadata {
  struct Mock {
    static let sample: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-ui-mocks")
  }
}

// MARK: - TypeMetadata.Mock

extension TypeMetadata {
  struct Mock {
    static let sample: TypeMetadata = Mocker.decode(fromFile: "typemetadata-ui-mocks")
    static let sampleData: Data = Mocker.getData(fromFile: "typemetadata-ui-mocks") ?? Data()
    static let vcSchemaData: Data = Mocker.getData(fromFile: "vc-schema-ui-mocks") ?? Data()
  }
}

// MARK: - AccessToken.Mock

extension AccessToken {
  struct Mock {
    static let sample: AccessToken = Mocker.decode(fromFile: "access-token-ui-mocks")
  }
}

// MARK: - CredentialResponse.Mock

extension CredentialResponse {
  struct Mock {
    static let sample: CredentialResponse = Mocker.decode(fromFile: "credential-response-ui-mocks")
  }
}

// MARK: - OpenIdConfiguration.Mock

extension OpenIdConfiguration {
  struct Mock {
    static let sample: OpenIdConfiguration = Mocker.decode(fromFile: "openid-configuration-ui-mocks")
  }
}

// MARK: - PublicKeyInfo.Mock

extension PublicKeyInfo {
  struct Mock {
    static let sample: PublicKeyInfo = Mocker.decode(fromFile: "jwks-ui-mocks")
  }
}

// MARK: - TokenStatusList.Mock

extension TokenStatusList {
  struct Mock {
    static func credentialStatusSample() throws -> JWS<TokenStatusList> {
      Mocker.decodeRawText(fromFile: "jwt-credential-status-ui-mocks")
    }
  }
}

// MARK: - TrustStatement.Mock

extension TrustStatement {
  struct Mock {
    static func trustStatementValidSample() throws -> [TrustStatement] {
      let trustStatementData: Data = Mocker.getData(fromFile: "jwt-trust-statement-valid-ui-mocks", ofType: "txt") ?? Data()
      let trustStatement = try SdJWSDecoder(dateDecodingStrategy: .secondsSince1970).decode(TrustStatementPayload.self, from: trustStatementData)
      return [trustStatement]
    }
  }
}

// MARK: - RequestObject.Mock

extension RequestObject {
  enum Mock {
    static let sample: RequestObject = Mocker.decode(fromFile: "request-object-multipass")
    static let sampleData: Data = Mocker.getData(fromFile: "request-object-multipass") ?? Data()
  }
}

// MARK: - Credential.Mock

extension Credential {
  enum Mock {
    public static let sampleVC: Credential = Mocker.decode(fromFile: "credential-database-sample")
  }
}
