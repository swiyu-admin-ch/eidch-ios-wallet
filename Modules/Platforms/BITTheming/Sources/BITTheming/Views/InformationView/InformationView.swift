import BITL10n
import SwiftUI

// MARK: - InformationView

public struct InformationView<Content: View, Footer: View, ImageView: View>: View {

  // MARK: Lifecycle

  public init(
    image: ImageView,
    backgroundImage: Image = ThemingAssets.Gradient.gradient4.swiftUIImage,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer = { EmptyView() })
  {
    self.init(image: image, backgroundImage: backgroundImage, backgroundColor: nil, content: content, footer: footer)
  }

  public init(
    image: ImageView,
    backgroundColor: Color,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer = { EmptyView() })
  {
    self.init(image: image, backgroundImage: nil, backgroundColor: backgroundColor, content: content, footer: footer)
  }

  private init(
    image: ImageView,
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
    VStack {
      if orientation.isPortrait {
        portraitLayout()
      } else {
        landscapeLayout()
      }
    }
    .onAppear {
      resetAccessibilityFocus()
    }
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case image
    case content
    case footer
  }

  @Environment(\.sizeCategory) var sizeCategory

  // MARK: Private

  private enum Constants {
    static var cardAccessibilityMaxHeight: CGFloat { 150 }
  }

  @AccessibilityFocusState private var isCurrentPageFocused: Bool

  @Orientation private var orientation

  private let footer: Footer
  private let content: Content

  private let image: ImageView
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
  private func card() -> some View {
    if let backgroundImage {
      Card(background: .image(backgroundImage), content: { image })
        .foregroundStyle(ThemingAssets.Grays.white.swiftUIColor)
        .accessibilityHidden(true)
        .accessibilityIdentifier(AccessibilityIdentifier.image.rawValue)
    } else if let backgroundColor {
      Card(background: .color(backgroundColor), content: { image })
        .foregroundStyle(ThemingAssets.Grays.white.swiftUIColor)
        .accessibilityHidden(true)
        .accessibilityIdentifier(AccessibilityIdentifier.image.rawValue)
    }
  }

  @ViewBuilder
  private func viewFooter() -> some View {
    FooterView {
      footer
        .accessibilityIdentifier(AccessibilityIdentifier.footer.rawValue)
    }
  }

  @ViewBuilder
  private func viewContent() -> some View {
    content
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

}

// MARK: - Portrait layout

extension InformationView {

  @ViewBuilder
  private func portraitLayout() -> some View {
    ViewThatFits(in: .vertical) {
      portraitContentLayout()
      portraitScrollableContentLayout()
    }
  }

  @ViewBuilder
  private func portraitContentLayout() -> some View {
    VStack(spacing: 0) {
      portraitMainContent()
      Spacer()
      viewFooter()
    }
  }

  @ViewBuilder
  private func portraitScrollableContentLayout() -> some View {
    ScrollView {
      VStack(spacing: 0) {
        portraitMainContent()
        if sizeCategory.isAccessibilityCategory {
          viewFooter()
        }
      }
    }
    .if(!sizeCategory.isAccessibilityCategory, transform: {
      $0.safeAreaInset(edge: .bottom) {
        viewFooter()
      }
    })
    .overlay(alignment: .top) {
      Color.clear
        .background(ThemingAssets.Brand.Core.white.swiftUIColor)
        .ignoresSafeArea(edges: .top)
        .frame(height: 0)
    }
  }

  @ViewBuilder
  private func portraitMainContent() -> some View {
    VStack(spacing: .x6) {
      card()
        .if(sizeCategory.isAccessibilityCategory) {
          $0.frame(maxHeight: Constants.cardAccessibilityMaxHeight)
        }
        .padding(.top, .x3)

      content
        .accessibilityFocused($isCurrentPageFocused)

      Spacer()
    }
  }
}

// MARK: - Landscape layout

extension InformationView {

  @ViewBuilder
  private func landscapeLayout() -> some View {
    ViewThatFits(in: .vertical) {
      landscapeContentLayout()
      landscapeScrollableContentLayout()
    }
  }

  @ViewBuilder
  private func landscapeContentLayout() -> some View {
    HStack {
      card()
        .padding(.x3)

      VStack(spacing: .x6) {
        viewContent()
          .padding(.top, .x3)
        Spacer()
        viewFooter()
      }
    }
  }

  @ViewBuilder
  private func landscapeScrollableContentLayout() -> some View {
    HStack {
      card()
        .padding(.x3)

      ScrollView {
        VStack(spacing: .x6) {
          viewContent()
            .padding(.top, .x3)
          Spacer()
        }
      }
      .safeAreaInset(edge: .bottom) {
        viewFooter()
          .background(ThemingAssets.Materials.chrome.swiftUIColor)
      }
    }
  }
}
