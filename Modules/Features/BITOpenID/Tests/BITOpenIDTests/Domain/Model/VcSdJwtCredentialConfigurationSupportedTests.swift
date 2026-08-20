import Foundation
import Testing
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITOpenID
@testable import BITTestingCore

private typealias Config = CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported

// MARK: - VcSdJwtCredentialConfigurationSupportedTests

struct VcSdJwtCredentialConfigurationSupportedTests {

  // MARK: Internal

  @Test
  func decode_success_returnsConfig() throws {
    let data = Config.Mock.sampleData

    let config = try decoder.decode(Config.self, from: data)

    #expect(config.format == CredentialFormat.vcSdJwt)
    #expect(config.scope == "scope")
    #expect(config.cryptographicBindingMethodsSupported == [CredentialIssuerMetadata.CryptographicBindingMethod.jwk])
    #expect(config.credentialSigningAlgValuesSupported == ["ES256"])
    #expect(config.vct == "vct")
    #expect(config.vctIntegrity == "vctIntegrity")
    #expect(config.vctMetadataUri == "vctMetadataUri")
    #expect(config.vctMetadataUriIntegrity == "vctMetadataUriIntegrity")

    #expect(config.protectedIssuanceAuthorizationTrustStatement != nil)

    #expect(config.credentialMetadata?.display != nil)
    #expect(config.proofTypesSupported.count == 1)
    guard case .jwt(let type) = config.proofTypesSupported.first else {
      Issue.record("Expected .jwt")
      return
    }
    #expect(type.supportedAlgorithms == [.ES256])
    #expect(type.keyAttestationRequirements?.keyStorage == [.iso18045EnhancedBasic])

    let metadataDisplay = try #require(config.credentialMetadata?.display)

    #expect(metadataDisplay.count == 2)

    try metadataDisplay.assertDisplay(locale: "de-CH")
    try metadataDisplay.assertDisplay(locale: "en-US")

    let metadataClaims = try #require(config.credentialMetadata?.claims)
    #expect(metadataClaims.count == 2)
    try metadataClaims.assertClaim(index: 1, mandatory: true)
    try metadataClaims.assertClaim(index: 2, mandatory: false)
  }

  @Test
  func decodeMetadataWithoutProofTypes() throws {
    let data = try Config.Mock.sampleData.removeJsonKey(Config.CodingKeys.proofTypesSupported.rawValue)

    let config = try decoder.decode(Config.self, from: data)

    #expect(config.proofTypesSupported.isEmpty)
  }

  @Test
  func decodeMetadataWithUnsupportedProofTypeAlgorithmThrowsError() throws {
    let payload = [Config.CodingKeys.proofTypesSupported.rawValue: [CredentialIssuerMetadata.ProofType.CodingKeys.jwt.rawValue: [CredentialIssuerMetadata.JwtProofType.CodingKeys.supportedAlgorithms.rawValue: ["unknown"]]]]
    let data = try Config.Mock.sampleData.changeJsonPayload(with: payload)

    #expect(
      throws: CredentialIssuerMetadata.AnyCredentialConfigurationSupportedError
        .invalidProofType)
    {
      try JSONDecoder().decode(Config.self, from: data)
    }
  }

  @Test
  func decodeMetadataWithUnsupportedCryptographicBindingMethodThrowsError() throws {
    let payload = [Config.CodingKeys.cryptographicBindingMethodsSupported.rawValue: ["unknown"]]
    let data = try Config.Mock.sampleData.changeJsonPayload(with: payload)

    #expect(
      throws: CredentialIssuerMetadata.AnyCredentialConfigurationSupportedError
        .invalidCryptographicBindingMethod)
    {
      try JSONDecoder().decode(Config.self, from: data)
    }
  }

  @Test
  func decodeUnknownMetadataFormat() throws {
    let payload = [Config.CodingKeys.format.rawValue: ["unknown"]]
    let data = try Config.Mock.sampleData.changeJsonPayload(with: payload)

    #expect { try JSONDecoder().decode(Config.self, from: data) } throws: { error in
      if case DecodingError.typeMismatch = error {
        return true
      }
      return false
    }
  }

  // MARK: Private

  private let decoder = JSONDecoder()
}

extension [CredentialIssuerMetadata.CredentialMetadata.Display] {
  fileprivate func assertDisplay(locale: String) throws {
    let display = try #require(first(where: { $0.locale == locale }))

    #expect(display.name == "name (\(locale))")
    #expect(display.description == "description (\(locale))")
    #expect(display.backgroundColor == "#CCFFCC")
    #expect(display.logo?.url?.dataURLDataString?.base64Decoded == "image (\(locale))")
  }
}

extension [CredentialIssuerMetadata.CredentialMetadata.Claim] {
  fileprivate func assertClaim(index: Int, mandatory: Bool, locales: [String] = ["de-CH", "en-US"]) throws {
    let path = "[\"claim_\(index)\"]"
    let claim = try #require(first(where: { $0.path.stringValue == path }))

    #expect(claim.mandatory == mandatory)

    for locale in locales {
      let display = try #require(claim.display?.first(where: { $0.locale == locale }))
      #expect(display.name == "Claim \(index) (\(locale))")
    }
  }
}
