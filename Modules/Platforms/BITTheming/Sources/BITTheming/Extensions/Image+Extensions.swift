import Foundation
import SwiftUI

extension Image {

  // MARK: Lifecycle

  public init?(data: Data, rotation: Angle? = nil) {
    guard var image = UIImage(data: data) else { return nil }

    if let rotation, let rotatedImage = image.rotated(by: rotation) {
      image = rotatedImage
    }

    self = Image(uiImage: image)
  }

  // MARK: Public

  public func applyCircleShape(size: CGFloat = 26, padding: CGFloat = .x3, backgroundColor: Color = ThemingAssets.gray4.swiftUIColor) -> some View {
    resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: size, height: size)
      .padding(padding)
      .background(backgroundColor)
      .clipShape(Circle())
  }

}
