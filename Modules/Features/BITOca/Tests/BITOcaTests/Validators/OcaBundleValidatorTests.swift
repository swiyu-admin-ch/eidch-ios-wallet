import Factory
import Spyable
import XCTest
@testable import BITCore
@testable import BITOca

// MARK: - OcaBundleValidatorTests

final class OcaBundleValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    validator = OcaBundleValidator()
    successState()
  }

  func testValidate_valid_argumentsPassed() throws {
    let overlay = Self.createLabelOverlay(captureBaseDigest: Self.digestMock)
    try validator.validate([emptyCaptureBaseMock], [overlay])

    XCTAssertEqual(localeValidatorSpy.validateCallsCount, 1)
    XCTAssertEqual(localeValidatorSpy.validateReceivedLocale, Self.languageMock)
  }

  func testValidate_captureBaseGraphWithoutCycles_justRuns() throws {
    let digest1 = "digest1"
    let digest2 = "digest2"
    let digest3 = "digest3"
    let rootCaptureBase = Self.createCaptureBase(digest: Self.digestMock, attributes: ["test": .reference(digest: digest1), "test_other": .array(type: .reference(digest: digest2))])
    let captureBase1 = Self.createCaptureBase(digest: digest1, attributes: ["test": .reference(digest: digest3)])
    let captureBase2 = Self.createCaptureBase(digest: digest2, attributes: ["test": .array(type: .reference(digest: digest3))])
    let captureBase3 = Self.createCaptureBase(digest: digest3)

    XCTAssertNoThrow(try validator.validate([rootCaptureBase, captureBase1, captureBase2, captureBase3], []))
  }

  func testValidate_additionalOverlayAttribute_justRuns() throws {
    let overlay = Self.createLabelOverlay(captureBaseDigest: Self.digestMock, attributes: ["test": "test"])

    XCTAssertNoThrow(try validator.validate([emptyCaptureBaseMock], [overlay]))
  }

  func testValidate_brandingOverlay_justRuns() throws {
    let overlay = try Self.createBrandingOverlay(logo: URL(string: "data:image/png;base64,iVBORw0KG"))

    XCTAssertNoThrow(try validator.validate([emptyCaptureBaseMock], [overlay]))
  }

  func testValidate_invalidAttributeTypeReference_throwsInvalidReferenceAttributeError() throws {
    let captureBase = Self.createCaptureBase(digest: "otherDigest", attributes: ["test": referenceAttributeMock, "test_other": .reference(digest: "invalid")])

    XCTAssertThrowsError(try validator.validate([emptyCaptureBaseMock, captureBase], [])) { error in
      XCTAssertEqual(error as? OcaError, .invalidCaptureBaseReferenceAttribute)
    }
  }

  func testValidate_invalidArrayAttributeTypeReference_throwsInvalidReferenceAttributeError() throws {
    let captureBase = Self.createCaptureBase(digest: "otherDigest", attributes: ["test": referenceAttributeMock, "test_other": .array(type: .reference(digest: "invalid"))])

    XCTAssertThrowsError(try validator.validate([emptyCaptureBaseMock, captureBase], [])) { error in
      XCTAssertEqual(error as? OcaError, .invalidCaptureBaseReferenceAttribute)
    }
  }

  func testValidate_oneSelfReferencingCaptureBase_throwsCycleError() throws {
    let digest = "otherDigest"
    let rootCaptureBase = Self.createCaptureBase(digest: Self.digestMock, attributes: ["test": .reference(digest: digest)])
    let captureBase = Self.createCaptureBase(digest: digest, attributes: ["test": .reference(digest: digest)])
    rootCaptureBaseResolverSpy.resolveReturnValue = rootCaptureBase

    XCTAssertThrowsError(try validator.validate([rootCaptureBase, captureBase], [])) { error in
      XCTAssertEqual(error as? OcaError, .captureBaseCycleError)
    }
  }

  func testValidate_twoCaptureBaseCycle_throwsCycleError() throws {
    let digest1 = "digest1"
    let digest2 = "digest2"
    let rootCaptureBase = Self.createCaptureBase(digest: Self.digestMock, attributes: ["test": .reference(digest: digest1)])
    let captureBase1 = Self.createCaptureBase(digest: digest1, attributes: ["test": .reference(digest: digest2)])
    let captureBase2 = Self.createCaptureBase(digest: digest2, attributes: ["test": .reference(digest: digest1)])
    rootCaptureBaseResolverSpy.resolveReturnValue = rootCaptureBase

    XCTAssertThrowsError(try validator.validate([rootCaptureBase, captureBase1, captureBase2], [])) { error in
      XCTAssertEqual(error as? OcaError, .captureBaseCycleError)
    }
  }

  func testValidate_threeCaptureBaseCycle_throwsCycleError() throws {
    let digest1 = "digest1"
    let digest2 = "digest2"
    let digest3 = "digest3"
    let rootCaptureBase = Self.createCaptureBase(digest: Self.digestMock, attributes: ["test": .reference(digest: digest1)])
    let captureBase1 = Self.createCaptureBase(digest: digest1, attributes: ["test": .array(type: .reference(digest: digest2))])
    let captureBase2 = Self.createCaptureBase(digest: digest2, attributes: ["test": .reference(digest: digest3)])
    let captureBase3 = Self.createCaptureBase(digest: digest3, attributes: ["test": .reference(digest: digest1)])
    rootCaptureBaseResolverSpy.resolveReturnValue = rootCaptureBase

    XCTAssertThrowsError(try validator.validate([rootCaptureBase, captureBase1, captureBase2, captureBase3], [])) { error in
      XCTAssertEqual(error as? OcaError, .captureBaseCycleError)
    }
  }

  func testValidate_rootCaptureBaseResolverThrows_rethrowsError() throws {
    rootCaptureBaseResolverSpy.resolveThrowableError = OcaError.invalidRootCaptureBase

    XCTAssertThrowsError(try validator.validate([emptyCaptureBaseMock], [])) { error in
      XCTAssertEqual(error as? OcaError, .invalidRootCaptureBase)
    }
  }

  func testValidate_invalidOverlayCaptureBaseDigest_throwsOverlayCaptureBaseError() throws {
    let overlay = Self.createLabelOverlay(captureBaseDigest: "otherDigest", attributes: ["test": "test"])

    XCTAssertThrowsError(try validator.validate([emptyCaptureBaseMock], [overlay])) { error in
      XCTAssertEqual(error as? OcaError, .invalidOverlayCaptureBaseDigest)
    }
  }

  func testValidate_invalidOverlayLanguage_throwsLanguageCodeError() throws {
    let overlay = Self.createLabelOverlay(captureBaseDigest: Self.digestMock)
    localeValidatorSpy.validateReturnValue = false

    XCTAssertThrowsError(try validator.validate([emptyCaptureBaseMock], [overlay])) { error in
      XCTAssertEqual(error as? OcaError, .invalidOverlayLanguageCode)
    }
  }

  // MARK: Private

  private static let digestMock = "digest"
  private static let languageMock = "language"

  private let emptyCaptureBaseMock = createCaptureBase()
  private let referenceAttributeMock = AttributeType.reference(digest: digestMock)

  private var localeValidatorSpy = LocaleValidatorProtocolSpy()
  private var rootCaptureBaseResolverSpy = RootCaptureBaseResolverProtocolSpy()

  private var validator = OcaBundleValidator()

  private static func createCaptureBase(digest: String = digestMock, attributes: [AttributeKey: AttributeType] = [:]) -> CaptureBase1x0 {
    CaptureBase1x0(digest: digest, attributes: attributes, classification: nil, flaggedAttributes: nil)
  }

  private static func createLabelOverlay(captureBaseDigest: String = digestMock, language: String = languageMock, attributes: [AttributeKey: String] = [:]) -> LabelOverlay1x0 {
    LabelOverlay1x0(captureBaseDigest: captureBaseDigest, language: language, attributeLabels: attributes, attributeCategories: nil, categoryLabels: nil)
  }

  private static func createBrandingOverlay(captureBaseDigest: String = digestMock, language: String = languageMock, logo: URL? = nil) throws -> BrandingOverlay1x1 {
    try BrandingOverlay1x1(captureBaseDigest: captureBaseDigest, logo: logo, language: language)
  }

  private func registerMocks() {
    localeValidatorSpy = LocaleValidatorProtocolSpy()
    Container.shared.localeValidator.register { self.localeValidatorSpy }
    Container.shared.rootCaptureBaseResolver.register { self.rootCaptureBaseResolverSpy }
  }

  private func successState() {
    localeValidatorSpy.validateReturnValue = true
    rootCaptureBaseResolverSpy.resolveReturnValue = Self.createCaptureBase()
  }

}
