import SwiftUI

// MARK: - PrimitiveProgressBar

struct PrimitiveProgressBar: View {

  // MARK: Lifecycle

  init(image: Image, position: CGFloat) {
    self.image = image
    self.position = position
  }

  // MARK: Internal

  var image: Image
  var position: CGFloat

  var body: some View {
    Capsule()
      .overlay(
        image
          .resizable()
          .frame(width: 1000, height: 1000)
          .offset(x: position)
      )
      .clipped()
      .clipShape(.capsule)
  }

}
