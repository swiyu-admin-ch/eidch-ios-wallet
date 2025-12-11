import SwiftUI

public struct TextCell: View {

  // MARK: Lifecycle

  public init(
    title: String,
    subtitle: String?)
  {
    self.title = title
    self.subtitle = subtitle
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title)
        .multilineTextAlignment(.leading)
        .font(.custom.body)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
      if let subtitle {
        Text(subtitle)
          .multilineTextAlignment(.leading)
          .font(.custom.subheadline)
          .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
      }
    }
  }

  // MARK: Private

  private let title: String
  private let subtitle: String?
}
