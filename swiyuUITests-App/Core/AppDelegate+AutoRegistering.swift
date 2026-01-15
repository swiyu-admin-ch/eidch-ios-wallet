import BITOpenID
import BITPresentation
import Factory
import Foundation
import RealmSwift

// MARK: - Container + AutoRegistering

extension Container: AutoRegistering {
  public func autoRegister() {
    pepperKeyVaultOptions.register { .none }
    delayAfterAcceptingCredential.register { 0 }
    loadingDelay.register { 0 }
    trustEnvironmentDidRegex.register { #/^did:(?:tdw|webvh):[^:]+:identifier-reg-r\.trust-infra\.swiyu\.admin\.ch:.*/# }

    openIDRepository.register { MockOpenIDRepository() }
    trustStatementRepository.register { MockTrustStatementRepository() }
    ocaRepository.register { MockOCARepository() }

    versionEnforcementRepository.register { MockVersionEnforcementRepository() }

    updateAnalyticsStatusUseCase.register { MockUpdateAnalyticStatusUseCase() }
    registerPinCodeUseCase.register { MockRegisterPinCodeUseCase() }
    hasDevicePinUseCase.register { MockHasDevicePinUseCase(true) }
    loginPinCodeUseCase.register { MockLoginPinCodeUseCase() }
    homeRouter.register { MockHomeRouter() }
    jwsSignatureValidator.register { MockJWSSignatureValidator() }

    userSession.register { MockUserSession() }
    keyManager.register { MockKeyManager() }

    presentationRequestRepository.register { MockPresentationRequestRepository() }
    checkInvitationTypeUseCase.register { MockCheckInvitationTypeUseCase() }
  }

}
