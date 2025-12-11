import BITAVWrapper
import BITEIDRequestShared
import Factory
import Foundation
import Spyable

@MainActor
extension Container {

  var scanDocumentViewModel: Factory<ScanDocumentViewModel> {
    self { ScanDocumentViewModel() }
  }

  var scanDocumentSubmitViewModel: ParameterFactory<ScanDocumentOutput, ScanDocumentSubmitViewModel> {
    self { ScanDocumentSubmitViewModel(scanDocumentOutput: $0) }
  }

  var recordDocumentViewModel: Factory<RecordDocumentViewModel> {
    self { RecordDocumentViewModel() }
  }

  var recordSelfieViewModel: Factory<RecordSelfieViewModel> {
    self { RecordSelfieViewModel() }
  }

  var queueInformationViewModel: ParameterFactory<Date, QueueInformationViewModel> {
    self { QueueInformationViewModel(onlineSessionStartDate: $0) }
  }

  var walletPairingViewModel: Factory<WalletPairingViewModel> {
    self { WalletPairingViewModel() }
  }

  var walletPairingListViewModel: Factory<WalletPairingListViewModel> {
    self { WalletPairingListViewModel() }
  }

  var avWelcomeViewModel: Factory<AVWelcomeViewModel> {
    self { AVWelcomeViewModel() }
  }

  var avIdentityCheckViewModel: Factory<AVIdentityCheckViewModel> {
    self { AVIdentityCheckViewModel() }
  }

  var legalRepresentantViewModel: Factory<LegalRepresentantViewModel> {
    self { LegalRepresentantViewModel() }
  }

  var legalRepresentantConsentViewModel: ParameterFactory<String, LegalRepresentantConsentViewModel> {
    self { LegalRepresentantConsentViewModel(caseId: $0) }
  }

  var legalRepresentantVerificationViewModel: ParameterFactory<String, LegalRepresentantVerificationViewModel> {
    self { LegalRepresentantVerificationViewModel(caseId: $0) }
  }

  var legalRepresentantQRCodeViewModel: ParameterFactory<String, LegalRepresentantQRCodeViewModel> {
    self { LegalRepresentantQRCodeViewModel(caseId: $0) }
  }

  var walletPairingOfferViewModel: ParameterFactory<(Void) -> Void, WalletPairingOfferViewModel> {
    self { WalletPairingOfferViewModel($0) }
  }

  var legalRepresentantConsentStateViewModel: ParameterFactory<RequestCaseViewState, LegalRepresentantConsentStateViewModel> {
    self { LegalRepresentantConsentStateViewModel(state: $0) }
  }

  var documentSelectionViewModel: Factory<DocumentSelectionViewModel> {
    self { DocumentSelectionViewModel() }
  }

  var validateAttestationsViewModel: Factory<ValidateAttestationsViewModel> {
    self {
      #if targetEnvironment(simulator)
      MockValidateAttestationsViewModel()
      #else
      ValidateAttestationsViewModel()
      #endif
    }
  }

  var validateAttestationsErrorViewModel: ParameterFactory<(ErrorWrapper, (Void) -> Void), ValidateAttestationsErrorViewModel> {
    self { ValidateAttestationsErrorViewModel(error: $0, callback: $1) }
  }

  var nfcScanViewModel: Factory<NFCScanViewModel> {
    self { NFCScanViewModel() }
  }

  var submitEIDRequestFilesViewModel: Factory<SubmitEIDRequestFilesViewModel> {
    self { SubmitEIDRequestFilesViewModel() }
  }

  var nfcScanResultViewModel: ParameterFactory<AVBeamPackageResult, NFCScanResultViewModel> {
    self { NFCScanResultViewModel(package: $0) }
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

  public var isEIDRequestAfterOnboardingEnabledUseCase: Factory<IsEIDRequestAfterOnboardingEnabledUseCaseProtocol> {
    self { IsEIDRequestAfterOnboardingEnabledUseCase() }
  }

  public var enableEIDRequestAfterOnboardingUseCase: Factory<EnableEIDRequestAfterOnboardingUseCaseProtocol> {
    self { EnableEIDRequestAfterOnboardingUseCase() }
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

  // MARK: Internal

  var applyEIDRequestUseCase: Factory<ApplyEIDRequestUseCaseProtocol> {
    #if targetEnvironment (simulator)
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

  var captureFaceDelay: Factory<UInt64> {
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

  var fetchAttestationsUseCase: Factory<FetchAttestationsUseCaseProtocol> {
    self { FetchAttestationsUseCase() }
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

  var eIDRequestRouter: Factory<EIDRequestRouter> {
    self { EIDRequestRouter() }.cached
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
    self { [.readyForOnlineSession, .inQueue] }
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
}

@MainActor
extension Container {

  var walletPairingPollingManager: Factory<WalletPairingPollingProtocol> {
    self { WalletPairingPollingManager() }
  }

}
