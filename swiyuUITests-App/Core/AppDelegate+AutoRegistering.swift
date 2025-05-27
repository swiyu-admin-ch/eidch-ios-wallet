import BITOpenID
import BITPresentation
import Factory
import Foundation
import RealmSwift

// MARK: - Container + AutoRegistering

extension Container: AutoRegistering {
  public func autoRegister() {
    baseRegistryDomainPattern.register { #"^did:tdw:(.+)"# }
    vaultOptions.register { .none }
    delayAfterAcceptingCredential.register { 0 }
    loadingDelay.register { 0 }

    openIDRepository.register { MockOpenIDRepository() }

    versionEnforcementRepository.register { MockVersionEnforcementRepository() }
    trustRegistryRepository.register { MockTrustRegistryRepository() }

    updateAnalyticsStatusUseCase.register { MockUpdateAnalyticStatusUseCase() }
    registerPinCodeUseCase.register { MockRegisterPinCodeUseCase() }
    hasDevicePinUseCase.register { MockHasDevicePinUseCase(true) }
    loginPinCodeUseCase.register { MockLoginPinCodeUseCase() }
    homeRouter.register { MockHomeRouter() }
    jwsSignatureValidator.register { MockJWSSignatureValidator(true) }

    userSession.register { MockUserSession() }
    keyManager.register { MockKeyManager() }

    presentationRepository.register { MockPresentationRepository() }
    checkInvitationTypeUseCase.register { MockCheckInvitationTypeUseCase() }
  }

}
