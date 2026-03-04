import BITCore
import Factory
import Foundation
import XCTest
@testable import BITAppAuth

// MARK: - ValidateBiometricUseCaseTests

final class IsBiometricInvalidatedUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    isBiometricUsageAllowed = IsBiometricUsageAllowedUseCaseProtocolSpy()
    hasBiometricAuth = HasBiometricAuthUseCaseProtocolSpy()
    uniquePassphraseManager = UniquePassphraseManagerProtocolSpy()

    Container.shared.isBiometricUsageAllowedUseCase.register { self.isBiometricUsageAllowed }
    Container.shared.hasBiometricAuthUseCase.register { self.hasBiometricAuth }
    Container.shared.uniquePassphraseManager.register { self.uniquePassphraseManager }

    useCase = IsBiometricInvalidatedUseCase()
  }

  func testBiometricAreValid() {
    uniquePassphraseManager.existsForReturnValue = true
    isBiometricUsageAllowed.executeReturnValue = true
    hasBiometricAuth.executeReturnValue = true

    let isInvalidated = useCase.execute()
    XCTAssertFalse(isInvalidated)
    XCTAssertTrue(uniquePassphraseManager.existsForCalled)
    XCTAssertTrue(isBiometricUsageAllowed.executeCalled)
    XCTAssertTrue(hasBiometricAuth.executeCalled)
  }

  func testBiometricInvalid_uniquePassphraseMissing() {
    uniquePassphraseManager.existsForReturnValue = false
    isBiometricUsageAllowed.executeReturnValue = true
    hasBiometricAuth.executeReturnValue = true

    let isInvalidated = useCase.execute()
    XCTAssertTrue(isInvalidated)
    XCTAssertTrue(uniquePassphraseManager.existsForCalled)
    XCTAssertTrue(isBiometricUsageAllowed.executeCalled)
    XCTAssertTrue(hasBiometricAuth.executeCalled)
  }

  func testBiometricAreValid_isBiometricUsageForbidden() {
    uniquePassphraseManager.existsForReturnValue = true
    isBiometricUsageAllowed.executeReturnValue = false
    hasBiometricAuth.executeReturnValue = true

    let isInvalidated = useCase.execute()
    XCTAssertFalse(isInvalidated)
    XCTAssertTrue(uniquePassphraseManager.existsForCalled)
    XCTAssertTrue(isBiometricUsageAllowed.executeCalled)
    XCTAssertFalse(hasBiometricAuth.executeCalled)
  }

  func testBiometricAreValid_hasNoBiometricAuth() {
    uniquePassphraseManager.existsForReturnValue = true
    isBiometricUsageAllowed.executeReturnValue = true
    hasBiometricAuth.executeReturnValue = false

    let isInvalidated = useCase.execute()
    XCTAssertFalse(isInvalidated)
    XCTAssertTrue(uniquePassphraseManager.existsForCalled)
    XCTAssertTrue(isBiometricUsageAllowed.executeCalled)
    XCTAssertTrue(hasBiometricAuth.executeCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var useCase: IsBiometricInvalidatedUseCase!
  private var isBiometricUsageAllowed: IsBiometricUsageAllowedUseCaseProtocolSpy!
  private var hasBiometricAuth: HasBiometricAuthUseCaseProtocolSpy!
  private var uniquePassphraseManager: UniquePassphraseManagerProtocolSpy!
  // swiftlint:enable all

}
