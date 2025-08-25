import XCTest
@testable import BITOca

final class EntryOverlayTests: XCTestCase {

  // MARK: Internal

  func testValidate_withEntriesInEntryCodeOverlay_isValid() throws {
    let entryCodeOverlay = Self.createEntryCodeOverlay(attributeEntryCodes: ["id": ["A", "B"], "sex": ["F", "M", "X"]])
    let entryOverlay = Self.createEntryOverlay(attributeEntries: ["sex": ["F": "Female", "M": "Male", "X": "Unspecified"]])

    XCTAssertNoThrow(try entryOverlay.validate(with: [], overlays: [entryCodeOverlay, entryOverlay]))
  }

  func testValidate_entryAndEntryCodeOverlayNotOnSameCaptureBase_throwsInvalidEntryError() throws {
    let captureBaseA = Self.createCaptureBase(digest: "A", attributes: ["sex": .text])
    let captureBaseB = Self.createCaptureBase(digest: "B", attributes: ["sex": .text])
    let entryCodeOverlay = Self.createEntryCodeOverlay(captureBaseDigest: "B")
    let entryOverlay = Self.createEntryOverlay(captureBaseDigest: "A")

    XCTAssertThrowsError(try entryOverlay.validate(with: [captureBaseA, captureBaseB], overlays: [entryCodeOverlay, entryOverlay])) { error in
      XCTAssertEqual(error as? OcaError, .invalidEntryOverlay)
    }
  }

  func testValidate_withoutEntryCodeOverlay_throwsInvalidEntryOverlayError() throws {
    let captureBase = Self.createCaptureBase(attributes: ["sex": .text])
    let entryOverlay = Self.createEntryOverlay()

    XCTAssertThrowsError(try entryOverlay.validate(with: [captureBase], overlays: [entryOverlay])) { error in
      XCTAssertEqual(error as? OcaError, .invalidEntryOverlay)
    }
  }

  func testValidate_invalidEntryCode_throwsInvalidEntryOverlayError() throws {
    let captureBase = Self.createCaptureBase(attributes: ["sex": .text])
    let entryCodeOverlay = Self.createEntryCodeOverlay(attributeEntryCodes: ["sex": ["F", "M", "X"]])
    let entryOverlay = Self.createEntryOverlay(attributeEntries: ["sex": ["unknown": "Unknown"]])

    XCTAssertThrowsError(try entryOverlay.validate(with: [captureBase], overlays: [entryCodeOverlay, entryOverlay])) { error in
      XCTAssertEqual(error as? OcaError, .invalidEntryOverlay)
    }
  }

  // MARK: Private

  private static let digestMock = "digest"
  private static let entryCodeMock = ["sex": ["F", "M", "X"]]
  private static let entryMock = ["sex": ["F": "Female", "M": "Male", "X": "Unspecified"]]

  private static func createEntryCodeOverlay(captureBaseDigest: String = digestMock, attributeEntryCodes: [AttributeKey: [EntryCode]] = entryCodeMock) -> EntryCodeOverlay1x0 {
    EntryCodeOverlay1x0(captureBaseDigest: captureBaseDigest, attributeEntryCodes: attributeEntryCodes)
  }

  private static func createEntryOverlay(captureBaseDigest: String = digestMock, attributeEntries: [AttributeKey: [EntryCode: String]] = entryMock) -> EntryOverlay1x0 {
    EntryOverlay1x0(captureBaseDigest: captureBaseDigest, language: "language", attributeEntries: attributeEntries)
  }

  private static func createCaptureBase(digest: String = digestMock, attributes: [AttributeKey: AttributeType] = [:]) -> CaptureBase1x0 {
    CaptureBase1x0(digest: digest, attributes: attributes, classification: nil, flaggedAttributes: nil)
  }
}
