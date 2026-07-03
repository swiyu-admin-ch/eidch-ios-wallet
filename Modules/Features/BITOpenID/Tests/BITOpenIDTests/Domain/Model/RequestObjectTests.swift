import XCTest
@testable import BITCore
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - RequestObjectTests

final class RequestObjectTests: XCTestCase {

  func testDecodingVcSdJwtRequestObject() throws {
    let mockRequestObjectData = RequestObjectJWS.Mock.sampleData
    let decoder = JSONDecoder()
    let mockRequestObject = try decoder.decode(RequestObject.self, from: mockRequestObjectData)

    XCTAssertNotNil(mockRequestObject.dcqlQuery)
    XCTAssertNotNil(mockRequestObject.responseUri)
    XCTAssertNotNil(mockRequestObject.clientMetadata)
    XCTAssertNotNil(mockRequestObject.clientMetadata?.clientName)
    XCTAssertNotNil(mockRequestObject.clientMetadata?.logoUri)
  }

  func testDecodingVcSdJwtRequestObjectWithUnsupportedClientMetadata() throws {
    let mockRequestObjectData = RequestObjectJWS.Mock.unsupportedClientMetadata
    let decoder = JSONDecoder()
    let mockRequestObject = try decoder.decode(RequestObject.self, from: mockRequestObjectData)

    XCTAssertNotNil(mockRequestObject.dcqlQuery)
    XCTAssertNotNil(mockRequestObject.responseUri)
    XCTAssertNotNil(mockRequestObject.clientMetadata)
    XCTAssertNil(mockRequestObject.clientMetadata?.clientName)
    XCTAssertNil(mockRequestObject.clientMetadata?.logoUri)
  }

  func testDecodingRequestObjectWithoutClientMetadata() throws {
    let mockRequestObjectData = RequestObjectJWS.Mock.withoutClientMetadataData
    let decoder = JSONDecoder()
    let mockRequestObject = try decoder.decode(RequestObject.self, from: mockRequestObjectData)

    XCTAssertNotNil(mockRequestObject.dcqlQuery)
    XCTAssertNotNil(mockRequestObject.responseUri)
    XCTAssertNil(mockRequestObject.clientMetadata)
  }

  func testGetPreferredDisplay_multipleLanguages_returnsFirstValidLanguage() {
    let requestObject = RequestObjectJWS.Mock.sample.payload
    let languages: [UserLanguageCode] = ["cz", "de", "en"]

    let clientName = requestObject.clientMetadata?.clientName?.getPreferredDisplay(considering: languages)

    XCTAssertEqual(clientName, "DE Verifier")
  }

  func testGetPreferredDisplay_noLanguages_returnsFallback() {
    let requestObject = RequestObjectJWS.Mock.sample.payload

    let clientName = requestObject.clientMetadata?.clientName?.getPreferredDisplay(considering: [])

    XCTAssertEqual(clientName, "Verifier")
  }

  func testDecoding_missingQuery_returnsNilQuery() throws {
    let decoder = JSONDecoder()
    let data = Data(
      """
      {
        "client_id": "did:example:12345",
        "response_mode": "direct_post",
        "response_type": "vp_token"
      }
      """
      .utf8)

    let requestObject = try decoder.decode(RequestObject.self, from: data)

    XCTAssertNil(requestObject.dcqlQuery)
  }
}
