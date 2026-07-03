import BITL10n
import BITTheming
import Factory
import SwiftUI

struct RecordDocumentInformationView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      lottie: lottieView,
      contents: [
        .title(L10n.tkEidRequestRecordDocumentInformationPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestRecordDocumentInformationSecondary, identifier: "secondaryText"),
      ],
      actions: [
        .primary(L10n.tkEidRequestRecordDocumentInformationButtonPrimary, identifier: "primaryButton", { navigator in
          navigator.navigate(to: EIDRequestDestinations.recordDocument)
        }),
      ])
      .navigationDestination(EIDRequestDestinations.self)
      .navigationBarTitleDisplayMode(.inline)
      .defaultEidRequestToolbar()
      .navigationCheckpoint(EIDRequestCheckpoints.recordDocumentInformation)
      .navigationBarBackButtonHidden()
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.eidRequestContext) private var context

  private var lottieView: LottieView {
    guard case .passport = context.identityType else {
      return Lotties.recordDoc
    }
    return Lotties.recordPass
  }

}

#Preview {
  RecordDocumentInformationView()
}
