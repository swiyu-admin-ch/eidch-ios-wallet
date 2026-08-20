import SwiftUI

// MARK: - Card

public struct Card<Content: View>: View {

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
        } else if let content {
          content
        } else if let image {
          image
            .resizable()
            .scaledToFit()
            .frame(width: maxWidthContent, height: maxHeightContent)
        }
      }
      .padding(lottieView == nil ? .x8 : 0)
    }
    .frame(maxWidth: .infinity, minHeight: minHeightCard, idealHeight: idealHeightCard, maxHeight: maxHeightCard)
    .background(background.view)
    .cornerRadius(cornerRadius)
    .contentShape(.accessibility, .rect(cornerRadius: cornerRadius))
    .if(((sizeCategory.isAccessibilityCategory && orientation.isPortrait) || orientation.isFlat) && cardAccessibilityMaxHeight != nil) {
      $0.frame(maxHeight: cardAccessibilityMaxHeight)
    }
  }

  // MARK: Internal

  @Environment(\.sizeCategory) var sizeCategory
  @Environment(\.cardAccessibilityMaxHeight) var cardAccessibilityMaxHeight

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

  private let cornerRadius = CGFloat.x9
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

// MARK: - CardAccessibilityMaxHeightKey

private struct CardAccessibilityMaxHeightKey: EnvironmentKey {
  static let defaultValue: CGFloat? = 150
}

extension EnvironmentValues {
  var cardAccessibilityMaxHeight: CGFloat? {
    get { self[CardAccessibilityMaxHeightKey.self] }
    set { self[CardAccessibilityMaxHeightKey.self] = newValue }
  }
}

extension Card {
  public func disableAXResizing(_ disabled: Bool = true) -> some View {
    environment(\.cardAccessibilityMaxHeight, disabled ? nil : CardAccessibilityMaxHeightKey.defaultValue)
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
        .colorScheme(.light)
    }
  }
}
