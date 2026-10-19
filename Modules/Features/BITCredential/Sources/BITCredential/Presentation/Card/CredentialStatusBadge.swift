import BITTheming
import SwiftUI

// MARK: - CredentialStatusBadge

public struct CredentialStatusBadge: View {

  // MARK: Lifecycle

  public init(label: String, image: Image) {
    self.label = label
    self.image = image
  }

  // MARK: Public

  public var body: some View {
    let image = sizeCategory.isAccessibilityCategory ? nil : image
    Badge(label: label, image: image)
      .accessibilityLabel(label)
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  private let image: Image
  private let label: String
}

#if DEBUG
#Preview {
  VStack {
    CredentialStatusBadge(label: "Label", image: Image(systemName: "faceid"))
      .badgeType(.filled(.info))
  }.background(.blue)
}
#endif
