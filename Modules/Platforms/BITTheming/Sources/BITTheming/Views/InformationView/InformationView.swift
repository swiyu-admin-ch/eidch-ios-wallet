import BITL10n
import SwiftUI

// MARK: - InformationView

public struct InformationView<Content: View, Footer: View>: View {

  // MARK: Lifecycle

  public init(
    image: Image,
    backgroundImage: Image = ThemingAssets.Gradient.gradient4.swiftUIImage,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer = { EmptyView() })
  {
    self.init(image: image, backgroundImage: backgroundImage, backgroundColor: nil, content: content, footer: footer)
  }

  public init(
    image: Image,
    backgroundColor: Color,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer = { EmptyView() })
  {
    self.init(image: image, backgroundImage: nil, backgroundColor: backgroundColor, content: content, footer: footer)
  }

  private init(
    image: Image,
    backgroundImage: Image?,
    backgroundColor: Color?,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer = { EmptyView() })
  {
    self.image = image
    self.backgroundImage = backgroundImage
    self.backgroundColor = backgroundColor

    self.content = content()
    self.footer = footer()
  }

  // MARK: Public

  public var body: some View {
    AdaptiveColumnsView(
      primaryContent: leftContent,
      secondaryContent: rightContent,
      footer: footerContent)
      .onAppear {
        resetAccessibilityFocus()
      }
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case image
  }

  // MARK: Private

  @AccessibilityFocusState private var isCurrentPageFocused: Bool

  @Orientation private var orientation

  private let footer: Footer
  private let content: Content

  private let image: Image
  private let backgroundImage: Image?
  private let backgroundColor: Color?

  private func resetAccessibilityFocus() {
    DispatchQueue.main.async {
      isCurrentPageFocused = false
      isCurrentPageFocused = true
    }
  }
}

// MARK: - Components

extension InformationView {

  @ViewBuilder
  private func leftContent() -> some View {
    card()
  }

  @ViewBuilder
  private func rightContent() -> some View {
    content
      .padding(.horizontal, .x6)
      .accessibilityFocused($isCurrentPageFocused)
  }

  @ViewBuilder
  private func footerContent() -> some View {
    footer
  }

}

extension InformationView {

  @ViewBuilder
  private func card() -> some View {
    if let backgroundImage {
      Card(background: .image(backgroundImage), image: image)
        .foregroundStyle(ThemingAssets.Grays.white.swiftUIColor)
        .accessibilityHidden(true)
        .accessibilityIdentifier(AccessibilityIdentifier.image.rawValue)
    } else if let backgroundColor {
      Card(background: .color(backgroundColor), image: image)
        .foregroundStyle(ThemingAssets.Grays.white.swiftUIColor)
        .accessibilityHidden(true)
        .accessibilityIdentifier(AccessibilityIdentifier.image.rawValue)
    }
  }

}
