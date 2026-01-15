import BITAppInfo
import BITCore
import BITL10n
import Combine
import Factory
import SwiftUI

// MARK: - LoginViewModel

@MainActor
public class LoginViewModel: ObservableObject {

  // MARK: Lifecycle

  public init(router: LoginRouterRoutes, state: ViewState = ViewState.loginBiometrics) {
    self.router = router
    self.state = state

    updateBiometricContext()
    configureObservers()
    restoreAttempts()
    evaluateLockedWallet()

    NotificationCenter.default.post(name: .loginRequired, object: nil)
  }

  // MARK: Public

  public enum ViewState {
    case loginBiometrics
    case loginPassword
    case locked
    case loading
  }

  // MARK: Internal

  @Published var isBiometricAuthenticationAvailable = false
  @Published var isBiometricTriggered = false
  @Published var biometricType = BiometricType.faceID
  @Published var pinCode: PinCode = ""
  @Published var pinCodeState = PinCodeState.normal
  @Published var biometricAttempts = 0
  @Published var attempts = 0
  @Published var countdown: TimeInterval?

  @Published var state: ViewState

  @Injected(\.attemptsLimit) var attemptsLimit: Int

  var inputFieldMessage: String {
    "\(pinCodeState == .error ? L10n.tkLoginPasswordfailedNotification : "") \(L10n.tkLoginPasswordfailedIosSubtitle(attemptsLeft))"
  }

  var timeLeft: String? {
    guard let countdown else { return nil }
    let date = Date(timeInterval: countdown, since: .now)
    let timeLeft = date.timeIntervalSince(.now)
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = timeLeft <= 60 ? [.second] : [.minute]
    let value = formatter.string(from: timeLeft) ?? ""
    return timeLeft <= 60 ? L10n.tkLoginLockedBodySecondsIos(value) : L10n.tkLoginLockedBodyIos(value)
  }

  var isLocked: Bool {
    guard let countdown else { return false }
    return countdown >= 1 && countdown <= lockDelay
  }

  var attemptsLeft: Int {
    attemptsLimit - attempts
  }

  func openHelp() {
    guard let url = URL(string: L10n.tkLoginLockedSecondarybuttonValue) else { return }
    router.openExternalLink(url: url)
  }

  func pinCodeAuthentication() {
    if pinCode.isEmpty { return }

    guard (try? useCases.loginPinCode.execute(from: pinCode)) != nil else {
      return loginWithPasswordFailed()
    }

    didLogin()
  }

  // MARK: Private

  @Injected(\.loginUseCases) private var useCases: LoginUseCasesProtocol
  @Injected(\.awaitTimeBeforeBiometrics) private var awaitTimeOnAppear: UInt64
  @Injected(\.pinCodeErrorAnimationDuration) private var pinCodeErrorAnimationDuration: CGFloat
  @Injected(\.pinCodeObserverDelay) private var pinCodeObserverDelay: CGFloat
  @Injected(\.lockDelay) private var lockDelay: TimeInterval
  @Injected(\.loadingDelay) private var loadingDelay: UInt64
  @Injected(\.pinCodeSize) private var pinCodeSize: Int

  private var timer: Timer?
  private let router: LoginRouterRoutes

  private var bag = Set<AnyCancellable>()

  private func configureObservers() {
    $pinCode
      .filter { [weak self] in !$0.isEmpty && self?.pinCodeState == .error }
      .delay(for: .seconds(pinCodeObserverDelay), scheduler: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.pinCodeState = .normal
      }.store(in: &bag)

    NotificationCenter.default.addObserver(forName: .willEnterForeground, object: nil, queue: .main) { [weak self] _ in
      Task { @MainActor in
        self?.startCountdown()
      }
    }

    NotificationCenter.default.addObserver(forName: .didEnterBackground, object: nil, queue: .main) { [weak self] _ in
      Task { @MainActor in
        self?.stopCountdown()
      }
    }
  }

  private func didLogin() {
    state = .loading

    unlockApp()

    Task {
      try? await Task.sleep(nanoseconds: loadingDelay)
      if let versionEnforcement = await checkVersionEnforcement() {
        return router.versionEnforcement(versionEnforcement)
      }

      close()
    }
  }

  private func close() {
    router.close(onComplete: {
      NotificationCenter.default.post(name: .didLoginClose, object: nil)
    })
  }

  private func loginWithPasswordFailed() {
    pinCodeState = .error
    withAnimation {
      pinCode = ""
      vibrate()
      registerLoginAttempt()
    }
  }

  private func resetState() {
    resetAttempts()
    timer?.invalidate()
    timer = nil
    pinCode = ""
    countdown = nil
    pinCodeState = .normal
    isBiometricTriggered = false
  }

  private func resetAttempts() {
    try? useCases.resetLoginAttemptCounterUseCase.execute()
    attempts = 0
    biometricAttempts = 0
  }

}

// MARK: - Lock login

extension LoginViewModel {

  private func startCountdown() {
    guard timer == nil else { return }

    countdown = useCases.getLockedWalletTimeLeftUseCase.execute()

    if let countdown, countdown <= 0 {
      state = .loginPassword
      unlockApp()
    }

    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
      Task { @MainActor [weak self] in
        guard let self else { return }
        countdown = useCases.getLockedWalletTimeLeftUseCase.execute()

        if !isLocked {
          state = .loginPassword
          unlockApp()
        }
      }
    })
  }

  private func stopCountdown() {
    timer?.invalidate()
    timer = nil
  }

  private func evaluateLockedWallet() {
    countdown = useCases.getLockedWalletTimeLeftUseCase.execute()
    let tooManyAttempts = (attempts >= attemptsLimit || biometricAttempts >= attemptsLimit)

    if isLocked {
      state = .locked
      return startCountdown()
    }

    guard let countdown else { return }

    let deviceWasRebooted = countdown > lockDelay && tooManyAttempts
    let countdownFinishedWhenAppKilled = countdown < 1 && tooManyAttempts

    if deviceWasRebooted {
      lockApp() // re-lock the app
    } else if countdownFinishedWhenAppKilled {
      unlockApp()
      state = .loginPassword
    }
  }

  private func unlockApp() {
    do {
      try useCases.unlockWalletUseCase.execute()
      resetState()
    } catch {}
  }

  private func lockApp() {
    do {
      try useCases.lockWalletUseCase.execute()
      state = .locked
      startCountdown()
    } catch {}
  }

  private func restoreAttempts() {
    attempts = (try? useCases.getLoginAttemptCounterUseCase.execute(kind: .appPin)) ?? 0
    biometricAttempts = (try? useCases.getLoginAttemptCounterUseCase.execute(kind: .biometric)) ?? 0
  }

  private func registerLoginAttempt() {
    attempts = (try? useCases.registerLoginAttemptCounterUseCase.execute(kind: .appPin)) ?? attempts + 1
    evaluateAttempts(attempts)
  }

  private func registerBiometricAttempt() {
    if let attempts = try? useCases.registerLoginAttemptCounterUseCase.execute(kind: .biometric) {
      biometricAttempts = attempts
    } else {
      biometricAttempts += 1
    }

    evaluateAttempts(biometricAttempts)
  }

  private func evaluateAttempts(_ attempts: Int) {
    guard attempts >= attemptsLimit else { return }
    lockApp()
  }

}

// MARK: - Version enforcement

extension LoginViewModel {
  private func checkVersionEnforcement() async -> VersionEnforcement? {
    try? await useCases.fetchVersionEnforcementUseCase.execute()
  }
}

// MARK: - Biometrics

extension LoginViewModel {

  // MARK: Internal

  func biometricViewDidAppear() {
    Task {
      try? await Task.sleep(nanoseconds: awaitTimeOnAppear)
      await promptBiometricAuthentication()
    }
  }

  func promptBiometricAuthentication() async {
    guard
      isBiometricAuthenticationAvailable,
      !isBiometricTriggered
    else { return }

    isBiometricTriggered = true
    do {
      try await useCases.loginBiometric.execute()
      didLogin()
    } catch {
      isBiometricTriggered = false
      guard state != .locked else { return }

      state = .loginPassword
      registerBiometricAttempt()
    }
  }

  // MARK: Private

  private func updateBiometricContext() {
    isBiometricAuthenticationAvailable = useCases.isBiometricUsageAllowed.execute()
      && useCases.hasBiometricAuth.execute()
      && !useCases.isBiometricInvalidatedUseCase.execute()

    biometricType = useCases.getBiometricTypeUseCase.execute()

    if biometricType == .none || !isBiometricAuthenticationAvailable {
      state = .loginPassword
    }
  }

}

// MARK: Vibrating

extension LoginViewModel: Vibrating {}
