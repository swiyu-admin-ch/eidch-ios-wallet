import BITCredential
import BITL10n
import Foundation

extension ActorHeaderView {

  init(verifier: VerifierDisplay, topInset: CGFloat) {
    let name = verifier.name ?? L10n.tkPresentVerifierNameUnknown
    self.init(name: name, trustInformation: verifier.trustInformation, imageData: verifier.logo, topInset: topInset, isIssuance: false)
  }

}
