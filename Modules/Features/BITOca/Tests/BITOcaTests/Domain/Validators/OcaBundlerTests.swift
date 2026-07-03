import Factory
import Spyable
import XCTest
@testable import BITOca
@testable import BITTestingCore

// swiftlint:disable force_unwrapping

// MARK: - OcaBundlerTests

final class OcaBundlerTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    bundler = OcaBundler()
    successState()
  }

  func testCreateOcaBundle_valid_returnsOcaBundle() throws {
    let bundle = try bundler.createOcaBundle(ocaBundleDataMock)

    XCTAssertEqual(bundle.captureBases.count, 2)
    XCTAssertEqual(bundle.overlays.count, 26)
  }

  func testCreateOcaBundle_valid_argumentsPassed() throws {
    let bundle = try bundler.createOcaBundle(ocaBundleDataMock)

    XCTAssertEqual(digestsValidatorSpy.validateReceivedRawOcaData, ocaBundleDataMock)
    XCTAssertEqual(overlayTemplateResolverSpy.callAsFunctionOverlaysReceivedOverlays?.count, bundle.overlays.count)
  }

  func testCreateOcaBundle_digestValidatorReturnsFalse_throwsInvalidCESRHashError() throws {
    digestsValidatorSpy.validateReturnValue = false

    XCTAssertThrowsError(try bundler.createOcaBundle(ocaBundleDataMock)) { error in
      XCTAssertEqual(error as? OcaError, .invalidCESRHash)
    }
  }

  func testCreateOcaBundle_resolvedOverlays_verifyBrandingOverlaysAdded() throws {
    let bundle = try bundler.createOcaBundle(ocaBundleDataMock)
    XCTAssertEqual(bundle.overlays.compactMap { $0 as? BrandingOverlay1x1 }.count, 5)
  }

  func testCreateOcaBundle_missingBrandingOverlays_verifyBrandingOverlaysEmpty() throws {
    overlayTemplateResolverSpy.callAsFunctionOverlaysReturnValue = []
    let bundle = try bundler.createOcaBundle(OcaBundle.Mock.emptyBrandingOverlayData)
    XCTAssertEqual(bundle.overlays.compactMap { $0 as? BrandingOverlay1x1 }.count, 0)
  }

  func testCreateOcaBundle_decodingError_throwsError() throws {
    let data = "invalid".data(using: .utf8)!

    XCTAssertThrowsError(try bundler.createOcaBundle(data)) { error in
      XCTAssertEqual(error as? OcaError, .invalidJsonObject)
    }
  }

  func testCreateOcaBundle_MissingCaptureBases_throwsError() throws {
    XCTAssertThrowsError(try bundler.createOcaBundle(OcaBundle.Mock.missingCaptureBasesData)) { error in
      XCTAssertEqual(error as? OcaError, .invalidRootCaptureBase)
    }
  }

  func testCreateOcaBundle_MissingOverlays_throwsError() throws {
    XCTAssertThrowsError(try bundler.createOcaBundle(OcaBundle.Mock.missingOverlaysData)) { error in
      XCTAssertEqual(error as? OcaError, .invalidOverlayCaptureBaseDigest)
    }
  }

  func testCreateOcaBundle_MalformedCaputureBases_throwsError() throws {
    XCTAssertThrowsError(try bundler.createOcaBundle(OcaBundle.Mock.malformedCaptureBasesData)) { error in
      XCTAssertNotNil(error as? DecodingError)
    }
  }

  func testCreateOcaBundle_MalformedOverlays_throwsError() throws {
    XCTAssertThrowsError(try bundler.createOcaBundle(OcaBundle.Mock.malformedOverlaysData)) { error in
      XCTAssertNotNil(error as? DecodingError)
    }
  }

  // MARK: Private

  private static let digestMock = "digest"

  private let ocaBundleDataMock = OcaBundle.Mock.elfaData
  private let ocaBundleaMock = OcaBundle.Mock.elfa

  private var bundler = OcaBundler()

  private var digestsValidatorSpy = OcaCaptureBaseDigestsValidatorProtocolSpy()
  private var overlayTemplateResolverSpy = OverlayTemplateResolverProtocolSpy()

  private func registerMocks() {
    digestsValidatorSpy = OcaCaptureBaseDigestsValidatorProtocolSpy()
    overlayTemplateResolverSpy = OverlayTemplateResolverProtocolSpy()
    Container.shared.ocaCaptureBaseDigestsValidator.register { self.digestsValidatorSpy }
    Container.shared.overlayTemplateResolver.register { self.overlayTemplateResolverSpy }
  }

  private func successState() {
    digestsValidatorSpy.validateReturnValue = true
    overlayTemplateResolverSpy.callAsFunctionOverlaysReturnValue = ocaBundleaMock.overlays
  }
}

// swiftlint:enable all
