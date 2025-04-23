import Factory
import Foundation

@MainActor
extension Container {

  var introductionViewModel: ParameterFactory<EIDRequestInternalRoutes, IntroductionViewModel> {
    self { IntroductionViewModel(router: $0) }
  }

  var checkCardIntroductionViewModel: ParameterFactory<EIDRequestInternalRoutes, CheckCardIntroductionViewModel> {
    self { CheckCardIntroductionViewModel(router: $0) }
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

  var queueInformationViewModel: ParameterFactory<(EIDRequestInternalRoutes, Date), QueueInformationViewViewModel> {
    self { QueueInformationViewViewModel(router: $0, onlineSessionStartDate: $1) }
  }

  var walletPairingViewModel: ParameterFactory<EIDRequestInternalRoutes, WalletPairingViewModel> {
    self { WalletPairingViewModel(router: $0) }
  }

}

extension Container {

  // MARK: Public

  public var isEIDRequestFeatureEnabled: Factory<Bool> {
    self { false }
  }

  public var sidUrl: Factory<URL> {
    self {
      guard let url = URL(string: "https://eid.admin.ch") else {
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
}
