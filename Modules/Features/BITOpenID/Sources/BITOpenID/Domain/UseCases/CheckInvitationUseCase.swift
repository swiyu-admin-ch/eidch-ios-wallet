import Factory
import Foundation
import Spyable

// MARK: - CheckInvitationTypeError

public enum CheckInvitationTypeError: Error {
  case wrongScheme
}

// MARK: - CheckInvitationTypeUseCaseProtocol

@Spyable
public protocol CheckInvitationTypeUseCaseProtocol {
  func execute(url: URL) throws -> InvitationType
}

// MARK: - CheckInvitationTypeUseCase

struct CheckInvitationTypeUseCase: CheckInvitationTypeUseCaseProtocol {

  func execute(url: URL) throws -> InvitationType {
    guard let scheme = url.scheme else { throw CheckInvitationTypeError.wrongScheme }
    return if InvitationType.credentialOffer.schemes.contains(scheme) {
      .credentialOffer
    } else if InvitationType.presentation.schemes.contains(scheme) {
      .presentation
    } else if isProximityEnabled, InvitationType.proximityEngagement.schemes.contains(scheme) {
      .proximityEngagement
    } else {
      throw CheckInvitationTypeError.wrongScheme
    }
  }

  // MARK: Private

  @Injected(\.isProximityEnabled) private var isProximityEnabled: Bool
}
