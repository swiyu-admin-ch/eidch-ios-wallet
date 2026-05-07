import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

// MARK: - RecentActivitiesWidget

public struct RecentActivitiesWidget: View {

  // MARK: Lifecycle

  public init(_ activities: [ActivityCellViewModel], credentialId: UUID, isActivityHistoryEnabled: Bool) {
    self.activities = activities
    self.credentialId = credentialId
    self.isActivityHistoryEnabled = isActivityHistoryEnabled
  }

  // MARK: Public

  public var body: some View {
    SectionView(title: L10n.tkActivityLatestActivitiesTitle) {
      if !activities.isEmpty {
        recentHistoryItems
      } else {
        ActivityEmptyCell(isActivityHistoryEnabled: isActivityHistoryEnabled)
        if !isActivityHistoryEnabled {
          Divider()
            .padding(.leading, leadingIconSize + .x7)
          activitySettingsLink
        }
      }
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @ScaledMetric(relativeTo: .body) private var trailingIconSize: CGFloat = 11
  @ScaledMetric(relativeTo: .body) private var leadingIconSize: CGFloat = 30

  private let activities: [ActivityCellViewModel]
  private let credentialId: UUID
  private let isActivityHistoryEnabled: Bool

  private var recentHistoryItems: some View {
    VStack {
      ForEach(activities) { viewModel in
        ActivityCell(viewModel)
          .padding(.horizontal, .x4)
          .padding(.bottom, .x2)
        Divider()
          .padding(.leading, leadingIconSize + .x7)
      }
      entireHistoryLink
    }
    .padding(.vertical, .x2)
  }

  private var entireHistoryLink: some View {
    Button(action: {
      navigator.navigate(
        to: ActivityDestinations.activities(credentialId: credentialId))
    }) {
      HStack {
        Text(L10n.tkActivityLatestActivitiesEntireHistory)
          .font(.custom.body)
          .multilineTextAlignment(.leading)
          .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
        Spacer(minLength: .x2)
        ThemingAssets.chevronRight.swiftUIImage
          .resizable()
          .scaledToFit()
          .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
          .frame(width: trailingIconSize, height: trailingIconSize)
          .accessibilityHidden(true)
          .padding(.trailing, .x4)
      }
      .padding(.top, .x2)
      .padding(.leading, leadingIconSize + .x7)
    }
  }

  private var activitySettingsLink: some View {
    Button(action: {
      navigator.navigate(
        to: ActivityDestinations.settings)
    }) {
      Text(L10n.tkActivityLatestActivitiesGoToSettings)
        .font(.custom.body)
        .multilineTextAlignment(.leading)
        .foregroundColor(ThemingAssets.Brand.Accent.link.swiftUIColor)
        .padding(.vertical, .x2)
        .padding(.leading, leadingIconSize + .x7)
    }
  }
}

#if DEBUG
#Preview {
  ZStack {
    ThemingAssets.Background.secondary.swiftUIColor.ignoresSafeArea()
    VStack {
      RecentActivitiesWidget([ActivityCellViewModel(listItem: .Mock.issuance), ActivityCellViewModel(listItem: .Mock.acceptedPresentation)], credentialId: UUID(), isActivityHistoryEnabled: true)
      RecentActivitiesWidget([], credentialId: UUID(), isActivityHistoryEnabled: false)
    }
  }
}
#endif
