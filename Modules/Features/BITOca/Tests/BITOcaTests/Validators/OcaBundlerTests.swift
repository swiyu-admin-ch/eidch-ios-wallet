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
    XCTAssertEqual(bundle.overlays.count, 25)
  }

  func testCreateOcaBundle_valid_argumentsPassed() throws {
    let bundle = try bundler.createOcaBundle(ocaBundleDataMock)

    XCTAssertEqual(digestsValidatorSpy.validateReceivedRawOcaData, ocaBundleDataMock)
    XCTAssertEqual(brandingOverlayResolverSpy.resolveOverlaysReceivedOverlays?.count, bundle.overlays.count)
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
    brandingOverlayResolverSpy.resolveOverlaysReturnValue = []
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

  private var bundler = OcaBundler()

  private var digestsValidatorSpy = OcaCaptureBaseDigestsValidatorProtocolSpy()
  private var brandingOverlayResolverSpy = BrandingOverlayResolverProtocolSpy()

  private func registerMocks() {
    digestsValidatorSpy = OcaCaptureBaseDigestsValidatorProtocolSpy()
    brandingOverlayResolverSpy = BrandingOverlayResolverProtocolSpy()
    Container.shared.ocaCaptureBaseDigestsValidator.register { self.digestsValidatorSpy }
    Container.shared.brandingOverlayResolver.register { self.brandingOverlayResolverSpy }
  }

  private func successState() {
    digestsValidatorSpy.validateReturnValue = true
    brandingOverlayResolverSpy.resolveOverlaysReturnValue = OcaBundle.Mock.elfa.overlays
  }
}

// swiftlint:enable all
