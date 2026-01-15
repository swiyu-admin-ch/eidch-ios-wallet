import BITAnyCredentialFormat
import BITCredentialShared
import BITCrypto
import BITJWT
import BITNetworking
import BITOpenID
import BITSdJWT
import Foundation

// MARK: - MockOpenIDRepository

struct MockOpenIDRepository: OpenIDRepositoryProtocol {

  func fetchVcSchemaData(from url: URL) async throws -> VcSchema {
    TypeMetadata.Mock.vcSchemaData
  }

  func fetchTypeMetadata(from url: URL) async throws -> NetworkResponse<TypeMetadata> {
    NetworkResponse(object: TypeMetadata.Mock.sample, data: TypeMetadata.Mock.sampleData)
  }

  func fetchMetadata(from issuerUrl: URL) async throws -> CredentialMetadataResponse {
    CredentialMetadataResponse(metadata: CredentialMetadata.Mock.sample, raw: CredentialMetadata.Mock.sampleData)
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

  func fetchNonce(from url: URL) async throws -> Nonce {
    Nonce.Mock.sample
  }

  func fetchCredential(with context: FetchCredentialContext, credentialRequest: CredentialRequest) async throws -> FetchAnyCredentialResult {
    try .credential(VcSdJWS.Mock.validSample())
  }

  func fetchCredential(from url: URL, transactionId: String, accessToken: String, format: String) async throws -> FetchAnyCredentialResult {
    try .credential(VcSdJWS.Mock.validSample())
  }

  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList> {
    try TokenStatusList.Mock.credentialStatusSample()
  }

}

// MARK: - CredentialMetadata.Mock

extension CredentialMetadata {
  struct Mock {
    static let sample: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-ui-mocks")
    static let sampleData: Data = Mocker.getData(fromFile: "credential-metadata-ui-mocks") ?? Data()
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

// MARK: - Nonce.Mock

extension Nonce {
  struct Mock {
    static let sample = Nonce(cNonce: "502b8c3c-5343-4e13-8a72-963fc53d2ea1")
  }
}

// MARK: - VcSdJWS.Mock

extension VcSdJWS {
  struct Mock {
    static func validSample() throws -> VcSdJWS {
      let data = Mocker.getData(fromFile: "vc-sd-jwt-credential-ui-mocks", ofType: "txt") ?? Data()
      return try SdJWSDecoder().decode(VcSdJwt.self, from: data)
    }
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

// MARK: - VerifiableCredential.Mock

extension VerifiableCredential {
  enum Mock {
    static let sampleVC: VerifiableCredential = Mocker.decode(fromFile: "credential-database-sample")
  }
}
