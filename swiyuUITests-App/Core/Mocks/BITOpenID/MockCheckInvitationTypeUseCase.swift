import BITOpenID
import Foundation

struct MockCheckInvitationTypeUseCase: CheckInvitationTypeUseCaseProtocol {
  func execute(url: URL) throws -> InvitationType {
    if ProcessInfo().arguments.contains("-presentation") { // Necessary as long as we do not have presentation via deeplink
      return .presentation
    }

    return .credentialOffer
  }
}
