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

  func fetchCredential(with context: FetchCredentialContext, credentialRequestBody: VcSdJwtCredentialRequestBody) async throws -> FetchAnyCredentialResult {
    try .credential(VcSdJwtPayload.Mock.validSample())
  }

  func fetchCredentialStatus(from url: URL) async throws -> JWS<TokenStatusList> {
    try TokenStatusList.Mock.credentialStatusSample()
  }

  func refreshDeferredCredential(from url: URL, transactionId: String, acccessToken: String, format: String) async throws -> any AnyCredential {
    try VcSdJwtPayload.Mock.validSample()
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

// MARK: - VcSdJwtPayload.Mock

extension VcSdJwtPayload {
  struct Mock {
    static func validSample() throws -> VcSdJwt {
      let data = Mocker.getData(fromFile: "vc-sd-jwt-credential-ui-mocks", ofType: "txt") ?? Data()
      return try SdJWSDecoder(dateDecodingStrategy: .secondsSince1970).decode(VcSdJwtPayload.self, from: data)
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
