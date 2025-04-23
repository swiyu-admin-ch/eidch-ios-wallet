import BITCredentialShared
import BITTheming
import SwiftUI

// MARK: - ActorHeaderView

public struct ActorHeaderView: View {

  // MARK: Lifecycle

  public init(name: String, trustStatus: TrustStatus) {
    _viewModel = StateObject(wrappedValue: ActorHeaderViewModel(name: name, trustStatus: trustStatus))
  }

  public init(name: String, trustStatus: TrustStatus, image: Image) {
    _viewModel = StateObject(wrappedValue: ActorHeaderViewModel(name: name, trustStatus: trustStatus, image: image))
  }

  public init(name: String, trustStatus: TrustStatus, imageData: Data) {
    _viewModel = StateObject(wrappedValue: ActorHeaderViewModel(name: name, trustStatus: trustStatus, imageData: imageData))
  }

  public init(name: String, trustStatus: TrustStatus, imageUrl: URL) {
    _viewModel = StateObject(wrappedValue: ActorHeaderViewModel(name: name, trustStatus: trustStatus, imageUrl: imageUrl))
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: .x4) {
      HStack(alignment: .top, spacing: .x4) {

        if !sizeCategory.isAccessibilityCategory {
          (viewModel.image ?? Assets.unknownIcon.swiftUIImage)
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
        }

        VStack(alignment: .leading, spacing: 0) {
          Text(viewModel.name)
            .lineSpacing(Self.lineSpacing)
            .font(.custom.title3Emphasized)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilityLabel(viewModel.name)
            .accessibilityIdentifier(AccessibilityIdentifier.title.rawValue)

          HStack(alignment: .center, spacing: .x1) {
            if !sizeCategory.isAccessibilityCategory {
              viewModel.trustStatus.icon
            }
            Text(viewModel.trustStatus.description)
              .font(.custom.body)
              .foregroundStyle(viewModel.trustStatus.color)
              .accessibilityLabel(viewModel.trustStatus.description)
              .padding(.top, 2)
              .accessibilityIdentifier(AccessibilityIdentifier.verifiedStatus.rawValue)
          }
        }

        Spacer()
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isHeader)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case title
    case verifiedStatus
    case image
  }

  @Environment(\.sizeCategory) var sizeCategory
  @Environment(\.colorScheme) var colorScheme

  // MARK: Private

  private static let imageMaxSize: CGFloat = 24
  private static let lineSpacing: CGFloat = -10

  @StateObject private var viewModel: ActorHeaderViewModel

}

#Preview {
  Group {
    ActorHeaderView(name: "Test", trustStatus: .verified, image: Image(systemName: "square.fill"))
    ActorHeaderView(name: "Test", trustStatus: .verified)
  }
}
