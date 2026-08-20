import BITSwiyuSharedKMP
import Foundation
import Testing
@testable import BITCore
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - RequestObjectTests

struct RequestObjectTests {

  // MARK: Internal

  struct ValidationCase: Sendable {
    let data: Data
    let expected: RequestObjectError
  }

  @Test
  func decodingRequestObject() throws {
    let data = RequestObjectJWS.Mock.sampleData

    let requestObject = try decoder.decode(RequestObject.self, from: data)

    #expect(requestObject.dcqlQuery.credentials?.count == 1)
    #expect(requestObject.identityTrustStatement != nil)
    #expect(requestObject.identityTrustStatement?.payload.entityNames.getAllDisplays().count == 3)
    #expect(requestObject.verificationQueryPublicStatement != nil)
    #expect(requestObject.scope == "com.example.credential_presentation")
    #expect(requestObject.protectedVerificationAuthorizationTrustStatement == nil)
  }

  @Test
  func decodingRequestObjectWithoutVerifiedQuery() throws {
    let data = RequestObjectJWS.Mock.sampleWithoutVerifiedQueryData

    let requestObject = try decoder.decode(RequestObject.self, from: data)

    #expect(requestObject.dcqlQuery.credentials?.count == 1)
    #expect(requestObject.responseUri != nil)
    #expect(requestObject.clientMetadata != nil)
    #expect(requestObject.clientMetadata?.clientName != nil)
    #expect(requestObject.clientMetadata?.logoUri != nil)
  }

  @Test
  func decodingRequestObjectWithProtectedClaims() throws {
    let data = RequestObjectJWS.Mock.sampleWithProtectedClaimsData

    let requestObject = try decoder.decode(RequestObject.self, from: data)

    #expect(requestObject.protectedVerificationAuthorizationTrustStatement != nil)
  }

  @Test
  func decodingVcSdJwtRequestObjectWithUnsupportedClientMetadata() throws {
    let data = RequestObjectJWS.Mock.unsupportedClientMetadata
    let requestObject = try decoder.decode(RequestObject.self, from: data)

    #expect(requestObject.dcqlQuery.credentials?.count == 1)
    #expect(requestObject.responseUri != nil)
    #expect(requestObject.clientMetadata != nil)
    #expect(requestObject.clientMetadata?.clientName == nil)
    #expect(requestObject.clientMetadata?.logoUri == nil)
  }

  @Test
  func decodingRequestObjectWithoutClientMetadata() throws {
    let data = RequestObjectJWS.Mock.withoutClientMetadataData
    let requestObject = try decoder.decode(RequestObject.self, from: data)

    #expect(requestObject.dcqlQuery.credentials?.count == 1)
    #expect(requestObject.responseUri != nil)
    #expect(requestObject.clientMetadata == nil)
  }

  @Test(arguments: [
    RequestObjectJWS.Mock.clientIdNotADidData,
    RequestObjectJWS.Mock.unsupportedClientIdData,
  ])
  func decodingRequestObjectWithInvalidClientId_throws(data: Data) {
    #expect(throws: ClientIdentifierError.invalidClientId) {
      _ = try decoder.decode(RequestObject.self, from: data)
    }
  }

  @Test
  func getPreferredDisplay_multipleLanguages_returnsFirstValidLanguage() {
    let requestObject = RequestObjectJWS.Mock.sample.payload
    let languages: [UserLanguageCode] = ["cz", "de", "en"]

    let clientName = requestObject.clientMetadata?
      .clientName?
      .getPreferredDisplay(considering: languages)

    #expect(clientName == "DE Verifier")
  }

  @Test
  func getPreferredDisplay_noLanguages_returnsFallback() {
    let requestObject = RequestObjectJWS.Mock.sample.payload

    let clientName = requestObject.clientMetadata?
      .clientName?
      .getPreferredDisplay(considering: [])

    #expect(clientName == "Verifier")
  }

  @Test(arguments: [
    ValidationCase(
      data: RequestObjectJWS.Mock.duplicateIdTS,
      expected: .duplicateTrustStatement),
    ValidationCase(
      data: RequestObjectJWS.Mock.missingDcqlQueryAndScopeData,
      expected: .missingDcqlQuery),
    ValidationCase(
      data: RequestObjectJWS.Mock.dcqlQueryAndScopeData,
      expected: .verifiedAndNotVerifiedQueryPresent),
    ValidationCase(
      data: RequestObjectJWS.Mock.missingVqPS,
      expected: .missingVQPS),
    ValidationCase(
      data: RequestObjectJWS.Mock.queryScopeMismatch,
      expected: .noQueryFoundOnVQPS),
    ValidationCase(
      data: RequestObjectJWS.Mock.duplicateVqPS,
      expected: .duplicateTrustStatement),
    ValidationCase(
      data: RequestObjectJWS.Mock.duplicatePvaTS,
      expected: .duplicateTrustStatement),
  ])
  func validate_knownValidationErrors(testCase: ValidationCase) {
    #expect(throws: testCase.expected) {
      _ = try decoder.decode(RequestObject.self, from: testCase.data)
    }
  }

  // MARK: Private

  private let decoder = JSONDecoder()
}
