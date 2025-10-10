import SwiftUI

// MARK: - ButtonSheet

public struct ButtonSheet<Content: View>: View {

  // MARK: Lifecycle

  public init(colorConfig: ColorConfig = .primary, @ViewBuilder _ content: @escaping () -> Content) {
    self.colorConfig = colorConfig
    self.content = content
  }

  // MARK: Public

  public enum ColorConfig {
    case primary
    case secondary
  }

  public var body: some View {
    content()
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.vertical, .x2)
      .padding(.horizontal, .x6)
      .background(
        backgroundColor
          .clipShape(
            RoundedCorner(radius: .xxl, corners: [.topLeft, .topRight])
          )
          .ignoresSafeArea(edges: .bottom)
      )
  }

  // MARK: Private

  private let content: () -> Content
  private let colorConfig: ColorConfig

  private var backgroundColor: Color {
    switch colorConfig {
    case .primary: ThemingAssets.Background.ButtonSheet.primary.swiftUIColor
    case .secondary: ThemingAssets.Background.ButtonSheet.secondary.swiftUIColor
    }
  }

}
