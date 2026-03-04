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
public class CameraViewModel: ObservableObject, Vibrating {

  // MARK: Lifecycle

  public init(router: InvitationRouterRoutes, delegate: InvitationDelegate? = nil) {
    self.router = router
    self.delegate = delegate
    configureBindings()
    session = cameraManager.session
    try? cameraManager.configure()
  }

  public init(url: URL, router: InvitationRouterRoutes, delegate: InvitationDelegate? = nil) {
    self.router = router
    self.delegate = delegate
    scannerDelay = 0
    invitationURL = url
  }

  deinit {
    cameraManager.stop()
  }

  // MARK: Public

  @Published public var isTipPresented = false
  @Published public var isLoading = false
  @Published public var isErrorPopupPresented = false
  @Published public var isScanEnabled = true
  public var cameraManager = CameraManager()
  public var session = AVCaptureSession()

  @Published public var isSessionTimeoutPresented = false

  @Published public var isTorchEnabled = false {
    didSet {
      isTorchEnabled ? cameraManager.flashlight.turnOn() : cameraManager.flashlight.turnOff()
    }
  }

  public var currentError: Error? {
    error
  }

  public var currentInvitationURL: URL? {
    invitationURL
  }

  public func onAppear() async {
    cameraManager.start()
    isTipPresented = (try? await getCredentialsCountUseCase.execute() == 0) ?? true

    if let url = invitationURL, !hasProcessedInitialURL {
      hasProcessedInitialURL = true
      await setMetadataUrl(url)
    }
  }

  public func setMetadataUrl(_ url: URL) async {
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

  public func login() {
    router.login(animated: true)
  }

  // MARK: Internal

  @Published var error: Error?

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
  @Injected(\.invitationErrorMapper) private var invitationErrorMapper: InvitationErrorMapping
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
    let mappedError = invitationErrorMapper(error)
    if error as? UserSessionError == .notLoggedIn {
      isSessionTimeoutPresented = true
    } else {
      self.error = mappedError
      isErrorPopupPresented = true
    }

    isScanEnabled = true
    isLoading = false

    if case .invalidQRCode = mappedError as? InvitationError {
      invitationURL = nil // Keep the torch enabled
    } else {
      resetTorchAndInvitation()
    }
  }

  private func openCredentialOffer(credential: VerifiableCredential, trustInformation: TrustInformation) {
    isTorchEnabled = false
    cameraManager.stop()
    router.credentialOffer(credential: credential, trustInformation: trustInformation, delegate: delegate)
  }

  private func saveDeferredCredential(_ deferredCredential: DeferredCredential) async throws {
    try await saveDeferredCredentialUseCase.execute(for: deferredCredential)

    router.close { [weak self] in
      self?.delegate?.didSaveCredential()
    }
  }
}

// MARK: - QR Scanner

extension CameraViewModel {

  public func didMoveFocusArea(to object: AVMetadataMachineReadableCodeObject) {
    guard
      isScanEnabled,
      !isLoading,
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

  public func close() {
    router.close()
  }

  public func closeErrorView() {
    error = nil
    isErrorPopupPresented = false
    isScanEnabled = true
  }

  public func closeTipView() {
    isTipPresented = false
  }

  public func toggleTorch() {
    isTorchEnabled.toggle()
  }
}

// MARK: PresentationFinishDelegate

extension CameraViewModel: PresentationFinishDelegate {
  public func retry() {
    router.pop()
  }

  public func cancel() {
    router.close()
  }

  public func finish(with state: PresentationRequestResultState) async {
    router.close()
  }
}
