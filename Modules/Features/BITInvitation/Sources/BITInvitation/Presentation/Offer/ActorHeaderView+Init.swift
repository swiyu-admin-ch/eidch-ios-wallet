import BITCredential
import BITCredentialShared
import BITL10n
import Foundation

extension ActorHeaderView {

  init(issuer: CredentialIssuerDisplay?, trustStatus: TrustStatus) {
    let name = issuer?.name ?? L10n.tkErrorNotregisteredTitle
    self.init(name: name, trustStatus: trustStatus, imageData: issuer?.image)
  }

}
