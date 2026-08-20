import AVFoundation
import BITAnalytics
import BITCore
import BITCredential
import BITCredentialShared
import BITOpenID
import BITQRCode
import BITTheming
import Combine
import CoreBluetooth
import Factory
import NavigatorUI

// MARK: - CameraViewModel

@MainActor
@Observable
public class CameraViewModel: Vibrating {

  // MARK: Lifecycle

  public init() {
    errorDestinationStyle = .managedSheet
    configureBindings()
  }

  public init(url: URL) {
    errorDestinationStyle = .push
    scannerDelay = 0
    invitationURL = url
  }

  deinit {
    cameraManager.stop()
    proximityTask?.cancel()
  }

  // MARK: Public

  public var isLoading = false
  @ObservationIgnored nonisolated(unsafe) public var cameraManager = CameraManager()
  public var destination: InvitationDestinations?

  public var currentError: Error? {
    error
  }

  public var currentInvitationURL: URL? {
    invitationURL
  }

  public func onAppear() async {
    if let url = invitationURL, !hasProcessedInitialURL { // Deeplink case
      hasProcessedInitialURL = true
      return await setMetadataUrl(url)
    }

    guard isCameraReady else { return }

    try? cameraManager.configure()
    cameraManager.start()
    accessibilityFeedback.announceCameraDidStartRunning()

    guard await (try? getCredentialsCountUseCase() == 0) ?? true else { return }
    notificationState = .tip
  }

  public func onCameraPermissionChange(_ permission: AVAuthorizationStatus) async {
    isCameraReady = permission == .authorized
    await onAppear()
  }

  // MARK: Internal

  enum NotificationState: Equatable {
    case tip, failure(error: Error)

    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.tip, .tip):
        true
      case (.failure(let lhsError), .failure(let rhsError)):
        lhsError.localizedDescription == rhsError.localizedDescription
      default:
        false
      }
    }
  }

  var notificationState: NotificationState?
  var isScanEnabled = true
  var onDismiss = false
  var isBluetoothPermissionRequired = false

  private(set) var error: Error?

  var isTorchEnabled = false {
    didSet {
      isTorchEnabled ? cameraManager.flashlight.turnOn() : cameraManager.flashlight.turnOff()
    }
  }

  func setMetadataUrl(_ url: URL) async {
    accessibilityFeedback.announceQRCodeDetected()
    defer {
      accessibilityFeedback.stopQRCodeLoadingAnnouncements()
    }

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
      case .proximityEngagement:
        try await processProximityEngagement(url: url)
      }
    } catch {
      handleError(error)
    }
  }

  func resetProximityEngagementIfNeeded() {
    proximityTask?.cancel()
    proximityTask = nil
  }

  // MARK: Private

  private var invitationURL: URL?
  private var bag = Set<AnyCancellable>()
  private let errorDestinationStyle: ErrorDestinationStyle

  private var credential: VerifiableCredential?
  private var qrCodeObject: AVMetadataMachineReadableCodeObject?

  @ObservationIgnored nonisolated(unsafe) private var proximityTask: Task<Void, Never>?
  private var previousUrl: String?
  private var hasProcessedInitialURL = false
  private var isCameraReady = false

  @ObservationIgnored @Injected(\.scannerDelay) private var scannerDelay: UInt64
  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.fetchCredentialUseCase) private var fetchCredentialUseCase: FetchCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.fetchPresentationRequestUseCase) private var fetchPresentationRequestUseCase: FetchPresentationRequestUseCaseProtocol
  @ObservationIgnored @Injected(\.getCredentialsCountUseCase) private var getCredentialsCountUseCase: GetCredentialsCountUseCaseProtocol
  @ObservationIgnored @Injected(\.checkInvitationTypeUseCase) private var checkInvitationTypeUseCase: CheckInvitationTypeUseCaseProtocol
  @ObservationIgnored @Injected(\.validateCredentialOfferInvitationUrlUseCase) private var validateCredentialOfferInvitationUrlUseCase: ValidateCredentialOfferInvitationUrlUseCaseProtocol
  @ObservationIgnored @Injected(\.saveDeferredCredentialUseCase) private var saveDeferredCredentialUseCase: SaveDeferredCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.invitationErrorMapper) private var invitationErrorMapper: InvitationErrorMapping
  @ObservationIgnored @Injected(\.startProximityEngagementUseCase) private var startProximityEngagementUseCase: StartProximityEngagementUseCaseProtocol
  @ObservationIgnored @Injected(\.isProximityEnabled) private var isProximityEnabled: Bool
  @ObservationIgnored @Injected(\.accessibilityFeedback) private var accessibilityFeedback: CameraAccessibilityFeedbackProtocol

  private func configureBindings() {
    observeCapturedObject()
  }

  private func observeCapturedObject() {
    withObservationTracking {
      _ = cameraManager.capturedObject
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in
        guard let self else { return }

        defer { observeCapturedObject() }

        guard
          !isLoading && isScanEnabled,
          let qrcode = cameraManager.capturedObject,
          qrcode != qrCodeObject
        else { return }

        qrCodeObject = qrcode
      }
    }
  }

  private func processPresentation(url: URL) async throws {
    let context = try await fetchPresentationRequestUseCase(url: url)

    isTorchEnabled = false
    cameraManager.stop()
    accessibilityFeedback.announceCameraDidStopRunning()

    destination = .external(.presentation(context))
  }

  private func processCredentialOffer(url: URL) async throws {
    let credentialOffer = try validateCredentialOfferInvitationUrlUseCase.execute(url)
    let credential = try await fetchCredentialUseCase.execute(from: credentialOffer)

    if let verifiableCredential = credential as? VerifiableCredential {
      openCredentialOffer(credential: verifiableCredential)
    } else if let deferredCredential = credential as? DeferredCredential {
      try await saveDeferredCredential(deferredCredential)
    }
  }

  private func resetTorchAndInvitation() {
    isTorchEnabled = false
    invitationURL = nil
    hasProcessedInitialURL = false
  }

  private func processProximityEngagement(url: URL) async throws {
    isTorchEnabled = false
    cameraManager.stop()

    if CBManager.authorization != .allowedAlways {
      isScanEnabled = false
      isBluetoothPermissionRequired = true

      await MainActor.run {
        isLoading = false
      }
      return
    }

    startObservingProximityState()
  }

  private func startObservingProximityState() {
    proximityTask?.cancel()
    proximityTask = Task { [weak self] in
      guard
        let url = self?.invitationURL?.absoluteString,
        let stream = self?.startProximityEngagementUseCase(qrCode: url) else { return }

      do {
        for try await event in stream {
          try self?.handleProximityEvent(event)
        }
      } catch is CancellationError {
        // ignore
      } catch {
        self?.handleError(error)
      }
    }
  }

  private func handleProximityEvent(_ event: ProximityEngagementEvent) throws {
    switch event {
    case .qrCode:
      break
    case .request(let context):
      isLoading = false
      destination = .external(.presentation(context))
    }
  }

  private func handleError(_ error: Error) {
    let presentationResponse = (error as? FetchPresentationRequestUseCaseError)?.presentationResponse

    vibrate(.error)
    if error as? CheckInvitationTypeError != .wrongScheme {
      analytics.log(error)
    }
    let mappedError = invitationErrorMapper(error) as? InvitationError ?? .invalidQRCode()
    self.error = mappedError

    isLoading = false
    isScanEnabled = true

    // full screen error or toast
    if let errorDataset = mappedError.errorDataset {
      destination = errorDestination(errorDataset, presentationResponse: presentationResponse)
    } else {
      notificationState = .failure(error: mappedError)
    }

    if mappedError == .invalidQRCode() {
      invitationURL = nil // Keep the torch enabled
    } else {
      resetTorchAndInvitation()
    }
  }

  private func errorDestination(_ errorDataset: ErrorDataset, presentationResponse: PresentationResponse?) -> InvitationDestinations {
    let onClose = Callback<Void> { [weak self] in
      Task { @MainActor [weak self] in
        self?.closeErrorView()
      }
    }

    switch errorDestinationStyle {
    case .managedSheet:
      return .error(errorDataset, onClose, presentationResponse)
    case .push:
      return .deeplinkError(errorDataset, onClose, presentationResponse)
    }
  }

  private func openCredentialOffer(credential: VerifiableCredential) {
    isTorchEnabled = false
    cameraManager.stop()
    accessibilityFeedback.announceCameraDidStopRunning()
    vibrate(.success)
    destination = .offer(credential)
  }

  private func saveDeferredCredential(_ deferredCredential: DeferredCredential) async throws {
    try await saveDeferredCredentialUseCase.execute(for: deferredCredential)
    onDismiss = true
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
    notificationState = nil

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
  func closeErrorView() {
    error = nil
    notificationState = nil
    destination = nil
    isScanEnabled = true
    cameraManager.start()
  }

  func closeTipView() {
    notificationState = nil
  }

  func toggleTorch() {
    isTorchEnabled.toggle()
  }
}

// MARK: CameraViewModel.ErrorDestinationStyle

extension CameraViewModel {
  fileprivate enum ErrorDestinationStyle {
    case managedSheet
    case push
  }
}
