import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - QueueInformationView

struct QueueInformationView: View {

  // MARK: Lifecycle

  init(onlineSessionStartDate: Date) {
    viewModel = Container.shared.queueInformationViewModel(onlineSessionStartDate)
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.timer.swiftUIImage,
      contents: [
        .title(L10n.tkEidRequestQueuingTitle, identifier: AccessibilityIdentifier.primaryText.rawValue),
        .body(L10n.tkEidRequestQueuingBody, identifier: AccessibilityIdentifier.secondaryText.rawValue),
        .body(L10n.tkEidRequestQueuingBody2Ios, identifier: AccessibilityIdentifier.tertiaryText.rawValue),
        .bodyBold(viewModel.expectedOnlineSessionStart, identifier: AccessibilityIdentifier.startDateText.rawValue),
      ],
      actions: [
        .primary(L10n.tkGlobalContinue, identifier: "primaryButton", { navigator in
          navigator.dismiss()
        }),
      ])
      .toolbar(.visible)
      .navigationBarBackButtonHidden()
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case primaryText
    case secondaryText
    case tertiaryText
    case startDateText
  }

  private var viewModel: QueueInformationViewModel
}

#Preview {
  QueueInformationView(onlineSessionStartDate: Date())
}
