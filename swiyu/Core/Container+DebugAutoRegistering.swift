#if DEBUG
import BITTheming
import Factory
import Foundation
import RealmSwift
import UIKit
@testable import BITAppAuth
@testable import BITCredential
@testable import BITDataStore
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITHome
@testable import BITInvitation
@testable import BITJWT
@testable import BITNetworking
@testable import BITOpenID

enum Argument: String, CaseIterable {
  case disableDevicePin = "-disable-device-pin"
  case disableSecureEnclave = "-disable-secure-enclave"
  case disableUserInactivityTimeout = "-disable-user-inactivity-timeout"
  case disableDelays = "-disable-delays"
  case disableOnboarding = "-disable-onboarding"
  case disableLockWallet = "-disable-lock-wallet"
}

// MARK: - Container + AutoRegistering

extension Container: AutoRegistering {
  @MainActor
  public func autoRegister() {
    if ProcessInfo().arguments.contains(Argument.disableDevicePin.rawValue) {
      hasDevicePinUseCase.register { MockHasDevicePinUseCase(true) }
    }

    if ProcessInfo().arguments.contains(Argument.disableSecureEnclave.rawValue) {
      pepperKeyVaultOptions.register { .savePermanently }
    }

    if ProcessInfo().arguments.contains(Argument.disableUserInactivityTimeout.rawValue) {
      userInactivityTimeout.register { .infinity }
    }

    if ProcessInfo().arguments.contains(Argument.disableDelays.rawValue) {
      delayAfterAcceptingCredential.register { 0 }
      loadingDelay.register { 0 }
    }

    if ProcessInfo().arguments.contains(Argument.disableLockWallet.rawValue) {
      lockDelay.register { 0 }
      attemptsLimit.register { 999 }
      lockWalletUseCase.register { MockLockWalletUseCase() }
    }
  }
}

#endif
