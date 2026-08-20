import BITCredential
import BITCredentialShared
import BITL10n
import BITNonCompliance
import Foundation

extension ActorHeaderView {

  init(
    issuer: CredentialIssuerDisplay?,
    trustInformation: TrustInformation,
    actorCompliance: ActorCompliance,
    topInset: CGFloat,
    onTapped: ((ActorInformation) -> Void)? = nil)
  {
    let name = issuer?.name ?? L10n.tkErrorNotregisteredTitle
    self.init(
      name: name,
      trustInformation: trustInformation,
      actorCompliance: actorCompliance,
      imageData: issuer?.image,
      topInset: topInset,
      onTapped: onTapped)
  }
}
