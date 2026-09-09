import SwiftUI

public struct HeaderCell: View {

  // MARK: Lifecycle

  public init(image: Image, title: String, bodyText: String) {
    self.image = image
    self.title = title
    self.bodyText = bodyText
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: .x4) {
      image
        .frame(width: .x14, height: .x14, alignment: .leading)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: .x1) {
        Text(title)
          .font(.custom.bodyEmphasized)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityAddTraits(.isHeader)

        Text(bodyText)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
      }
    }
    .padding(.top, .x4)
    .padding(.bottom, .x3)
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  // MARK: Private

  private let image: Image
  private let title: String
  private let bodyText: String

}
