import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - LegalRepresentantConsentStateView

struct LegalRepresentantConsentStateView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, state: RequestCaseViewState) {
    viewModel = Container.shared.legalRepresentantConsentStateViewModel((router, state))
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: viewModel.image,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: content,
      footer: {
        DefaultInformationFooterView(primaryButtonLabel: viewModel.primaryButtonText, primaryButtonAction: viewModel.primaryAction)
      })
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case primaryText
    case secondaryText
    case tertiaryText
    case startDateText
  }

  private var viewModel: LegalRepresentantConsentStateViewModel
}

extension LegalRepresentantConsentStateView {
  @ViewBuilder
  private func content() -> some View {
    if case .inQueue(let inQueueStateViewModel) = viewModel.state, inQueueStateViewModel.isLegalRepresentantConsentVerified {
      queueInformationViewContent(inQueueStateViewModel)
    } else if case .readyForOnlineSession(let readyForOnlineSessionViewModel) = viewModel.state {
      readyForOnlineSessionContent(readyForOnlineSessionViewModel)
    } else {
      DefaultInformationContentView(primary: viewModel.primaryText, secondary: viewModel.secondaryText)
    }
  }

  @ViewBuilder
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
        Text(L10n.tkGetEidQueuingBody2Ios)
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

  @ViewBuilder
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
      Text(L10n.tkGetEidLegalRepresentantGivenConsentReadyForAVSecondary)
    } else {
      Text("\(L10n.tkGetEidLegalRepresentantPendingConsentReadyForAVSecondaryPrefix) \(Text(readyForOnlineSessionViewModel.formattedDateAndTime).font(.custom.bodyBold)) \(L10n.tkGetEidLegalRepresentantPendingConsentReadyForAVSecondarySuffix)")
    }
  }
}
