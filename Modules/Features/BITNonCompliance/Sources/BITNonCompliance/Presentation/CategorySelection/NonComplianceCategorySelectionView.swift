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

  let activityId: UUID
  let credentialId: UUID

  private let categories = NonComplianceCategory.allCases

  private var content: some View {
    List {
      Section {
        ForEach(categories) { category in
          NavigationLink(to: NonComplianceDestinations.info(category: category, activityId: activityId, credentialId: credentialId)) {
            category.cell
          }
        }
        .padding(.vertical, .x3)
        .padding(.horizontal, .x4)
        .listRowInsets(EdgeInsets())
      } footer: {
        Text(L10n.tkNonComplianceListFooter)
      }
    }
    .landscapeMaxWidth()
    .scrollContentBackground(.hidden)
  }
}
