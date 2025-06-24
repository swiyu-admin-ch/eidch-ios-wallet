import Factory
import Spyable


@Spyable
public protocol EnableEIDRequestAfterOnboardingUseCaseProtocol {
  func execute(_ enable: Bool)
}


struct EnableEIDRequestAfterOnboardingUseCase: EnableEIDRequestAfterOnboardingUseCaseProtocol {
  func execute(_ enable: Bool) {
    eIDRequestAfterOnboardingEnabledRepository.set(enable)
  }

  @Injected(\.eIDRequestAfterOnboardingEnabledRepository) private var eIDRequestAfterOnboardingEnabledRepository: EIDRequestAfterOnboardingEnabledRepositoryProcotol
}
