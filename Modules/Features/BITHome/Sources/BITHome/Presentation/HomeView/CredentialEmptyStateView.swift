import BITEIDRequest
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - CredentialEmptyStateView

struct CredentialEmptyStateView: View {

  // MARK: Internal

  var body: some View {
    VStack {
      Spacer()
      content
      Spacer()
    }
    .applyScrollViewIfNeeded(.vertical)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @Environment(\.sizeCategory) private var sizeCategory
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  @Injected(\.isEIDRequestFeatureEnabled) private var isEIDRequestEnabled
  @Injected(\.isBetaIdEnabled) private var isBetaIdEnabled

  private var hidesButtonIcon: Bool {
    dynamicTypeSize >= .accessibility2
  }

  private var content: some View {
    VStack(alignment: .center, spacing: .x1) {
      emptyWalletIcon
      title
      message

      if isEIDRequestEnabled {
        orderEIDButton
      }

      if isBetaIdEnabled {
        getBetaIdButton
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, .x6)
  }

  @ViewBuilder
  private var emptyWalletIcon: some View {
    if !sizeCategory.isAccessibilityCategory {
      HomeAssets.emptyWalletIcon.swiftUIImage
        .padding(.bottom, .x6)
        .accessibilityHidden(true)
    }
  }

  private var title: some View {
    Text(L10n.tkGetBetaIdFirstUseTitle)
      .multilineTextAlignment(.center)
      .font(.custom.title3)
      .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
      .accessibilityAddTraits(.isHeader)
  }

  private var message: some View {
    Text(L10n.tkGetBetaIdFirstUseBody)
      .multilineTextAlignment(.center)
      .font(.custom.body)
      .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
      .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
  }

  private var orderEIDButton: some View {
    primaryButton(
      L10n.menuOrderEidBody,
      action: { navigator.navigate(to: HomeDestinations.external(.eIDRequest)) })
      .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      .padding(.top, .x6)
  }

  private var getBetaIdButton: some View {
    primaryButton(
      L10n.getBetaIdButton,
      action: { navigator.navigate(to: HomeDestinations.external(.betaId)) })
      .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
      .padding(.top, .x4)
  }

  private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(action: action, label: {
      if hidesButtonIcon {
        Text(title)
          .fixedSize(horizontal: false, vertical: true)
      } else {
        Label(title, systemImage: "arrow.forward")
          .fixedSize(horizontal: false, vertical: true)
      }
    })
    .buttonStyle(.tertiary)
    .controlSize(.large)
  }
}
