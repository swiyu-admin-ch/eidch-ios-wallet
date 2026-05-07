import BITL10n
import BITTheming
import SwiftUI

struct ActivityEmptyCell: View {

  // MARK: Lifecycle

  init(isActivityHistoryEnabled: Bool = true) {
    self.isActivityHistoryEnabled = isActivityHistoryEnabled
  }

  // MARK: Internal

  var body: some View {
    HStack(spacing: 0) {
      Assets.recentActivityNoHistory.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: iconSize, height: iconSize)
        .padding(.trailing, .x3)
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 0) {
        Text(L10n.tkActivityLatestActivitiesNoHistoryTitle)
          .font(.custom.body)
          .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
        Text(isActivityHistoryEnabled ? L10n.tkActivityLatestActivitiesNoHistoryBody : L10n.tkActivityLatestActivitiesDisabledHistoryBody)
          .font(.custom.caption1)
          .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
      }
      Spacer()
    }
    .padding(.horizontal, .x4)
    .padding(.vertical, .x2)
  }

  // MARK: Private

  @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 30

  private let isActivityHistoryEnabled: Bool
}
