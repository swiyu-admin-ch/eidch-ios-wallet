import BITCredential
import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - CredentialSummaryWidget

struct CredentialSummaryWidget: View {

  // MARK: Lifecycle

  init(credential: VerifiableCredentialViewModel, claimBadges: [ClaimBadgeViewModel], badgeAction: @escaping (BadgeType) -> Void) {
    self.credential = credential
    self.claimBadges = claimBadges
    self.badgeAction = badgeAction
  }

  // MARK: Internal

  var body: some View {
    VStack(alignment: .leading, spacing: .x2) {
      VerifiableCredentialCell(credential)
      badges
        .padding(.horizontal, .x4)
    }
    .padding(.top, .x1)
    .padding(.bottom, .x2)
    .accessibilityElement(children: .contain)
  }

  // MARK: Private

  private let credential: VerifiableCredentialViewModel
  private let claimBadges: [ClaimBadgeViewModel]
  private let badgeAction: (BadgeType) -> Void

  private var badges: some View {
    FlowLayout(verticalSpacing: .x3, horizontalSpacing: .x2) {
      ForEach(claimBadges) { badge in
        Button {
          badgeAction(.sensitiveData(isSensitive: badge.isSensitive, claimName: badge.name))
        } label: {
          SensitiveDataBadge(isSensitive: badge.isSensitive, claimName: badge.name)
        }
      }
    }
    .accessibilityElement(children: .contain)
  }
}

#if DEBUG
#Preview {
  ZStack {
    ThemingAssets.Background.secondary.swiftUIColor.ignoresSafeArea()
    SectionView {
      CredentialSummaryWidget(
        credential: VerifiableCredentialViewModel(credential: .Mock.sample),
        claimBadges: [
          ClaimBadgeViewModel(name: "Test", isSensitive: true),
          ClaimBadgeViewModel(name: "Another", isSensitive: false),
          ClaimBadgeViewModel(name: "Longer name that is a bit annoying", isSensitive: false),
        ]) { _ in }
    }
  }
}
#endif
