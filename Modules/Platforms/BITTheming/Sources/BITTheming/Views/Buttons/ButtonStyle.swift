import SwiftUI

// MARK: - FlatLinkStyle

/// Removes the opacity glitch when a navigation link is tapped or long pressed
public struct FlatLinkStyle: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
  }
}

extension ButtonStyle where Self == FlatLinkStyle {
  public static var flatLink: FlatLinkStyle {
    Self()
  }
}
