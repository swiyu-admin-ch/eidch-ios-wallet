import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITOca
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable force_unwrapping

final class OcaClaimGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    success()
    generator = OcaClaimGenerator()
  }

  func testGenerate_attributeWithLabels_returnsClaimWithDisplays() throws {
    let anyClaim = createAnyClaim(value: .string(Self.valueMock))
    let labels = createLabels(for: ["en", "de"])
    let attribute = createAttribute(attributeType: .text, labels: labels)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    let expectedDisplays = labels.map { locale, name in
      CredentialClaimDisplay(locale: locale, name: name)
    }
    assertClaim(claim, displays: expectedDisplays)
  }

  func testGenerate_textAttributeWithEntries_returnsClaimWithDisplays() throws {
    let anyClaim = createAnyClaim(value: .string(Self.entryCodeMock))
    let entryMapping = createEntryMapping(for: ["en", "de"], entryCode: Self.entryCodeMock)
    let attribute = createAttribute(attributeType: .text, entryMapping: entryMapping)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    let expectedDisplays = entryMapping.map { locale, entries in
      CredentialClaimDisplay(locale: locale, value: entries[Self.entryCodeMock])
    }
    assertClaim(claim, value: Self.entryCodeMock, displays: expectedDisplays)
  }

  func testGenerate_numericAttributeWithEntries_returnsClaimWithDisplays() throws {
    let anyClaim = createAnyClaim(value: .int(1))
    let entryMapping = createEntryMapping(for: ["en", "de"], entryCode: "1")
    let attribute = createAttribute(attributeType: .numeric, entryMapping: entryMapping)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    let expectedDisplays = entryMapping.map { locale, entries in
      CredentialClaimDisplay(locale: locale, value: entries["1"])
    }
    assertClaim(claim, value: "1", valueType: .numeric, displays: expectedDisplays)
  }

  func testGenerate_booleanAttributeWithEntries_returnsClaimWithDisplays() throws {
    let anyClaim = createAnyClaim(value: .bool(true))
    let entryMapping = createEntryMapping(for: ["en", "de"], entryCode: "true")
    let attribute = createAttribute(attributeType: .numeric, entryMapping: entryMapping)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    let expectedDisplays = entryMapping.map { locale, entries in
      CredentialClaimDisplay(locale: locale, value: entries["true"])
    }
    assertClaim(claim, value: "true", valueType: .numeric, displays: expectedDisplays)
  }

  func testGenerate_attributeWithLabelsAndEntries_returnsClaimWithDisplays() throws {
    let anyClaim = createAnyClaim(value: .string(Self.entryCodeMock))
    let locales = ["en", "de"]
    let labels = createLabels(for: locales)
    let entryMapping = createEntryMapping(for: locales)
    let attribute = createAttribute(attributeType: .text, entryMapping: entryMapping, labels: labels)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    let expectedDisplays = locales.map { locale in
      CredentialClaimDisplay(locale: locale, name: "\(labelMock)_\(locale)", value: "\(Self.entryCodeMock)_\(locale)")
    }
    assertClaim(claim, value: Self.entryCodeMock, displays: expectedDisplays)
  }

  func testGenerate_attributeWithSomeLabelsAndSomeEntries_returnsClaimWithDisplays() throws {
    let anyClaim = createAnyClaim(value: .string(Self.entryCodeMock))
    let labels = createLabels(for: ["en", "de"])
    let entryMapping = createEntryMapping(for: ["de", "fr"])
    let attribute = createAttribute(attributeType: .text, entryMapping: entryMapping, labels: labels)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    let expectedDisplays = [
      CredentialClaimDisplay(locale: "en", name: "\(labelMock)_en"),
      CredentialClaimDisplay(locale: "de", name: "\(labelMock)_de", value: "\(Self.entryCodeMock)_de"),
      CredentialClaimDisplay(locale: "fr", value: "\(Self.entryCodeMock)_fr"),
    ]
    assertClaim(claim, value: Self.entryCodeMock, displays: expectedDisplays)
  }

  func testGenerate_attributeWithoutLabelsNorEntries_returnsClaimWithoutDisplays() throws {
    let anyClaim = createAnyClaim(value: .string(Self.valueMock))
    let attribute = createAttribute(attributeType: .text)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, displays: [])
  }

  func testGenerate_attributeWithMismatchingEntries_returnsClaimWithoutDisplays() throws {
    let anyClaim = createAnyClaim(value: .string(Self.valueMock))
    let entryMapping = createEntryMapping(for: ["de"], entryCode: "other")
    let attribute = createAttribute(attributeType: .text, entryMapping: entryMapping)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, displays: [])
  }

  func testGenerate_attributeWithOrder_returnsClaimWithOrder() throws {
    let anyClaim = createAnyClaim(value: .string(Self.valueMock))
    let attribute = createAttribute(attributeType: .text, order: 1)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, order: 1)
  }

  func testGenerate_dataURLPNG_returnsPNGClaim() throws {
    let anyClaim = createAnyClaim(value: .string("data:image/png;base64,\(Self.valueMock)"))
    let attribute = createAttribute(attributeType: .text, standard: .dataURLScheme)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: Self.valueMock, valueType: .imagePng)
  }

  func testGenerate_dataURLPNGWithNilValue_returnsStringClaim() throws {
    let anyClaim = createAnyClaim(value: nil)
    let attribute = createAttribute(attributeType: .text, standard: .dataURLScheme)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: nil, valueType: .string)
  }

  func testGenerate_binaryPNG_returnsPNGClaim() throws {
    let anyClaim = createAnyClaim(value: .string(Self.valueMock))
    let attribute = createAttribute(attributeType: .binary, encoding: .base64, format: "image/png")

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: Self.valueMock, valueType: .imagePng)
  }

  func testGenerate_binaryPNGWithNilValue_returnsPNGClaim() throws {
    let anyClaim = createAnyClaim(value: nil)
    let attribute = createAttribute(attributeType: .binary, encoding: .base64, format: "image/png")

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: nil, valueType: .imagePng)
  }

  func testGenerate_dataURLJPG_returnsJPGClaim() throws {
    let anyClaim = createAnyClaim(value: .string("data:image/jpeg;base64,\(Self.valueMock)"))
    let attribute = createAttribute(attributeType: .text, standard: .dataURLScheme)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: Self.valueMock, valueType: .imageJpg)
  }

  func testGenerate_binaryJPG_returnsJPGClaim() throws {
    let anyClaim = createAnyClaim(value: .string(Self.valueMock))
    let attribute = createAttribute(attributeType: .binary, encoding: .base64, format: "image/jpeg")

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: Self.valueMock, valueType: .imageJpg)
  }

  func testGenerate_dataURLUnknownFormat_returnsStringClaim() throws {
    let url = "data:unknown/unknown;base64,\(Self.valueMock)"
    let anyClaim = createAnyClaim(value: .string(url))
    let attribute = createAttribute(attributeType: .text, standard: .dataURLScheme)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: url, valueType: .string)
  }

  func testGenerate_binaryUnknownFormat_returnsStringClaim() throws {
    let anyClaim = createAnyClaim(value: .string(Self.valueMock))
    let attribute = createAttribute(attributeType: .binary, encoding: .base64, format: "unknown/unknown")

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, valueType: .string)
  }

  func testGenerate_binaryPNGWithoutEncoding_returnsStringClaim() throws {
    let anyClaim = createAnyClaim(value: .string(Self.valueMock))
    let attribute = createAttribute(attributeType: .binary, encoding: nil, format: "image/png")

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, valueType: .string)
  }

  func testGenerate_dateTime_returnsDateTimeClaim() throws {
    let anyClaim = createAnyClaim(value: .string(dateTimeMock))
    let attribute = createAttribute(attributeType: .dateTime)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: Self.normalizedDateTimeMock, valueType: .dateTime, valueDisplayInfo: Self.dateFormatMock.rawValue, ocaAttribute: attribute)
  }

  func testGenerate_dateTimeWithNilValue_returnsDateTimeClaim() throws {
    let anyClaim = createAnyClaim(value: nil)
    let attribute = createAttribute(attributeType: .dateTime)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: nil, valueType: .dateTime)
  }

  func testGenerate_dateTimeParserReturnsNil_returnsDateTimeClaimWithoutFormat() throws {
    let anyClaim = createAnyClaim(value: .string(dateTimeMock))
    let attribute = createAttribute(attributeType: .dateTime)
    overlayAttributeDateParserSpy.parseWithReturnValue = nil

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: dateTimeMock, valueType: .dateTime, valueDisplayInfo: nil, ocaAttribute: attribute)
  }

  func testGenerate_arrayAttribute_returnsStringClaim() throws {
    let anyClaim = createAnyClaim(value: .array([.string("value")]))
    let attribute = createAttribute(attributeType: .array(type: .text))

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: anyClaim.value!.rawValue, valueType: .string)
  }

  func testGenerate_referenceAttribute_returnsStringClaim() throws {
    let anyClaim = createAnyClaim(value: .dictionary(["test": .string("value")]))
    let attribute = createAttribute(attributeType: .reference(digest: "digest"))

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: anyClaim.value!.rawValue, valueType: .string)
  }

  func testGenerate_nilValue_returnsStringClaim() throws {
    let anyClaim = createAnyClaim(value: nil)
    let attribute = createAttribute(attributeType: .text)

    let claim = generator.generate(for: anyClaim, ocaAttribute: attribute)

    assertClaim(claim, value: nil)
  }

  // MARK: Private

  private static let normalizedDateTimeMock = "normalizedDateTime"
  private static let dateFormatMock = DateParserResult.Format.date
  private static let valueMock = "value"
  private static let entryCodeMock = "entryCode"

  private let dateParserResultMock = DateParserResult(normalizedDate: normalizedDateTimeMock, format: dateFormatMock)
  private let dateTimeMock = "dateTime"

  private let keyMock = "key"
  private let labelMock = "label"

  private var overlayAttributeDateParserSpy = OverlayAttributeDateParserProtocolSpy()

  private var generator = OcaClaimGenerator()

  private func registerMocks() {
    Container.shared.overlayAttributeDateParser.register { self.overlayAttributeDateParserSpy }
  }

  private func success() {
    overlayAttributeDateParserSpy.parseWithReturnValue = dateParserResultMock
  }

  private func createAnyClaim(value: CodableValue?) -> AnyClaim {
    let anyClaim = AnyClaimSpy()
    anyClaim.key = "$.\(keyMock)"
    anyClaim.value = value
    return anyClaim
  }

  private func createAttribute(
    attributeType: AttributeType,
    encoding: CharacterEncoding? = nil,
    entryMapping: [BITOca.Locale: [EntryCode: String]] = [:],
    format: String? = nil,
    labels: [BITOca.Locale: String] = [:],
    order: Int? = nil,
    standard: Standard? = nil)
    -> OverlayBundleAttribute
  {
    OverlayBundleAttribute(captureBaseDigest: "captureBaseDigest", name: "name", attributeType: attributeType, characterEncoding: encoding, entryMapping: entryMapping, format: format, labels: labels, order: order, standard: standard)
  }

  private func createLabels(for locales: [BITOca.Locale]) -> [BITOca.Locale: String] {
    locales.compactGroupWith { locale in
      "\(labelMock)_\(locale)"
    }
  }

  private func createEntryMapping(for locales: [BITOca.Locale], entryCode: EntryCode = entryCodeMock) -> [BITOca.Locale: [EntryCode: String]] {
    locales.compactGroupWith { locale in
      [entryCode: "\(entryCode)_\(locale)"]
    }
  }

  private func assertClaim(
    _ claim: CredentialClaim,
    value: String? = valueMock,
    valueType: ValueType = .string,
    valueDisplayInfo: String? = nil,
    order: Int = Int(Int16.max),
    displays: [CredentialClaimDisplay] = [],
    ocaAttribute: OverlayBundleAttribute? = nil)
  {
    XCTAssertEqual(claim.key, keyMock)
    XCTAssertEqual(claim.value, value)
    XCTAssertEqual(claim.valueType, valueType.rawValue)
    XCTAssertEqual(claim.valueDisplayInfo, valueDisplayInfo)
    XCTAssertEqual(claim.order, order)

    XCTAssertEqual(claim.displays.count, displays.count)
    for display in claim.displays {
      let expectedDisplay = displays.first { display.locale == $0.locale }
      XCTAssertEqual(display.name, expectedDisplay?.name)
      XCTAssertEqual(display.value, expectedDisplay?.value)
    }

    if case .dateTime = valueType, value != nil {
      XCTAssertEqual(overlayAttributeDateParserSpy.parseWithCallsCount, 1)
      XCTAssertEqual(overlayAttributeDateParserSpy.parseWithReceivedArguments?.dateString, dateTimeMock)
      XCTAssertEqual(overlayAttributeDateParserSpy.parseWithReceivedArguments?.ocaAttribute, ocaAttribute)
    } else {
      XCTAssertFalse(overlayAttributeDateParserSpy.parseWithCalled)
    }
  }
}

// swiftlint:enable all
