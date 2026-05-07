import BITL10n
import BITTheming
import SwiftUI

struct RecordDocumentInformationView: View {

  var body: some View {
    InformationView2(
      image: Assets.scanDocumentPreview.swiftUIImage,
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

}

#Preview {
  RecordDocumentInformationView()
}
