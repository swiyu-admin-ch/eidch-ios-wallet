import Factory
import Spyable


@Spyable
public protocol IsEIDRequestAfterOnboardingEnabledUseCaseProtocol {
  func execute() -> Bool
}


struct IsEIDRequestAfterOnboardingEnabledUseCase: IsEIDRequestAfterOnboardingEnabledUseCaseProtocol {
  func execute() -> Bool {
    eIDRequestAfterOnboardingEnabledRepository.get()
  }

  @Injected(\.eIDRequestAfterOnboardingEnabledRepository) private var eIDRequestAfterOnboardingEnabledRepository: EIDRequestAfterOnboardingEnabledRepositoryProcotol
}
