import AVFoundation
import BITAnalytics
import BITAppAuth
import BITCore
import BITCredential
import BITCredentialShared
import BITOpenID
import BITPresentation
import BITQRCode
import Combine
import Factory

// MARK: - CameraViewModel

@MainActor
class CameraViewModel: ObservableObject, Vibrating {

  // MARK: Lifecycle

  init(router: InvitationRouterRoutes, delegate: InvitationDelegate? = nil) {
    self.router = router
    self.delegate = delegate
    configureBindings()
    session = cameraManager.session
    try? cameraManager.configure()
  }

  init(url: URL, router: InvitationRouterRoutes, delegate: InvitationDelegate? = nil) {
    self.router = router
    self.delegate = delegate
    scannerDelay = 0
    invitationURL = url
  }

  deinit {
    cameraManager.stop()
  }

  // MARK: Internal

  @Published var error: InvitationError?
  @Published var isTipPresented = false
  @Published var isLoading = false
  @Published var isErrorPopupPresented = false
  @Published var isScanEnabled = true

  var cameraManager = CameraManager()
  var session = AVCaptureSession()

  @Published var isSessionTimeoutPresented = false

  @Published var isTorchEnabled = false {
    didSet {
      isTorchEnabled ? cameraManager.flashlight.turnOn() : cameraManager.flashlight.turnOff()
    }
  }

  func onAppear() async {
    cameraManager.start()
    isTipPresented = (try? await getCredentialsCountUseCase.execute() == 0) ?? true

    if let url = invitationURL, !hasProcessedInitialURL {
      hasProcessedInitialURL = true
      await setMetadataUrl(url)
    }
  }

  func setMetadataUrl(_ url: URL) async {
    do {
      isLoading = true
      isScanEnabled = false
      invitationURL = url

      try? await Task.sleep(nanoseconds: scannerDelay)
      let invitationType = try checkInvitationTypeUseCase.execute(url: url)

      switch invitationType {
      case .credentialOffer:
        try await processCredentialOffer(url: url)
      case .presentation:
        try await processPresentation(url: url)
      }
    } catch {
      handleError(error)
    }
  }

  func login() {
    router.login(animated: true)
  }

  // MARK: Private

  private weak var delegate: InvitationDelegate?

  @Published private var credential: VerifiableCredential?
  @Published private var qrCodeObject: AVMetadataMachineReadableCodeObject?

  private var invitationURL: URL?
  private var router: InvitationRouterRoutes
  private var bag = Set<AnyCancellable>()
  private var previousUrl: String?
  private var hasProcessedInitialURL = false

  @Injected(\.scannerDelay) private var scannerDelay: UInt64
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.fetchCredentialUseCase) private var fetchCredentialUseCase: FetchCredentialUseCaseProtocol
  @Injected(\.fetchPresentationRequestUseCase) private var fetchPresentationRequestUseCase: FetchPresentationRequestUseCaseProtocol
  @Injected(\.getCredentialsCountUseCase) private var getCredentialsCountUseCase: GetCredentialsCountUseCaseProtocol
  @Injected(\.checkInvitationTypeUseCase) private var checkInvitationTypeUseCase: CheckInvitationTypeUseCaseProtocol
  @Injected(\.validateCredentialOfferInvitationUrlUseCase) private var validateCredentialOfferInvitationUrlUseCase: ValidateCredentialOfferInvitationUrlUseCaseProtocol
  @Injected(\.saveDeferredCredentialUseCase) private var saveDeferredCredentialUseCase: SaveDeferredCredentialUseCaseProtocol

  private func configureBindings() {
    cameraManager.$capturedObject.sink { [weak self] qrcode in
      guard
        let self,
        !isLoading && isScanEnabled,
        let qrcode,
        qrcode != qrCodeObject
      else { return }

      qrCodeObject = qrcode
    }.store(in: &bag)
  }

  private func processPresentation(url: URL) async throws {
    let context = try await fetchPresentationRequestUseCase.execute(url: url)

    isTorchEnabled = false
    cameraManager.stop()

    try router.startPresentation(context: context, delegate: self)
  }

  private func processCredentialOffer(url: URL) async throws {
    let credentialOffer = try validateCredentialOfferInvitationUrlUseCase.execute(url)
    let (credential, trustInformation) = try await fetchCredentialUseCase.execute(from: credentialOffer)

    if let verifiableCredential = credential as? VerifiableCredential, let trustInformation {
      openCredentialOffer(credential: verifiableCredential, trustInformation: trustInformation)
    } else if let deferredCredential = credential as? DeferredCredential {
      try await saveDeferredCredential(deferredCredential)
    }
  }

  private func resetTorchAndInvitation() {
    isTorchEnabled = false
    invitationURL = nil
    hasProcessedInitialURL = false
  }

  private func handleError(_ error: Error) {
    vibrate(.error)
    if error as? CheckInvitationTypeError != .wrongScheme {
      analytics.log(error)
    }
    let invitationError = InvitationError.from(error)
    if error as? UserSessionError == .notLoggedIn {
      isSessionTimeoutPresented = true
    } else {
      self.error = invitationError
      isErrorPopupPresented = true
    }

    isScanEnabled = true
    isLoading = false

    if case .invalidQRCode = invitationError {
      invitationURL = nil // Keep the torch enabled
    } else {
      resetTorchAndInvitation()
    }
  }

  private func openCredentialOffer(credential: VerifiableCredential, trustInformation: TrustInformation) {
    isTorchEnabled = false
    cameraManager.stop()
    router.credentialOffer(credential: credential, trustInformation: trustInformation)
  }

  private func saveDeferredCredential(_ deferredCredential: DeferredCredential) async throws {
    try await saveDeferredCredentialUseCase.execute(for: deferredCredential)

    router.close { [weak self] in
      self?.delegate?.didSaveDeferredCredential()
    }
  }
}

// MARK: - QR Scanner

extension CameraViewModel {

  func didMoveFocusArea(to object: AVMetadataMachineReadableCodeObject) {
    guard
      let urlString = object.stringValue,
      urlString != previousUrl,
      let url = URL(string: urlString)
    else { return }

    previousUrl = urlString
    vibrate(.success)

    Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
      DispatchQueue.main.async { [weak self] in
        self?.previousUrl = nil
      }
    }

    Task {
      await self.setMetadataUrl(url)
    }
  }

}

// MARK: - Navigation || User actions

extension CameraViewModel {

  func close() {
    router.close()
  }

  func closeErrorView() {
    error = nil
    isErrorPopupPresented = false
    isScanEnabled = true
  }

  func closeTipView() {
    isTipPresented = false
  }

  func toggleTorch() {
    isTorchEnabled.toggle()
  }
}

// MARK: PresentationFinishDelegate

extension CameraViewModel: PresentationFinishDelegate {
  func retry() {
    router.pop()
  }

  func cancel() {
    router.close()
  }

  func finish(with state: PresentationRequestResultState) async {
    router.close()
  }
}
