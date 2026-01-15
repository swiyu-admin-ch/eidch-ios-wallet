import BITActivity
import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

struct NonComplianceCategorySelectionView: View {

  // MARK: Internal

  var body: some View {
    ZStack(alignment: .top) {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      content
    }
    .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
    .navigationTitle(L10n.tkNonComplianceListTitle)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      CloseButtonToolbar(action: {
        navigator.dismiss()
      })
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  let activity: Activity

  private var categories: [NonComplianceCategory] {
    activity.type.nonComplianceCategories
  }

  private var content: some View {
    List {
      Section {
        ForEach(categories) { category in
          NavigationLink(to: NonComplianceInternalDestinations.info(category: category, activityId: activity.id)) {
            category.cell
          }
        }
      } footer: {
        Text(L10n.tkNonComplianceListFooter)
      }
    }
    .landscapeMaxWidth()
    .scrollContentBackground(.hidden)
  }
}
