import BITL10n
import BITTheming
import SwiftUI

struct IssuanceSummarySection: View {

  let image: Image
  let title: String
  let description: String
  let openLearnMoreLink: () -> Void

  var body: some View {
    Section {
      VStack(alignment: .leading, spacing: .x4) {
        image
          .accessibilityHidden(true)

        Text(title)
          .font(.custom.bodyEmphasized)
          .accessibilityAddTraits(.isHeader)
        Text(description)
          .font(.custom.body)
          .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)

        ButtonLinkText(L10n.tkCredentialIssuanceTypeMoreInformation, openLearnMoreLink)
          .font(.custom.footnote)
          .foregroundStyle(ThemingAssets.Component.Link.label.swiftUIColor)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, .x6)
      .padding(.horizontal, .x4)
    }
    .background(ThemingAssets.Background.groupedRow.swiftUIColor)
  }
}
