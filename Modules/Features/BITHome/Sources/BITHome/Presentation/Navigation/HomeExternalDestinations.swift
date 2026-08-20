import BITCredential
import BITCredentialShared
import BITInvitation
import Foundation
import NavigatorUI

public enum HomeExternalDestinations: NavigationViews {
  case invitation(InvitationTab)
  case deeplink(URL)
  case offer(VerifiableCredential)
  case credentialDetail(CredentialDetailInput)
  case settings
  case betaId
  case otp
  case eIDRequest
  case autoVerification(String)
  case obtainConsent(String)
  case walletPairing(String)
  case identityCheck(String)
}
