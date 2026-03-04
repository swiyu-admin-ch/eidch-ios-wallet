import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct LegalRepresentantView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.person.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestGuardianshipPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestGuardianshipSecondary, identifier: "secondaryText"),
      ],
      actions: [
        .primary(L10n.tkEidRequestGuardianshipButtonNo, identifier: "primaryButton", { _ in
          viewModel.action(false)
        }),
        .secondary(L10n.tkEidRequestGuardianshipButtonYes, identifier: "secondaryButton", { _ in
          viewModel.action(true)
        }),
      ])
      .navigationBarBackButtonHidden()
      .defaultEidRequestToolbar()
      .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @InjectedObject(\.legalRepresentantViewModel) private var viewModel
}

#Preview {
  LegalRepresentantView()
}
