import SwiftUI

// MARK: - Badge

public struct Badge: View {

  // MARK: Lifecycle

  public init(label: String, image: Image? = nil) {
    self.label = label
    self.image = image
  }

  // MARK: Public

  public let label: String
  public let image: Image?

  public var body: some View {
    HStack(spacing: 3) {
      image?
        .resizable()
        .scaledToFit()
        .frame(width: badgeIconWidth)
        .accessibilityHidden(true)
      Text(label)
        .font(.custom.footnote)
        .lineLimit(1)
    }
    .padding(.vertical, .x2)
    .modifier(BadgeDecoration(badgeType: badgeType))
    .clipShape(.rect(cornerRadius: .x4))
  }

  // MARK: Private

  @Environment(\.badgeType) private var badgeType
  @ScaledMetric(relativeTo: .body) private var badgeIconWidth = 14

}

// MARK: - BadgeStyle

public enum BadgeStyle: Sendable, Equatable {
  case info
  case success
  case error
  case sensitive
}

// MARK: - BadgeType

public enum BadgeType: Sendable, Equatable {
  case filled(BadgeStyle)
  case plain(BadgeStyle)
}

extension EnvironmentValues {

  @Entry var badgeType = BadgeType.filled(.info)

}

extension View {
  public func badgeType(_ badgeType: BadgeType) -> some View {
    environment(\.badgeType, badgeType)
  }
}

// MARK: - BadgeDecoration

private struct BadgeDecoration: ViewModifier {
  let badgeType: BadgeType

  func body(content: Content) -> some View {
    switch badgeType {
    case .filled(let style):
      content
        .padding(.horizontal, .x3)
        .background(style.fillColor)
        .foregroundStyle(style.filledLabelColor)
    case .plain(let style):
      content
        .foregroundStyle(style.plainLabelColor)
    }
  }
}

extension BadgeStyle {

  fileprivate var fillColor: Color {
    switch self {
    case .info: ThemingAssets.Brand.Bright.navyBlue.swiftUIColor
    case .success: ThemingAssets.Brand.Bright.firGreen.swiftUIColor
    case .error: ThemingAssets.Brand.Bright.swissRed.swiftUIColor
    case .sensitive: ThemingAssets.Component.Pill.brightPurple.swiftUIColor
    }
  }

  fileprivate var filledLabelColor: Color {
    switch self {
    case .info: ThemingAssets.Brand.Bright.navyBlueLabel.swiftUIColor
    case .success: ThemingAssets.Brand.Bright.firGreenLabel.swiftUIColor
    case .error: ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor
    case .sensitive: ThemingAssets.Component.Pill.brightPurpleLabel.swiftUIColor
    }
  }

  fileprivate var plainLabelColor: Color {
    switch self {
    case .info: ThemingAssets.Label.secondary.swiftUIColor
    case .success: ThemingAssets.Brand.Bright.firGreenLabel.swiftUIColor
    case .error: ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor
    case .sensitive: ThemingAssets.Component.Pill.brightPurpleLabel.swiftUIColor
    }
  }
}
