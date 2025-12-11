import BITCredential
import BITCredentialShared
import BITL10n
import Foundation

extension ActorHeaderView {

  init(issuer: CredentialIssuerDisplay?, trustInformation: TrustInformation, topInset: CGFloat, onBadgeTapped: ((BadgeType) -> Void)? = nil) {
    let name = issuer?.name ?? L10n.tkErrorNotregisteredTitle
    self.init(name: name, trustInformation: trustInformation, imageData: issuer?.image, topInset: topInset, onBadgeTapped: onBadgeTapped)
  }

}
