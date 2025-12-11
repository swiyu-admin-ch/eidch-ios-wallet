import SwiftUI

// MARK: - LandscapeMaxWidthViewModifier

public struct LandscapeMaxWidthViewModifier: ViewModifier {

  let maxWidth: CGFloat

  init(maxWidth: CGFloat) {
    self.maxWidth = maxWidth
  }

  public func body(content: Content) -> some View {
    if orientation.isLandscape {
      content.frame(maxWidth: maxWidth)
    } else {
      content
    }
  }

  @Orientation private var orientation
}

extension View {
  public func landscapeMaxWidth(_ maxWidth: CGFloat = 568) -> some View {
    modifier(LandscapeMaxWidthViewModifier(maxWidth: maxWidth))
  }
}
