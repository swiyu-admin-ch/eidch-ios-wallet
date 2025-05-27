import BITCore
import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialMocks
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITOpenID
@testable import BITTestingCore

final class CredentialDetailBodyTests: XCTestCase {

  override func setUp() {
    super.setUp()
    Container.shared.preferredUserLocales.reset()
  }

  func testLoadSampleCredentialHappyPath() throws {
    Container.shared.preferredUserLocales.register { [UserLocale.LocaleIdentifier.swissGerman.rawValue] }
    let languageCode = UserLanguageCode.LanguageIdentifier.german.rawValue
    let mockCredential = Credential.Mock.sample

    let credentialDetailBody = CredentialDetailBody(from: mockCredential)

    XCTAssertEqual(mockCredential.preferredDisplay?.name, credentialDetailBody.display.name)
    XCTAssertEqual(mockCredential.claims.count, credentialDetailBody.claims.count)
    XCTAssertEqual(mockCredential.status, credentialDetailBody.status)
    for claim in mockCredential.claims {
      _ = claim.displays.first(where: {
        guard let locale = $0.locale else { return false }
        return locale.starts(with: "\(languageCode)-")
      })
      XCTAssertTrue(credentialDetailBody.claims.contains(where: { $0.value == claim.value }))

      guard let valueType = ValueType(rawValue: claim.valueType) else {
        fatalError("Error creating value type")
      }

      XCTAssertTrue(credentialDetailBody.claims.contains(where: { $0.type == valueType }))
    }
  }

  func testLoadMultipassCredentialHappyPath() throws {
    let mockCredential = Credential.Mock.sample
    let credentialDetailBody = CredentialDetailBody(from: mockCredential)
    XCTAssertEqual(mockCredential.claims.count, credentialDetailBody.claims.count)
  }

  func testLoadDiplomaCredentialHappyPath() throws {
    Container.shared.preferredUserLocales.register { [UserLocale.LocaleIdentifier.swissGerman.rawValue] }
    let languageCode = UserLanguageCode.LanguageIdentifier.german.rawValue
    let mockCredential = Credential.Mock.diploma
    let credentialDetailBody = CredentialDetailBody(from: mockCredential)

    XCTAssertEqual(mockCredential.preferredDisplay?.name, credentialDetailBody.display.name)
    XCTAssertEqual(mockCredential.claims.count, credentialDetailBody.claims.count)
    XCTAssertEqual(mockCredential.status, credentialDetailBody.status)
    for claim in mockCredential.claims {
      _ = claim.displays.first(where: {
        guard let locale = $0.locale else { return false }
        return locale.starts(with: "\(languageCode)-")
      })
      XCTAssertTrue(credentialDetailBody.claims.contains(where: { $0.value == claim.value }))

      guard let valueType = ValueType(rawValue: claim.valueType) else {
        fatalError("Error creating value type")
      }

      XCTAssertTrue(credentialDetailBody.claims.contains(where: { $0.type == valueType }))
    }
  }

  func testLoadCredentialDefaultLanguage() throws {
    let unmanagedCode = "cz"
    Container.shared.preferredUserLocales.register { [unmanagedCode] }
    let germanLanguageCode = UserLanguageCode.LanguageIdentifier.german.rawValue
    let unmanagedLanguageCode: UserLanguageCode = "cz"
    let mockCredential = Credential.Mock.sample

    let credentialDetailBody = CredentialDetailBody(from: mockCredential)

    XCTAssertEqual(mockCredential.preferredDisplay?.name, credentialDetailBody.display.name)
    XCTAssertEqual(mockCredential.status, credentialDetailBody.status)
    for claim in mockCredential.claims {
      let unManagedDisplay = claim.displays.first(where: {
        guard let locale = $0.locale else { return false }
        return locale.starts(with: "\(unmanagedLanguageCode)-")
      })
      let defaultDisplay = claim.displays.first(where: {
        guard let locale = $0.locale else { return false }
        return locale.starts(with: "\(germanLanguageCode)-")
      })

      XCTAssertNil(unManagedDisplay)
      XCTAssertNotNil(defaultDisplay)

      XCTAssertTrue(credentialDetailBody.claims.contains(where: { $0.value == claim.value }))

      guard let valueType = ValueType(rawValue: claim.valueType) else {
        fatalError("Error creating value type")
      }

      XCTAssertTrue(credentialDetailBody.claims.contains(where: { $0.type == valueType }))
    }
  }

  func testLoadCredentialNoDisplays() throws {
    let unmanagedCode = "cz"
    Container.shared.preferredUserLocales.register { [unmanagedCode] }
    let germanLanguageCode = UserLanguageCode.LanguageIdentifier.german.rawValue
    let unmanagedLanguageCode: UserLanguageCode = "cz"
    let mockCredential = Credential.Mock.sampleDisplaysEmpty

    let credentialDetailBody = CredentialDetailBody(from: mockCredential)

    // Ensure that the default text of a claim without translations is "not assigned"
    XCTAssertEqual(L10n.tkGlobalNotAssigned, credentialDetailBody.display.name)

    XCTAssertEqual(mockCredential.claims.count, credentialDetailBody.claims.count)
    XCTAssertEqual(mockCredential.status, credentialDetailBody.status)
    for claim in mockCredential.claims {
      let unManagedDisplay = claim.displays.first(where: {
        guard let locale = $0.locale else { return false }
        return locale.starts(with: "\(unmanagedLanguageCode)-")
      })
      let defaultDisplay = claim.displays.first(where: {
        guard let locale = $0.locale else { return false }
        return locale.starts(with: "\(germanLanguageCode)-")
      })

      XCTAssertNil(unManagedDisplay)
      XCTAssertNil(defaultDisplay)

      XCTAssertTrue(credentialDetailBody.claims.contains(where: { $0.key == claim.key }))
      XCTAssertTrue(credentialDetailBody.claims.contains(where: { $0.value == claim.value }))

      guard let valueType = ValueType(rawValue: claim.valueType) else {
        fatalError("Error creating value type")
      }

      XCTAssertTrue(credentialDetailBody.claims.contains(where: { $0.type == valueType }))
    }
  }

}
