import BITEIDRequestShared
import BITL10n
import BITTheming
import Factory
import SwiftUI

struct ScanDocumentSecondPageView: View {

  // MARK: Lifecycle

  init(action: @escaping (Void) -> Void) {
    self.action = action
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      lottie: lottie,
      contents: [
        .title(context.identityType == .passport ? L10n.tkEidRequestScanDocumentSecondPagePassportPrimary : L10n.tkEidRequestScanDocumentSecondPageIdCardPrimary),
        .body(context.identityType == .passport ? L10n.tkEidRequestScanDocumentSecondPagePassportSecondary : L10n.tkEidRequestScanDocumentSecondPageIdCardSecondary),
      ],
      actions: [
        .primary(L10n.tkGlobalContinue) { navigator in
          navigator.dismiss()
          action(())
        },
      ])
      .toolbar(.visible)
  }

  // MARK: Private

  private var action: (Void) -> Void

  @ObservationIgnored @Injected(\.eidRequestContext) private var context

  private var lottie: LottieView {
    guard case .passport = context.identityType else {
      return Lotties.scanDocBack
    }
    return Lotties.scanDocPass2
  }
}
