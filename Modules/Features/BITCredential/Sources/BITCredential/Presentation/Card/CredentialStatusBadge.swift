import BITTheming
import SwiftUI

// MARK: - CredentialStatusBadge

public struct CredentialStatusBadge: View {

  // MARK: Lifecycle

  public init(label: String, image: Image, style: any BadgeStyle) {
    self.label = label
    self.image = image
    self.style = style
  }

  // MARK: Public

  public var body: some View {
    let image = sizeCategory.isAccessibilityCategory ? nil : image
    Badge(label: label, image: image)
      .badgeStyle(style)
      .accessibilityLabel(label)
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  private let image: Image
  private let label: String
  private let style: any BadgeStyle
}

#if DEBUG
#Preview {
  VStack {
    CredentialStatusBadge(label: "Label", image: Image(systemName: "faceid"), style: .info)
  }.background(.blue)
}
#endif
