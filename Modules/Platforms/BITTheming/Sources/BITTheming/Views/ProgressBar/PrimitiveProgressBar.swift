import SwiftUI

// MARK: - PrimitiveProgressBar

struct PrimitiveProgressBar: View {

  // MARK: Internal

  var image: Image
  var position: CGFloat

  var body: some View {
    Capsule()
      .overlay(
        image
          .resizable()
          .frame(width: 1000, height: 1000)
          .offset(x: position))
      .clipped()
      .clipShape(.capsule)
  }

}
