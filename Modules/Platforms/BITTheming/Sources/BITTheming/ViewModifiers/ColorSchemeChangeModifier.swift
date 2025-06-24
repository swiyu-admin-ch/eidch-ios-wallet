import Factory
import SwiftUI

// MARK: - ColorSchemeChangeViewModifier

public struct ColorSchemeChangeViewModifier: ViewModifier {
  @Environment(\.colorScheme) private var colorScheme

  let onChange: (ColorScheme) -> Void

  public func body(content: Content) -> some View {
    content
      // forwards color scheme info at appearance time to initate view model setters
      .onAppear {
        onChange(colorScheme)
      }
      .onChange(of: colorScheme) { newScheme in
        onChange(newScheme)
      }
  }
}

extension View {
  public func onColorSchemeChange(_ onChange: @escaping (ColorScheme) -> Void) -> some View {
    modifier(ColorSchemeChangeViewModifier(onChange: onChange))
  }
}
