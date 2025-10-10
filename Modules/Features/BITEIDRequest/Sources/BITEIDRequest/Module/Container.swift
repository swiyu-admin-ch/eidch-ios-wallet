import BITAVWrapper
import BITEIDRequestShared
import Factory
import Foundation
import Spyable

@MainActor
extension Container {

  var introductionViewModel: ParameterFactory<EIDRequestInternalRoutes, IntroductionViewModel> {
    self { IntroductionViewModel(router: $0) }
  }

  var dataPrivacyViewModel: ParameterFactory<EIDRequestInternalRoutes, DataPrivacyViewModel> {
    self { DataPrivacyViewModel(router: $0) }
  }

  var cameraPermissionViewModel: ParameterFactory<EIDRequestInternalRoutes, CameraPermissionViewModel> {
    self { CameraPermissionViewModel(router: $0) }
  }

  var scanDocumentViewModel: ParameterFactory<EIDRequestInternalRoutes, ScanDocumentViewModel> {
    self { ScanDocumentViewModel(router: $0) }
  }

  var scanDocumentSubmitViewModel: ParameterFactory<(ScanDocumentOutput, EIDRequestInternalRoutes), ScanDocumentSubmitViewModel> {
    self { ScanDocumentSubmitViewModel(scanDocumentOutput: $0, router: $1) }
  }

  var recordDocumentViewModel: ParameterFactory<EIDRequestInternalRoutes, RecordDocumentViewModel> {
    self { RecordDocumentViewModel(router: $0) }
  }

  var recordSelfieViewModel: ParameterFactory<EIDRequestInternalRoutes, RecordSelfieViewModel> {
    self { RecordSelfieViewModel(router: $0) }
  }

  var queueInformationViewModel: ParameterFactory<(EIDRequestInternalRoutes, Date), QueueInformationViewModel> {
    self { QueueInformationViewModel(router: $0, onlineSessionStartDate: $1) }
  }

  var walletPairingViewModel: ParameterFactory<EIDRequestInternalRoutes, WalletPairingViewModel> {
    self { WalletPairingViewModel(router: $0) }
  }

  var walletPairingListViewModel: ParameterFactory<EIDRequestInternalRoutes, WalletPairingListViewModel> {
    self { WalletPairingListViewModel(router: $0) }
  }

  var avWelcomeViewModel: ParameterFactory<EIDRequestInternalRoutes, AVWelcomeViewModel> {
    self { AVWelcomeViewModel(router: $0) }
  }

  var avIdentityCheckViewModel: ParameterFactory<EIDRequestInternalRoutes, AVIdentityCheckViewModel> {
    self { AVIdentityCheckViewModel(router: $0) }
  }

  var legalRepresentantViewModel: ParameterFactory<EIDRequestInternalRoutes, LegalRepresentantViewModel> {
    self { LegalRepresentantViewModel(router: $0) }
  }

  var legalRepresentantConsentViewModel: ParameterFactory<(EIDRequestInternalRoutes, String), LegalRepresentantConsentViewModel> {
    self { LegalRepresentantConsentViewModel(router: $0, caseId: $1) }
  }

  var legalRepresentantVerificationViewModel: ParameterFactory<String, LegalRepresentantVerificationViewModel> {
    self { LegalRepresentantVerificationViewModel(caseId: $0) }
  }

  var eIDRequestErrorViewModel: ParameterFactory<(EIDRequestErrorDelegate, Error), EIDRequestErrorViewModel> {
    self { EIDRequestErrorViewModel(delegate: $0, error: $1) }
  }

  var legalRepresentantQRCodeViewModel: ParameterFactory<(EIDRequestInternalRoutes, String), LegalRepresentantQRCodeViewModel> {
    self { LegalRepresentantQRCodeViewModel(router: $0, caseId: $1) }
  }

  var avDevicePairingQRCodeViewModel: ParameterFactory<(EIDRequestInternalRoutes, DevicePairingDelegate?), AVDevicePairingQRCodeViewModel> {
    self { AVDevicePairingQRCodeViewModel(router: $0, delegate: $1) }
  }

  var legalRepresentantConsentStateViewModel: ParameterFactory<(EIDRequestInternalRoutes, RequestCaseViewState), LegalRepresentantConsentStateViewModel> {
    self { LegalRepresentantConsentStateViewModel(router: $0, state: $1) }
  }

  var documentSelectionViewModel: ParameterFactory<EIDRequestInternalRoutes, DocumentSelectionViewModel> {
    self { DocumentSelectionViewModel(router: $0) }
  }

  var validateAttestationsViewModel: ParameterFactory<EIDRequestInternalRoutes, ValidateAttestationsViewModelProtocol> {
    self {
      #if targetEnvironment(simulator)
      MockValidateAttestationsViewModel(router: $0)
      #else
      ValidateAttestationsViewModel(router: $0)
      #endif
    }
  }

  var clientAttestationErrorViewModel: ParameterFactory<EIDRequestInternalRoutes, ClientAttestationErrorViewModel> {
    self { ClientAttestationErrorViewModel(router: $0) }
  }

  var keyAttestationErrorViewModel: ParameterFactory<EIDRequestInternalRoutes, KeyAttestationErrorViewModel> {
    self { KeyAttestationErrorViewModel(router: $0) }
  }

  var validateAttestationsErrorViewModel: ParameterFactory<(EIDRequestInternalRoutes, ValidateAttestationsErrorDelegate, Error), ValidateAttestationsErrorViewModel> {
    self { ValidateAttestationsErrorViewModel(router: $0, delegate: $1, error: $2) }
  }

  var avIntroSelfieVideoViewModel: ParameterFactory<EIDRequestInternalRoutes, AVIntroSelfieVideoViewModel> {
    self { AVIntroSelfieVideoViewModel(router: $0) }
  }

  var nfcScanViewModel: ParameterFactory<EIDRequestInternalRoutes, NFCScanViewModel> {
    self { NFCScanViewModel(router: $0) }
  }

  var submitEIDRequestFilesViewModel: ParameterFactory<EIDRequestInternalRoutes, SubmitEIDRequestFilesViewModel> {
    self { SubmitEIDRequestFilesViewModel(router: $0) }
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

  public var submitEIDRequestUseCase: Factory<SubmitEIDRequestUseCaseProtocol> {
    self { SubmitEIDRequestUseCase() }
  }

  public var saveEIDRequestFilesUseCase: Factory<SaveEIDRequestFilesUseCaseProtocol> {
    self { SaveEIDRequestFilesUseCase() }
  }

  // MARK: Internal

  var submitEIDRequestFileUseCase: Factory<SubmitEIDRequestFileUseCaseProtocol> {
    self { SubmitEIDRequestFileUseCase() }
  }

  var getEIDRequestCaseFilesUseCase: Factory<GetEIDRequestCaseFilesUseCaseProtocol> {
    self { GetEIDRequestCaseFilesUseCase() }
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

  var eIDRequestContext: Factory<EIDRequestContext> {
    self { EIDRequestContext() }
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
}

@MainActor
extension Container {

  var walletPairingPollingManager: Factory<WalletPairingPollingProtocol> {
    self { WalletPairingPollingManager() }
  }

}
