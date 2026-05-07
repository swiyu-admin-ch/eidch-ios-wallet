import Factory
import Foundation
import NavigatorUI

extension Container {

  // MARK: Public

  public var otpServiceBaseUrl: Factory<URL> {
    self {
      guard let url = URL(string: "https://attestations.trust-infra.swiyu.admin.ch") else {
        fatalError("No valid URL for OTP url")
      }
      return url
    }
  }

  public var otpExternalViewProvider: Factory<(any NavigationViewProviding<OTPExternalViews>)?> {
    self { nil }
  }

  public var isOTPSkipEnabled: Factory<Bool> {
    self { false }
  }

  public var isOTPEnabledUseCase: Factory<IsOTPEnabledUseCaseProtocol> {
    self { IsOTPEnabledUseCase() }
  }

  public var setOTPEnabledUseCase: Factory<SetOTPEnabledUseCaseProtocol> {
    self { SetOTPEnabledUseCase() }
  }

  // MARK: Internal

  var otpEmailViewModel: Factory<OTPEmailViewModel> {
    self { @MainActor in OTPEmailViewModel() }
  }

  var otpCodeViewModel: ParameterFactory<(String, Callback<String>), OTPCodeViewModel> {
    self { @MainActor in OTPCodeViewModel(email: $0, onToastMessage: $1.handler) }
  }

  var otpRequestRepository: Factory<OTPRequestRepositoryProtocol> {
    self { OTPRequestRepository() }
  }

  var otpEnabledRepository: Factory<OTPEnabledRepositoryProtocol> {
    self { OTPEnabledRepository() }
  }

  var requestOTPUseCase: Factory<RequestOTPUseCaseProtocol> {
    self { RequestOTPUseCase() }
  }

  var verifyOTPUseCase: Factory<VerifyOTPUseCaseProtocol> {
    self { VerifyOTPUseCase() }
  }
}
