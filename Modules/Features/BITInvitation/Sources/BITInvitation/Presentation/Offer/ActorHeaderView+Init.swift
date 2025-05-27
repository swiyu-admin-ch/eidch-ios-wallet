import BITCredential
import BITCredentialShared
import BITL10n
import Foundation

extension ActorHeaderView {

  init(issuer: CredentialIssuerDisplay?, trustStatus: TrustStatus) {
    let name = issuer?.name ?? L10n.tkErrorNotregisteredTitle
    if let imageData = issuer?.image {
      self.init(name: name, trustStatus: trustStatus, imageData: imageData)
    } else {
      self.init(name: name, trustStatus: trustStatus, image: Assets.questionmarkCircle.swiftUIImage)
    }
  }

}
