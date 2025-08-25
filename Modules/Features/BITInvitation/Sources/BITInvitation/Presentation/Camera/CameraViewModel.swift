import AVFoundation
import BITAnalytics
import BITAnyCredentialFormat
import BITCore
import BITCredential
import BITCredentialShared
import BITL10n
import BITNetworking
import BITOpenID
import BITPresentation
import BITQRCode
import Combine
import Factory
import SwiftUI

// MARK: - CameraViewModel

@MainActor
class CameraViewModel: ObservableObject, Vibrating {

  // MARK: Lifecycle

  init(router: InvitationRouterRoutes) {
    self.router = router
    configureBindings()
    session = cameraManager.session
    try? cameraManager.configure()
  }

  init(url: URL, router: InvitationRouterRoutes) {
    self.router = router
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

  // MARK: Private

  @Published private var credential: Credential?
  @Published private var qrCodeObject: AVMetadataMachineReadableCodeObject?

  private var invitationURL: URL?
  private var router: InvitationRouterRoutes
  private var bag: Set<AnyCancellable> = []
  private var previousUrl: String?
  private var hasProcessedInitialURL = false

  @Injected(\.scannerDelay) private var scannerDelay: UInt64
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.fetchCredentialUseCase) private var fetchCredentialUseCase: FetchCredentialUseCaseProtocol
  @Injected(\.processPresentationRequestUseCase) private var processPresentationRequestUseCase: ProcessPresentationRequestUseCaseProtocol
  @Injected(\.getCredentialsCountUseCase) private var getCredentialsCountUseCase: GetCredentialsCountUseCaseProtocol
  @Injected(\.checkInvitationTypeUseCase) private var checkInvitationTypeUseCase: CheckInvitationTypeUseCaseProtocol
  @Injected(\.validateCredentialOfferInvitationUrlUseCase) private var validateCredentialOfferInvitationUrlUseCase: ValidateCredentialOfferInvitationUrlUseCaseProtocol

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
    let context = try await processPresentationRequestUseCase.execute(url: url)

    isTorchEnabled = false
    cameraManager.stop()

    if
      context.hasCompatibleCredentials,
      let id = context.inputDescriptorId
    {
      return try router.compatibleCredentials(for: id, and: context)
    }
    return router.presentationReview(with: context)
  }

  private func processCredentialOffer(url: URL) async throws {
    let credentialOffer = try validateCredentialOfferInvitationUrlUseCase.execute(url)
    let (credential, trustStatement) = try await fetchCredentialUseCase.execute(from: credentialOffer)

    isTorchEnabled = false
    cameraManager.stop()
    router.credentialOffer(credential: credential, trustStatement: trustStatement)
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
    self.error = invitationError
    isErrorPopupPresented = true
    isScanEnabled = true
    isLoading = false

    if case .invalidQRCode = invitationError {
      invitationURL = nil // Keep the torch enabled
    } else {
      resetTorchAndInvitation()
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
