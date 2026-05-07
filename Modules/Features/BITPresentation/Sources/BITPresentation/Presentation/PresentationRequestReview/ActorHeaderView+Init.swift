import BITCredential
import BITL10n
import Foundation

extension ActorHeaderView {

  init(verifier: VerifierDisplay, topInset: CGFloat, onBadgeTapped: ((BadgeType) -> Void)? = nil) {
    let name = verifier.name ?? L10n.tkPresentVerifierNameUnknown
    self.init(
      name: name,
      trustInformation: verifier.trustInformation,
      type: .presentation,
      imageData: verifier.logo,
      topInset: topInset,
      onBadgeTapped: onBadgeTapped)
  }

}
