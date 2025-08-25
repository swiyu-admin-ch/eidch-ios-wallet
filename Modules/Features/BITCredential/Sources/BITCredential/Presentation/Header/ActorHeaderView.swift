import BITCredentialShared
import BITTheming
import SwiftUI

// MARK: - ActorHeaderView

public struct ActorHeaderView: View {

  // MARK: Lifecycle

  public init(name: String, trustStatus: TrustStatus, imageData: Data? = nil) {
    self.name = name
    self.trustStatus = trustStatus
    self.imageData = imageData
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: .x4) {
      HStack(alignment: .top, spacing: .x4) {

        if !sizeCategory.isAccessibilityCategory {
          (imageData.flatMap(Image.init) ?? Assets.unknownIcon.swiftUIImage)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Self.imageMaxSize, height: Self.imageMaxSize)
            .foregroundColor(.white)
            .colorMultiply(colorScheme.standardColor())
            .padding(.x3)
            .background(ThemingAssets.Background.secondary.swiftUIColor)
            .clipShape(Circle())
            .accessibilityIdentifier(AccessibilityIdentifier.image.rawValue)
            .accessibilityHidden(true)
        }

        VStack(alignment: .leading, spacing: 0) {
          Text(name)
            .lineSpacing(Self.lineSpacing)
            .font(.custom.title3Emphasized)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilityAddTraits(.isHeader)

          HStack(alignment: .center, spacing: .x1) {
            if !sizeCategory.isAccessibilityCategory {
              trustStatus.icon
                .accessibilityHidden(true)
            }
            Text(trustStatus.description)
              .font(.custom.body)
              .foregroundStyle(trustStatus.color)
              .padding(.top, 2)
          }
        }

        Spacer()
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content
    case image
  }

  @Environment(\.sizeCategory) var sizeCategory
  @Environment(\.colorScheme) var colorScheme

  // MARK: Private

  private static let imageMaxSize: CGFloat = 24
  private static let lineSpacing: CGFloat = -10

  private let imageData: Data?
  private let name: String
  private let trustStatus: TrustStatus

}

#Preview {
  ActorHeaderView(name: "Test", trustStatus: .verified)
}
