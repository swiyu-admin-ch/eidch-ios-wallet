import XCTest
@testable import BITCore
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - RequestObjectTests

final class RequestObjectTests: XCTestCase {

  func testDecodingVcSdJwtRequestObject() throws {
    let mockRequestObjectData = RequestObject.Mock.VcSdJwt.jsonSampleData
    let mockRequestObject = try JSONDecoder().decode(RequestObject.self, from: mockRequestObjectData)

    XCTAssertNotNil(mockRequestObject.presentationDefinition)
    XCTAssertFalse(mockRequestObject.responseUri.isEmpty)
    XCTAssertNotNil(mockRequestObject.clientMetadata)
    XCTAssertNotNil(mockRequestObject.clientMetadata?.clientName)
    XCTAssertNotNil(mockRequestObject.clientMetadata?.logoUri)

    guard
      let firstInputDescriptor = mockRequestObject.presentationDefinition.inputDescriptors.first
    else {
      XCTFail("No input descriptor")
      return
    }
    XCTAssertEqual(mockRequestObject.firstInputDescriptor, mockRequestObject.presentationDefinition.inputDescriptors.first)
    XCTAssertFalse(firstInputDescriptor.formats.isEmpty)

    let preferredLanguages: [UserLanguageCode] = ["de", "en", "fr"]

    let preferredClientName = ClientMetadata.LocalizedDisplay.getPreferredDisplay(
      from: mockRequestObject.clientMetadata?.clientName,
      considering: preferredLanguages)
    let defaultClientName = ClientMetadata.LocalizedDisplay.getPreferredDisplay(
      from: mockRequestObject.clientMetadata?.clientName,
      considering: [])
    let emptyDisplays = ClientMetadata.LocalizedDisplay.getPreferredDisplay(
      from: nil,
      considering: [])

    XCTAssertEqual(preferredClientName, "DE Verifier")
    XCTAssertEqual(defaultClientName, "EN Verifier")
    XCTAssertNil(emptyDisplays)
    XCTAssertNotNil(mockRequestObject.clientMetadata?.clientName?.fallback())

    XCTAssertEqual(mockRequestObject.firstInputDescriptor?.formats.first?.vcAlgorithm?.first, "ES256")
    XCTAssertEqual(mockRequestObject.firstInputDescriptor?.formats.first?.keyBindingAlgorithm?.first, "ES256")
  }

  func testDecodingVcSdJwtRequestObjectWithUnsupportedClientMetadata() throws {
    let mockRequestObjectData = RequestObject.Mock.VcSdJwt.sampleWithUnsupportedClientMetadata
    let mockRequestObject = try JSONDecoder().decode(RequestObject.self, from: mockRequestObjectData)

    XCTAssertNotNil(mockRequestObject.presentationDefinition)
    XCTAssertFalse(mockRequestObject.responseUri.isEmpty)
    XCTAssertNotNil(mockRequestObject.clientMetadata)
    XCTAssertNil(mockRequestObject.clientMetadata?.clientName)
    XCTAssertNil(mockRequestObject.clientMetadata?.logoUri)

    guard
      let firstInputDescriptor = mockRequestObject.presentationDefinition.inputDescriptors.first
    else {
      XCTFail("No input descriptor")
      return
    }
    XCTAssertFalse(firstInputDescriptor.formats.isEmpty)
  }

  func testDecodingRequestObjectWithoutClientMetadata() throws {
    let mockRequestObjectData = RequestObject.Mock.VcSdJwt.sampleWithoutClientMetadataData
    let mockRequestObject = try JSONDecoder().decode(RequestObject.self, from: mockRequestObjectData)

    XCTAssertNotNil(mockRequestObject.presentationDefinition)
    XCTAssertFalse(mockRequestObject.responseUri.isEmpty)
    XCTAssertNil(mockRequestObject.clientMetadata)
  }

  func testDecoding_UnknownInputDescriptorFormat_ThrowsInvalidPayload() throws {
    let data = RequestObject.Mock.UnknownFormat.sampleData

    XCTAssertThrowsError(try JSONDecoder().decode(RequestObject.self, from: data)) { error in
      XCTAssertEqual(error as? RequestObjectError, .invalidPayload)
    }
  }

  func testDecoding_NoInputDescriptorFormat_ThrowsInvalidPayload() throws {
    let data = RequestObject.Mock.UnknownFormat.sampleWithoutFormatData

    XCTAssertThrowsError(try JSONDecoder().decode(RequestObject.self, from: data)) { error in
      XCTAssertEqual(error as? RequestObjectError, .invalidPayload)
    }
  }

}
