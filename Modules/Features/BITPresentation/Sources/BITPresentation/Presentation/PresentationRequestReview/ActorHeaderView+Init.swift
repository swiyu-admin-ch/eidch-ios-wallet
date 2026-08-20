import BITCredential
import BITL10n
import Foundation

extension ActorHeaderView {

  init(verifier: VerifierDisplay, topInset: CGFloat, onTapped: ((ActorInformation) -> Void)? = nil) {
    let name = verifier.name ?? L10n.tkPresentVerifierNameUnknown
    self.init(
      name: name,
      trustInformation: verifier.trustInformation,
      actorCompliance: verifier.actorCompliance,
      imageData: verifier.logo,
      topInset: topInset,
      onTapped: onTapped)
  }

}
