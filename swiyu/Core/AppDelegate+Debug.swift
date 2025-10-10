#if DEBUG
import Factory
import Foundation
import RealmSwift
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
  public func autoRegister() {
    if ProcessInfo().arguments.contains(Argument.disableDevicePin.rawValue) {
      hasDevicePinUseCase.register { MockHasDevicePinUseCase(true) }
    }

    if ProcessInfo().arguments.contains(Argument.disableSecureEnclave.rawValue) {
      pepperKeyVaultOptions.register { .savePermanently }
    }

    if ProcessInfo().arguments.contains(Argument.disableUserInactivityTimeout.rawValue) {
      userInactivityTimeout.register { 60 * 60 }
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

    // swiftlint: disable force_unwrapping
    Container.shared.getEIDRequestCaseFilesUseCase.onDebug { _ in
      let useCase = GetEIDRequestCaseFilesUseCaseProtocolSpy()
      useCase.executeCaseIdReturnValue = [
        EIDRequestCaseFile(fileName: "something.jpg", mime: .jpg, data: "jpg".data(using: .utf8)!, category: .documentScan),
        EIDRequestCaseFile(fileName: "something1.jpg", mime: .jpg, data: "jpg".data(using: .utf8)!, category: .documentScan),
        EIDRequestCaseFile(fileName: "something2.jpg", mime: .jpg, data: "jpg".data(using: .utf8)!, category: .documentScan),
        EIDRequestCaseFile(fileName: "something3.jpg", mime: .jpg, data: "jpg".data(using: .utf8)!, category: .documentScan),
        EIDRequestCaseFile(fileName: "something4.jpg", mime: .jpg, data: "jpg".data(using: .utf8)!, category: .documentScan),
        EIDRequestCaseFile(fileName: "something5.jpg", mime: .jpg, data: "jpg".data(using: .utf8)!, category: .documentScan),
      ]
      return useCase
    }

    Container.shared.submitEIDRequestFileUseCase.onDebug { _ in
      let useCase = SubmitEIDRequestFileUseCaseProtocolSpy()
      useCase.executeCaseIdFileAuthJwtClosure = { _, _, _, _ in
        let durations: [UInt64] = [1_000_000_000, 2_000_000_000, 3_000_000_000]
        let randomDuration = durations.randomElement()!
        try await Task.sleep(nanoseconds: randomDuration)
      }
      return useCase
    }
    // swiftlint: enable force_unwrapping
  }
}

#endif
