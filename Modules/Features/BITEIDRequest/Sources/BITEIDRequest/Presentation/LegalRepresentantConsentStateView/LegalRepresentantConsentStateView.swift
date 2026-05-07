import BITEIDRequestShared
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - LegalRepresentantConsentStateView

struct LegalRepresentantConsentStateView: View {

  // MARK: Lifecycle

  init(state: RequestCaseViewState) {
    _viewModel = State(initialValue: Container.shared.legalRepresentantConsentStateViewModel(state))
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: viewModel.image,
      contents: contents,
      actions: [
        .primary(viewModel.primaryButtonText, identifier: "primaryButton") { _ in
          viewModel.primaryAction()
        },
      ])
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
      .navigate(to: $viewModel.destination)
      .defaultEidRequestToolbar()
      .navigationBarBackButtonHidden()
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case primaryText
    case secondaryText
    case tertiaryText
    case startDateText
  }

  @State private var viewModel: LegalRepresentantConsentStateViewModel
}

extension LegalRepresentantConsentStateView {
  private var contents: [InformationView2.ContentType] {
    if case .inQueue(let inQueueStateViewModel) = viewModel.state, inQueueStateViewModel.isLegalRepresentantConsentVerified {
      [
        .anyView { queueInformationViewContent(inQueueStateViewModel) },
      ]
    } else if case .readyForOnlineSession(let readyForOnlineSessionViewModel) = viewModel.state {
      [
        .anyView { readyForOnlineSessionContent(readyForOnlineSessionViewModel) },
      ]
    } else {
      [
        .title(viewModel.primaryText, identifier: AccessibilityIdentifier.primaryText.rawValue),
        .body(viewModel.secondaryText, identifier: AccessibilityIdentifier.secondaryText.rawValue),
      ]
    }
  }

  private func queueInformationViewContent(_ inQueueStateViewModel: InQueueStateViewModel) -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(viewModel.primaryText)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.primaryText.rawValue)
        .accessibilityAddTraits(.isHeader)

      Text(viewModel.secondaryText)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.secondaryText.rawValue)

      VStack {
        Text(L10n.tkEidRequestQueuingBody2Ios)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier(AccessibilityIdentifier.tertiaryText.rawValue)

        Text(inQueueStateViewModel.formattedDate)
          .font(.custom.bodyBold)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier(AccessibilityIdentifier.startDateText.rawValue)
      }
    }
    .frame(maxWidth: .infinity)
  }

  private func readyForOnlineSessionContent(_ readyForOnlineSessionViewModel: ReadyForOnlineSessionStateViewModel) -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(viewModel.primaryText)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.primaryText.rawValue)
        .accessibilityAddTraits(.isHeader)

      readyForOnlineSessionSecondaryText(readyForOnlineSessionViewModel)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.secondaryText.rawValue)
    }
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  private func readyForOnlineSessionSecondaryText(_ readyForOnlineSessionViewModel: ReadyForOnlineSessionStateViewModel) -> some View {
    if readyForOnlineSessionViewModel.isLegalRepresentantConsentVerified {
      Text(L10n.tkEidRequestLegalRepresentantGivenConsentReadyForAVSecondary)
    } else {
      Text("\(L10n.tkEidRequestLegalRepresentantPendingConsentReadyForAVSecondaryPrefix) \(Text(readyForOnlineSessionViewModel.formattedDateAndTime).font(.custom.bodyBold)) \(L10n.tkEidRequestLegalRepresentantPendingConsentReadyForAVSecondarySuffix)")
    }
  }
}
