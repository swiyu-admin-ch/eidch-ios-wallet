import BITL10n
import BITTheming
import SwiftUI

// MARK: - InformationDetailView

struct InformationDetailView<Header: View>: View {

  // MARK: Lifecycle

  init(
    primaryText: String,
    indentedParagraphTitleText: String? = nil,
    indentedParagraphText: String? = nil,
    secondaryText: String?,
    @ViewBuilder _ header: () -> Header)
  {
    self.primaryText = primaryText
    self.indentedParagraphTitleText = indentedParagraphTitleText
    self.indentedParagraphText = indentedParagraphText
    self.secondaryText = secondaryText
    self.header = header()
  }

  // MARK: Internal

  var body: some View {
    ZStack {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      content
    }
    .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
    .toolbar { CloseButtonToolbar(action: { dismiss() }) }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss

  private let header: Header
  private let indentedParagraphTitleText: String?
  private let indentedParagraphText: String?
  private let primaryText: String
  private let secondaryText: String?

  private var content: some View {
    VStack(alignment: .leading, spacing: .x2) {
      header
      Text(primaryText)
        .font(.custom.headline)
        .padding(.top, .x4)
        .accessibilityAddTraits(.isHeader)
      VStack(alignment: .leading, spacing: .x6) {
        if let indentedParagraphTitleText, let indentedParagraphText {
          VStack(alignment: .leading, spacing: .x4) {
            Text(indentedParagraphTitleText)
            Text(indentedParagraphText)
              .font(.custom.body.italic())
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.x3)
              .background(
                RoundedRectangle(cornerRadius: 10)
                  .foregroundStyle(ThemingAssets.Background.groupedRow.swiftUIColor))
          }
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .padding(.horizontal, .x2)
        }
        if let secondaryText {
          Text(secondaryText)
            .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        if let url = URL(string: L10n.tkBadgeInformationFurtherInformationLinkValue) {
          CustomLink(to: url, label: L10n.tkBadgeInformationFurtherInformationLinkText)
        }
      }
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding(.horizontal, .x4)
    .landscapeMaxWidth()
    .applyScrollViewIfNeeded()
  }
}
