import SwiftUI

// MARK: - NormalizedLogoCircular

public struct NormalizedLogoCircular: View {

  // MARK: Lifecycle

  public init(_ imageData: Data?) {
    self.imageData = imageData
  }

  // MARK: Public

  public var body: some View {
    (imageData.flatMap { Image(data: $0) } ?? ThemingAssets.unknownIcon.swiftUIImage)
      .renderingMode(.template)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: imageSize, height: imageSize)
      .foregroundColor(.white)
      .colorMultiply(colorScheme.standardColor())
      .padding((size - imageSize) / 2)
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .clipShape(Circle())
      .accessibilityHidden(true)
  }

  // MARK: Internal

  let imageData: Data?

  // MARK: Private

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.controlSize) private var controlSize
}

extension NormalizedLogoCircular {

  private var size: CGFloat {
    switch controlSize {
    case .mini: 34
    default: 48
    }
  }

  private var imageSize: CGFloat {
    switch controlSize {
    case .mini: 18
    default: 24
    }
  }
}
