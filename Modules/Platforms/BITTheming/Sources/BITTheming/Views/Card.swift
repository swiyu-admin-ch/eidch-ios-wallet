import SwiftUI

// MARK: - Card

public struct Card<Content>: View where Content: View {

  // MARK: Lifecycle

  public init(background: CardBackground, @ViewBuilder content: () -> Content) {
    self.content = content()
    lottieView = nil
    image = nil
    self.background = background
  }

  // MARK: Public

  public var body: some View {
    VStack {
      VStack {
        if let lottieView {
          lottieView
            .frame(minWidth: minWidthContent, maxWidth: maxWidthContent, minHeight: minHeightContent, idealHeight: maxHeightContent, maxHeight: maxHeightContent)
            .colorScheme(colorScheme)
        } else if let content {
          content
            .preferredColorScheme(colorScheme)
        } else if let image {
          image
            .resizable()
            .scaledToFit()
            .frame(minWidth: minWidthContent, maxWidth: maxWidthContent, minHeight: minHeightContent, idealHeight: maxHeightContent, maxHeight: maxHeightContent)
            .colorScheme(colorScheme)
        }
      }
      .padding(.x8)
    }
    .frame(maxWidth: .infinity, minHeight: minHeightCard, idealHeight: idealHeightCard, maxHeight: maxHeightCard)
    .background(background.view)
    .cornerRadius(.x9)
    .if(sizeCategory.isAccessibilityCategory && orientation.isPortrait || orientation.isFlat) {
      $0.frame(maxHeight: 150)
    }
  }

  // MARK: Internal

  @Environment(\.colorScheme) var colorScheme
  @Environment(\.sizeCategory) var sizeCategory

  // MARK: Private

  @Orientation private var orientation

  private let content: Content?
  private let image: Image?
  private let lottieView: LottieView?
  private let background: CardBackground

  private let minWidthContent: CGFloat = 80
  private let maxWidthContent: CGFloat = 300
  private let minHeightContent: CGFloat = 80
  private let maxHeightContent: CGFloat = 180

  private let minHeightCard: CGFloat = 95
  private let maxHeightCard: CGFloat = 355
  private let idealHeightCard: CGFloat = 355
}

extension Card where Content == Image {
  public init(background: CardBackground, imageName: String) {
    image = Image(imageName)
    lottieView = nil
    content = nil
    self.background = background
  }

  public init(background: CardBackground, imageSystemName: String) {
    image = Image(systemName: imageSystemName)
    lottieView = nil
    content = nil
    self.background = background
  }

  public init(background: CardBackground, image: Image) {
    self.image = image
    lottieView = nil
    content = nil
    self.background = background
  }
}

extension Card where Content == LottieView {
  public init(background: CardBackground, lottieView: LottieView) {
    self.lottieView = lottieView
    image = nil
    content = nil
    self.background = background
  }
}

extension Card where Content == EmptyView {

  public init(background: CardBackground) {
    content = nil
    lottieView = nil
    image = nil
    self.background = background
  }

}

// MARK: - CardBackground

public enum CardBackground {
  case color(Color)
  case image(Image)
}

extension CardBackground {
  @ViewBuilder
  var view: some View {
    switch self {
    case .color(let color):
      color
    case .image(let image):
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .clipped()
        .preferredColorScheme(.light)
    }
  }
}
