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

  func testValidate_valid_returnsOcaBundle() throws {
    let bundle = try bundler.createOcaBundle(ocaBundleDataMock)

    XCTAssertEqual(bundle.captureBases.count, 1)
    XCTAssertEqual(bundle.overlays.count, 3)
  }

  func testValidate_valid_argumentsPassed() throws {
    let bundle = try bundler.createOcaBundle(ocaBundleDataMock)

    XCTAssertEqual(digestsValidatorSpy.validateReceivedRawOcaData, ocaBundleDataMock)
    XCTAssertEqual(ocaBundleValidatorSpy.validateReceivedOcaBundle?.captureBases.count, bundle.captureBases.count)
    XCTAssertEqual(ocaBundleValidatorSpy.validateReceivedOcaBundle?.overlays.count, bundle.overlays.count)
  }

  func testValidate_digestValidatorReturnsFalse_throwsInvalidCESRHashError() throws {
    digestsValidatorSpy.validateReturnValue = false

    XCTAssertThrowsError(try bundler.createOcaBundle(ocaBundleDataMock)) { error in
      XCTAssertEqual(error as? OcaError, .invalidCESRHash)
    }
  }

  func testValidate_decodingError_throwsError() throws {
    let data = "invalid".data(using: .utf8)!

    XCTAssertThrowsError(try bundler.createOcaBundle(data)) { error in
      XCTAssertTrue(error is DecodingError)
    }
  }

  func testValidate_bundleValidatorThrows_throwsError() throws {
    ocaBundleValidatorSpy.validateThrowableError = TestingError.error

    XCTAssertThrowsError(try bundler.createOcaBundle(ocaBundleDataMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private static let digestMock = "digest"

  private let ocaBundleDataMock = OcaBundle.Mock.elfaData

  private var bundler = OcaBundler()

  private var digestsValidatorSpy = OcaCaptureBaseDigestsValidatorProtocolSpy()
  private var ocaBundleValidatorSpy = OcaBundleValidatorProtocolSpy()

  private func registerMocks() {
    digestsValidatorSpy = OcaCaptureBaseDigestsValidatorProtocolSpy()
    ocaBundleValidatorSpy = OcaBundleValidatorProtocolSpy()
    Container.shared.ocaCaptureBaseDigestsValidator.register { self.digestsValidatorSpy }
    Container.shared.ocaBundleValidator.register { self.ocaBundleValidatorSpy }
  }

  private func successState() {
    digestsValidatorSpy.validateReturnValue = true
  }
}

// swiftlint:enable all
