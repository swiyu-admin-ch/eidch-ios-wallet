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

  func testInit_swiyuDid_returnsSwiyuCredential() {
    for didMethod in ["tdw", "webvh"] {
      let issuer = "did:\(didMethod):mock=:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:123"

      let credential = VerifiableCredential(progressionState: .accepted, payload: "payload".data(using: .utf8)!, format: "format", issuer: issuer)

      XCTAssertEqual(credential.environment, .swiyu, "didMethod: \(didMethod)")
    }
  }

  func testInit_swiyuIntDid_returnsSwiyuIntCredential() {
    for didMethod in ["tdw", "webvh"] {
      let issuer = "did:\(didMethod):mock=:identifier-reg.trust-infra.swiyu-int.admin.ch:api:v1:did:123"

      let credential = VerifiableCredential(progressionState: .accepted, payload: "payload".data(using: .utf8)!, format: "format", issuer: issuer)

      XCTAssertEqual(credential.environment, .swiyuInt, "didMethod: \(didMethod)")
    }
  }

  func testInit_externalDid_returnsExternalCredential() {
    let issuer = "did:tdw:mock=:identifier-reg.trust-infra.example.ch:api:v1:did:123"

    let credential = VerifiableCredential(progressionState: .accepted, payload: "payload".data(using: .utf8)!, format: "format", issuer: issuer)

    XCTAssertEqual(credential.environment, .external)
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
      XCTAssertEqual(claimDisplay.name, claim.key)
    }
  }

  // MARK: Private

  private func assertDisplays(credential: VerifiableCredential, expectedLanguageCode: UserLanguageCode) {
    let claims = credential.clusters.first?.claims ?? []
    for claim in claims {
      let claimDisplay = claim.preferredDisplay
      XCTAssertTrue(claimDisplay.locale?.starts(with: "\(expectedLanguageCode)-") ?? false)
    }
  }

}

// swiftlint:enable all
