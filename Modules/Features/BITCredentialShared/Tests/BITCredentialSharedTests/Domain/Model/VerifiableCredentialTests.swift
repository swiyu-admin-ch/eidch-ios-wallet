import BITCore
import Factory
import XCTest
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITTestingCore

// swiftlint:disable force_unwrapping

// MARK: - CredentialTests

final class VerifiableCredentialTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
  }

  func testInit_demoDid_returnsDemoCredential() {
    let issuer = "did:tdw:mock=:identifier-reg.trust-infra.swiyu-int.admin.ch:api:v1:did:123"

    let credential = VerifiableCredential(payload: "payload".data(using: .utf8)!, format: "format", issuer: issuer)

    XCTAssertEqual(credential.environment, .demo)
  }

  func testInit_notDemoDid_returnsNormalCredential() {
    let issuer = "did:tdw:mock=:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:123"

    let credential = VerifiableCredential(payload: "payload".data(using: .utf8)!, format: "format", issuer: issuer)

    XCTAssertEqual(credential.environment, .none)
  }

  func testFindDisplay_additionalDisplays_notAvailable() {
    let unmanagedCode = "cz"
    Container.shared.preferredUserLocales.register { [unmanagedCode] }
    let credential = VerifiableCredential.Mock.otherSampleDisplaysAdditional
    let expectedLanguageCode = "en"

    assertDisplays(credential: credential, expectedLanguageCode: expectedLanguageCode)
  }

  func testFindDisplay_appDefaultDisplays() {
    Container.shared.preferredUserLocales.register { [UserLocale.LocaleIdentifier.swissItalian.rawValue] }
    let credential = VerifiableCredential.Mock.sampleDisplaysAppDefault
    let expectedLanguageCode = "en"

    assertDisplays(credential: credential, expectedLanguageCode: expectedLanguageCode)
  }

  func testFindDisplay_fallbackDisplays() {
    Container.shared.preferredUserLocales.register { [UserLocale.LocaleIdentifier.swissItalian.rawValue] }
    let credential = VerifiableCredential.Mock.sampleDisplaysFallback
    let expectedLanguageCode = "en"

    assertDisplays(credential: credential, expectedLanguageCode: expectedLanguageCode)
  }

  func testFindDisplay_unsupportedDisplays() {
    Container.shared.preferredUserLocales.register { [UserLocale.LocaleIdentifier.swissItalian.rawValue] }
    let credential = VerifiableCredential.Mock.sampleDisplaysUnsupported

    let claims = credential.clusters.first?.claims ?? []
    for claim in claims {
      let claimDisplay = claim.preferredDisplay
      XCTAssertNotNil(claimDisplay)
    }
  }

  func testFindDisplay_emptyDisplays() {
    Container.shared.preferredUserLocales.register { [UserLocale.LocaleIdentifier.swissItalian.rawValue] }
    let credential = VerifiableCredential.Mock.sampleDisplaysEmpty

    let claims = credential.clusters.first?.claims ?? []
    for claim in claims {
      let claimDisplay = claim.preferredDisplay
      XCTAssertEqual(claimDisplay?.name, claim.key)
    }
  }

  // MARK: Private

  private func assertDisplays(credential: VerifiableCredential, expectedLanguageCode: UserLanguageCode) {
    let claims = credential.clusters.first?.claims ?? []
    for claim in claims {
      let claimDisplay = claim.preferredDisplay
      XCTAssertNotNil(claimDisplay)
      guard let claimDisplay else { fatalError("claim display is nil") }
      XCTAssertTrue(claimDisplay.locale?.starts(with: "\(expectedLanguageCode)-") ?? false)
    }
  }

}

// swiftlint:enable all
