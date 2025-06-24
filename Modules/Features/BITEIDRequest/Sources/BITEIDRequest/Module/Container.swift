import Factory
import Foundation

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

  var mrzScannerViewModel: ParameterFactory<EIDRequestInternalRoutes, MRZScannerViewModel> {
    self { MRZScannerViewModel(router: $0) }
  }

  var queueInformationViewModel: ParameterFactory<(EIDRequestInternalRoutes, Date), QueueInformationViewModel> {
    self { QueueInformationViewModel(router: $0, onlineSessionStartDate: $1) }
  }

  var walletPairingViewModel: ParameterFactory<EIDRequestInternalRoutes, WalletPairingViewModel> {
    self { WalletPairingViewModel(router: $0) }
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

  var legalRepresentantQRCodeViewModel: ParameterFactory<(EIDRequestInternalRoutes, String), LegalRepresentantQRCodeViewModel> {
    self { LegalRepresentantQRCodeViewModel(router: $0, caseId: $1) }
  }

  var legalRepresentantConsentStateViewModel: ParameterFactory<(EIDRequestInternalRoutes, RequestCaseViewState), LegalRepresentantConsentStateViewModel> {
    self { LegalRepresentantConsentStateViewModel(router: $0, state: $1) }
  }

  var documentSelectionViewModel: ParameterFactory<EIDRequestInternalRoutes, DocumentSelectionViewModel> {
    self { DocumentSelectionViewModel(router: $0) }
  }

  var attestationViewModel: ParameterFactory<EIDRequestInternalRoutes, AttestationViewModel> {
    self { AttestationViewModel(router: $0) }
  }

  var clientAttestationErrorViewModel: ParameterFactory<EIDRequestInternalRoutes, ClientAttestationErrorViewModel> {
    self { ClientAttestationErrorViewModel(router: $0) }
  }

  var keyAttestationErrorViewModel: ParameterFactory<EIDRequestInternalRoutes, KeyAttestationErrorViewModel> {
    self { KeyAttestationErrorViewModel(router: $0) }
  }

  var attestationErrorViewModel: ParameterFactory<(EIDRequestInternalRoutes, AttestationErrorDelegate), AttestationErrorViewModel> {
    self { AttestationErrorViewModel(router: $0, delegate: $1) }
  }

}

extension Container {

  // MARK: Public

  public var isEIDRequestFeatureEnabled: Factory<Bool> {
    self { false }
  }

  public var sidUrl: Factory<URL> {
    self {
      guard let url = URL(string: "https://www.sid.admin.ch/sid-web/") else {
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

  // MARK: Internal

  var eIDRequestResponseDecoder: Factory<JSONDecoder> {
    self {
      JSONDecoder(dateDecodingStrategy: .formatted(DateFormatter(format: "yyyy-MM-dd")))
    }
  }

  var eIDRequestRouter: Factory<EIDRequestRouter> {
    self { EIDRequestRouter() }
  }

  var eIDRequestAfterOnboardingEnabledRepository: Factory<EIDRequestAfterOnboardingEnabledRepositoryProcotol> {
    self { EIDRequestAfterOnboardingEnabledRepository() }
  }

  var eIDRequestRepository: Factory<EIDRequestRepositoryProtocol> {
    self { EIDRequestRepository() }
  }

  var localEIDRequestRepository: Factory<LocalEIDRequestRepositoryProtocol> {
    self { DatabaseEIDRequestRepository() }
  }

  var submitEIDRequestUseCase: Factory<SubmitEIDRequestUseCaseProtocol> {
    self { SubmitEIDRequestUseCase() }
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

  var validateAttestationsUseCase: Factory<ValidateAttestationsUseCaseProtocol> {
    self { ValidateAttestationsUseCase() }
  }
}
