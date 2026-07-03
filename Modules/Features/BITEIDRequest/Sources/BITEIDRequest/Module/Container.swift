import BITAVWrapper
import BITEIDRequestShared
import Factory
import Foundation
import NavigatorUI
import Spyable

@MainActor
extension Container {

  // MARK: Public

  public var eIDRequestExternalViewProvider: Factory<(any NavigationViewProviding<EIDRequestExternalDestination>)?> {
    self { nil }
  }

  // MARK: Internal

  var scanDocumentViewModel: Factory<ScanDocumentViewModel> {
    self { @MainActor in ScanDocumentViewModel() }
  }

  var scanDocumentSubmitViewModel: ParameterFactory<ScanDocumentOutput, ScanDocumentSubmitViewModel> {
    self { @MainActor in ScanDocumentSubmitViewModel(scanDocumentOutput: $0) }
  }

  var scanDocumentImageOverviewViewModel: ParameterFactory<ScanResultEntryImage, ScanDocumentImageOverviewViewModel> {
    self { @MainActor in ScanDocumentImageOverviewViewModel(image: $0) }
  }

  var recordDocumentViewModel: Factory<RecordDocumentViewModel> {
    self { @MainActor in RecordDocumentViewModel() }
  }

  var recordSelfieViewModel: Factory<RecordSelfieViewModel> {
    self { @MainActor in RecordSelfieViewModel() }
  }

  var queueInformationViewModel: ParameterFactory<Date, QueueInformationViewModel> {
    self { QueueInformationViewModel(onlineSessionStartDate: $0) }
  }

  var walletPairingViewModel: Factory<WalletPairingViewModel> {
    self { @MainActor in WalletPairingViewModel() }
  }

  var walletPairingListViewModel: ParameterFactory<String, WalletPairingListViewModel> {
    self { @MainActor in WalletPairingListViewModel(caseId: $0) }
  }

  var avIdentityCheckViewModel: ParameterFactory<String, AVIdentityCheckViewModel> {
    self { AVIdentityCheckViewModel(caseId: $0) }
  }

  var legalRepresentantViewModel: Factory<LegalRepresentantViewModel> {
    self { @MainActor in LegalRepresentantViewModel() }
  }

  var legalRepresentantConsentViewModel: ParameterFactory<String, LegalRepresentantConsentViewModel> {
    self { @MainActor in LegalRepresentantConsentViewModel(caseId: $0) }
  }

  var legalRepresentantVerificationViewModel: ParameterFactory<String, LegalRepresentantVerificationViewModel> {
    self { @MainActor in LegalRepresentantVerificationViewModel(caseId: $0) }
  }

  var legalRepresentantQRCodeViewModel: ParameterFactory<String, LegalRepresentantQRCodeViewModel> {
    self { @MainActor in LegalRepresentantQRCodeViewModel(caseId: $0) }
  }

  var walletPairingOfferViewModel: ParameterFactory<(Void) -> Void, WalletPairingOfferViewModel> {
    self { @MainActor in WalletPairingOfferViewModel($0) }
  }

  var legalRepresentantConsentStateViewModel: ParameterFactory<RequestCaseViewState, LegalRepresentantConsentStateViewModel> {
    self { @MainActor in LegalRepresentantConsentStateViewModel(state: $0) }
  }

  var documentSelectionViewModel: Factory<DocumentSelectionViewModel> {
    self { DocumentSelectionViewModel() }
  }

  var setupViewModel: Factory<SetupViewModel> {
    self {
      #if targetEnvironment(simulator)
      MockSetupViewModel()
      #else
      SetupViewModel()
      #endif
    }
  }

  var setupSDKErrorViewModel: ParameterFactory<(ErrorWrapper, (Void) -> Void), SetupSDKErrorViewModel> {
    self { @MainActor in SetupSDKErrorViewModel(error: $0, callback: $1) }
  }

  var nfcScanViewModel: Factory<NFCScanViewModel> {
    self { @MainActor in NFCScanViewModel() }
  }

  var submitEIDRequestFilesViewModel: Factory<SubmitEIDRequestFilesViewModel> {
    self { @MainActor in SubmitEIDRequestFilesViewModel() }
  }

  var nfcScanResultViewModel: ParameterFactory<AVBeamPackageResult, NFCScanResultViewModel> {
    self { NFCScanResultViewModel(package: $0) }
  }

  var eidRequestFlowCoordinator: Factory<EIDRequestFlowCoordinatorProtocol> {
    self { @MainActor in EIDRequestFlowCoordinator() }.singleton
  }

  var pushPermissionViewModel: ParameterFactory<EIDRequestCase, PushPermissionViewModel> {
    self { @MainActor in PushPermissionViewModel($0) }
  }
}

extension Container {
  public var avBeam: Factory<AVBeamProtocol> {
    self { AVBeam() }.singleton
  }

  public var avBeamAppID: Factory<String> {
    self { "2NG6YF3PM2.ch.admin.foitt.swiyu" }
  }
}

extension Container {

  // MARK: Public

  public var recordDocumentTimeout: Factory<TimeInterval> {
    self { 10 }
  }

  public var recordSelfieTimeout: Factory<TimeInterval> {
    self { 10 }
  }

  public var isEIDRequestFeatureEnabled: Factory<Bool> {
    self { false }
  }

  public var sidBaseUrl: Factory<URL> {
    self {
      guard let url = URL(string: "https://www.sid.admin.ch/sid-web/") else {
        fatalError("No valid URL for SID url")
      }
      return url
    }
  }

  public var avBaseUrl: Factory<URL> {
    self {
      guard let url = URL(string: "https://av.admin.ch/") else {
        fatalError("No valid URL for SID url")
      }
      return url
    }
  }

  public var avSocketUrl: Factory<URL> {
    self {
      guard let url = URL(string: "wss://av.admin.ch/nfc/ws1/validate") else {
        fatalError("No valid socket URL for AV")
      }
      return url
    }
  }

  public var getEIDRequestCaseListUseCase: Factory<GetEIDRequestCaseListUseCaseProtocol> {
    self { GetEIDRequestCaseListUseCase() }
  }

  public var updateEIDRequestCaseStatusUseCase: Factory<UpdateEIDRequestCaseStatusUseCaseProtocol> {
    self { UpdateEIDRequestCaseStatusUseCase() }
  }

  public var deleteEIDRequestCaseUseCase: Factory<DeleteEIDRequestCaseUseCaseProtocol> {
    self { DeleteEIDRequestCaseUseCase() }
  }

  public var updatePushTokenUseCase: Factory<UpdatePushTokenUseCaseProtocol> {
    self { UpdatePushTokenUseCase() }
  }

  // MARK: Internal

  var maxFailedNFCScanAttempts: Factory<Int> {
    self { 3 }
  }

  var applyEIDRequestUseCase: Factory<ApplyEIDRequestUseCaseProtocol> {
    #if targetEnvironment(simulator)
    self { MockApplyEIDRequestUseCase() }
    #else
    self { ApplyEIDRequestUseCase() }
    #endif
  }

  var saveEIDRequestFilesUseCase: Factory<SaveEIDRequestFilesUseCaseProtocol> {
    self { SaveEIDRequestFilesUseCase() }
  }

  var sidAllowedFiles: Factory<[String]> {
    self {
      [
        "fullFrameFirstPage.png",
        "fullFrameSecondPage.png",
        "video.mp4",
        "document.mp4",
        "mobile-result.xml",
        "mobile-result.json",
        "metadata.bin",
      ]
    }
  }

  var sidFilenameMap: Factory<[String: String?]> {
    self {
      [
        "fullFrameFirstPage.png": nil,
        "fullFrameSecondPage.png": nil,
        "video.mp4": nil,
        "docRecVideo.mp4": "document.mp4",
        "result.xml": "mobile-result.xml",
        "result.json": "mobile-result.json",
        "metadata.bin": nil,
      ]
    }
  }

  var scanDelay: Factory<UInt64> {
    self { 1_500_000_000 }
      .context(.test) { 10 }
  }

  var submitEIDRequestFileUseCase: Factory<SubmitEIDRequestFileUseCaseProtocol> {
    self { SubmitEIDRequestFileUseCase() }
  }

  var submitEIDRequestUseCase: Factory<SubmitEIDRequestUseCaseProtocol> {
    self { SubmitEIDRequestUseCase() }
  }

  var getEIDRequestCaseFilesUseCase: Factory<GetEIDRequestCaseFilesUseCaseProtocol> {
    self { GetEIDRequestCaseFilesUseCase() }
  }

  var eidRequestContext: Factory<EIDRequestContext> {
    self { EIDRequestContext() }.shared
  }

  var validateDeviceSecurityRequirementsUseCase: Factory<ValidateDeviceSecurityRequirementsUseCaseProtocol> {
    self { ValidateDeviceSecurityRequirementsUseCase() }
  }

  var fetchEIDRequestCaseUseCase: Factory<FetchEIDRequestCaseUseCaseProtocol> {
    self { FetchEIDRequestCaseUseCase() }
  }

  var deleteEIDRequestCaseFileUseCase: Factory<DeleteEIDRequestCaseFileUseCaseProtocol> {
    self { DeleteEIDRequestCaseFileUseCase() }
  }

  var eIDRequestResponseDecoder: Factory<JSONDecoder> {
    self {
      JSONDecoder(dateDecodingStrategy: .formatted(DateFormatter(format: "yyyy-MM-dd")))
    }
  }

  var eIDRequestAfterOnboardingEnabledRepository: Factory<EIDRequestAfterOnboardingEnabledRepositoryProcotol> {
    self { EIDRequestAfterOnboardingEnabledRepository() }
  }

  var eIDRequestRepository: Factory<EIDRequestRepositoryProtocol> {
    self { EIDRequestRepository() }
  }

  var eIDRequestCaseRepository: Factory<EIDRequestCaseRepositoryProtocol> {
    self { EIDRequestCaseRepository() }
  }

  var requestCasePriorityOrder: Factory<[EIDRequestStatus.State]> {
    self { [
      .autoVerification,
      .issuing,
      .closed,
      .readyForOnlineSession,
      .inTargetWalletPairing,
      .readyForFinalEntitlementCheck,
      .inQueue,
      .refused,
      .unknown,
      .expired,
      .cancelled,
      .agentReview,
    ] }
  }

  var getLegalRepresentantVerificationQRCodeUseCase: Factory<GetLegalRepresentantVerificationQRCodeUseCaseProtocol> {
    self { GetLegalRepresentantVerificationQRCodeUseCase() }
  }

  var getLegalRepresentantPresentationRequestContextUseCase: Factory<GetLegalRepresentantPresentationRequestContextUseCaseProtocol> {
    self { GetLegalRepresentantPresentationRequestContextUseCase() }
  }

  var validateAttestationsUseCase: Factory<ValidateAttestationsUseCaseProtocol> {
    self { ValidateAttestationsUseCase() }
  }

  var startOnlineSessionUseCase: Factory<StartOnlineSessionUseCaseProtocol> {
    self { StartOnlineSessionUseCase() }
  }

  var fetchWalletPairingOfferUseCase: Factory<FetchWalletPairingOfferUseCaseProtocol> {
    self {
      FetchWalletPairingOfferUseCase()
    }
  }

  var pairWalletUseCase: Factory<PairWalletUseCaseProtocol> {
    self { PairWalletUseCase() }
  }

  var fetchWalletPairingStateUseCase: Factory<FetchWalletPairingStateUseCaseProtocol> {
    self {
      FetchWalletPairingStateUseCase()
    }
  }

  var fetchEIDRequestStatusUseCase: Factory<FetchEIDRequestStatusUseCaseProtocol> {
    self { FetchEIDRequestStatusUseCase() }
  }

  var startAutoVerificationUseCase: Factory<StartAutoVerificationUseCaseProtocol> {
    self { StartAutoVerificationUseCase() }
  }

  var walletPairingDateFormatter: Factory<DateFormatter> {
    self { DateFormatter(format: "dd.MM.yyyy HH:mm") }
  }

  var legalRepresentantVerificationService: Factory<LegalRepresentantVerificationServiceProtocol> {
    self { LegalRepresentantVerificationService() }
  }

  var avBeamNFCService: Factory<AVBeamNFCServiceProtocol> {
    self { AVBeamNFCService() }
  }

  var avBeamNFCConfigurator: Factory<AVBeamNFCConfiguratorProtocol> {
    self { AVBeamNFCConfigurator() }
  }

  var fetchNFCScanResultUseCase: Factory<FetchNFCScanResultUseCaseProtocol> {
    self { FetchNFCScanResultUseCase() }
  }

  var updateEIDRequestCaseFilesUseCase: Factory<UpdateEIDRequestCaseFilesUseCaseProtocol> {
    self { UpdateEIDRequestCaseFilesUseCase() }
  }

  var compareScanDocumentOutputUseCase: Factory<CompareScanDocumentOutputUseCaseProtocol> {
    self { CompareScanDocumentOutputUseCase() }
  }

  var updateInputFileUseCase: Factory<UpdateInputFileUseCaseProtocol> {
    self { UpdateInputFileUseCase() }
  }

  var registerPushTokenUseCase: Factory<RegisterPushTokenUseCaseProtocol> {
    self { RegisterPushTokenUseCase() }
  }

  var enablePushNotificationsUseCase: Factory<EnablePushNotificationsUseCaseProtocol> {
    self { @MainActor in EnablePushNotificationsUseCase() }
  }
}

@MainActor
extension Container {

  // MARK: Public

  public var requestCasePollingManager: Factory<RequestCasePollingProtocol> {
    self { @MainActor in RequestCasePollingManager() }
  }

  // MARK: Internal

  var walletPairingPollingManager: Factory<WalletPairingPollingProtocol> {
    self { @MainActor in WalletPairingPollingManager() }
  }

  var recordingStateManager: Factory<RecordingStateProtocol> {
    self { @MainActor in RecordingStateManager() }
  }

}
