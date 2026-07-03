import BITCredentialShared
import NavigatorUI

struct CredentialDetailCheckpoints: NavigationCheckpoints {
  static var refreshedCredential: NavigationCheckpoint<VerifiableCredential> {
    checkpoint()
  }
}
