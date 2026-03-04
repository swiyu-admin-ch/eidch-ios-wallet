import XCTest
@testable import BITCore
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - RequestObjectTests

final class RequestObjectTests: XCTestCase {

  func testDecodingVcSdJwtRequestObject() throws {
    let mockRequestObjectData = RequestObject.Mock.VcSdJwt.jsonSampleData
    let decoder = JSONDecoder()
    let mockRequestObject = try decoder.decode(RequestObject.self, from: mockRequestObjectData)

    XCTAssertNotNil(mockRequestObject.presentationDefinition)
    XCTAssertNotNil(mockRequestObject.responseUri)
    XCTAssertNotNil(mockRequestObject.clientMetadata)
    XCTAssertNotNil(mockRequestObject.clientMetadata?.clientName)
    XCTAssertNotNil(mockRequestObject.clientMetadata?.logoUri)

    guard
      let presentationDefinition = mockRequestObject.presentationDefinition,
      let firstInputDescriptor = presentationDefinition.inputDescriptors.first
    else {
      XCTFail("No input descriptor")
      return
    }
    XCTAssertEqual(mockRequestObject.firstInputDescriptor, presentationDefinition.inputDescriptors.first)
    XCTAssertFalse(firstInputDescriptor.formats.isEmpty)

    XCTAssertEqual(mockRequestObject.firstInputDescriptor?.formats.first?.vcAlgorithm?.first, "ES256")
    XCTAssertEqual(mockRequestObject.firstInputDescriptor?.formats.first?.keyBindingAlgorithm?.first, "ES256")
  }

  func testDecodingVcSdJwtRequestObjectWithUnsupportedClientMetadata() throws {
    let mockRequestObjectData = RequestObject.Mock.VcSdJwt.sampleWithUnsupportedClientMetadata
    let decoder = JSONDecoder()
    let mockRequestObject = try decoder.decode(RequestObject.self, from: mockRequestObjectData)

    XCTAssertNotNil(mockRequestObject.presentationDefinition)
    XCTAssertNotNil(mockRequestObject.responseUri)
    XCTAssertNotNil(mockRequestObject.clientMetadata)
    XCTAssertNil(mockRequestObject.clientMetadata?.clientName)
    XCTAssertNil(mockRequestObject.clientMetadata?.logoUri)

    guard
      let presentationDefinition = mockRequestObject.presentationDefinition,
      let firstInputDescriptor = presentationDefinition.inputDescriptors.first
    else {
      XCTFail("No input descriptor")
      return
    }
    XCTAssertFalse(firstInputDescriptor.formats.isEmpty)
  }

  func testDecodingRequestObjectWithoutClientMetadata() throws {
    let mockRequestObjectData = RequestObject.Mock.VcSdJwt.sampleWithoutClientMetadataData
    let decoder = JSONDecoder()
    let mockRequestObject = try decoder.decode(RequestObject.self, from: mockRequestObjectData)

    XCTAssertNotNil(mockRequestObject.presentationDefinition)
    XCTAssertNotNil(mockRequestObject.responseUri)
    XCTAssertNil(mockRequestObject.clientMetadata)
  }

  func testDecoding_UnknownInputDescriptorFormat_ThrowsInvalidPayload() throws {
    let data = RequestObject.Mock.UnknownFormat.sampleData

    let decoder = JSONDecoder()
    XCTAssertThrowsError(try decoder.decode(RequestObject.self, from: data)) { error in
      XCTAssertEqual(error as? RequestObjectError, .invalidPayload)
    }
  }

  func testDecoding_NoInputDescriptorFormat_ThrowsInvalidPayload() throws {
    let data = RequestObject.Mock.UnknownFormat.sampleWithoutFormatData

    let decoder = JSONDecoder()
    XCTAssertThrowsError(try decoder.decode(RequestObject.self, from: data)) { error in
      XCTAssertEqual(error as? RequestObjectError, .invalidPayload)
    }
  }

  func testGetPreferredDisplay_multipleLanguages_returnsFirstValidLanguage() {
    let requestObject = RequestObject.Mock.VcSdJwt.sample
    let languages: [UserLanguageCode] = ["cz", "de", "en"]

    let clientName = requestObject.clientMetadata?.clientName?.getPreferredDisplay(considering: languages)

    XCTAssertEqual(clientName, "DE Verifier")
  }

  func testGetPreferredDisplay_noLanguages_returnsFallback() {
    let requestObject = RequestObject.Mock.VcSdJwt.sample

    let clientName = requestObject.clientMetadata?.clientName?.getPreferredDisplay(considering: [])

    XCTAssertEqual(clientName, "Verifier")
  }

  func testDecodingDcqlRequestObjectCapturesRawQuery() throws {
    let decoder = JSONDecoder()
    let requestObject = try decoder.decode(RequestObject.self, from: RequestObject.Mock.Dcql.sampleData)

    XCTAssertNil(requestObject.presentationDefinition)
    XCTAssertNotNil(requestObject.rawDcqlQuery)
  }

}
