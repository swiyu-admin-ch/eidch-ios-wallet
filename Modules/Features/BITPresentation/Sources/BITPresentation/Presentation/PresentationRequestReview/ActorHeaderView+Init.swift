import BITCredential
import BITL10n
import Foundation

extension ActorHeaderView {

  init(verifier: VerifierDisplay?) {
    let name = verifier?.name ?? L10n.tkPresentVerifierNameUnknown
    self.init(name: name, trustStatus: verifier?.trustStatus ?? .unverified, imageData: verifier?.logo)
  }

}
