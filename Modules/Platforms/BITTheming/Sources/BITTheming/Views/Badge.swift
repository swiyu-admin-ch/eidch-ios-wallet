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
    style.resolved(with: configuration)
      .clipShape(.rect(cornerRadius: .x4))
  }

  // MARK: Internal

  var configuration: BadgeStyleConfiguration {
    BadgeStyleConfiguration(label: label, image: image)
  }

  // MARK: Private

  @Environment(\.badgeStyle) private var style

}

// MARK: - BadgeStyle

public protocol BadgeStyle: DynamicProperty {
  associatedtype Body: View
  typealias Configuration = BadgeStyleConfiguration

  @ViewBuilder
  func makeBody(configuration: Configuration, badgeIconWidth: CGFloat) -> Body
}

extension BadgeStyle {
  func resolved(with configuration: BadgeStyleConfiguration) -> AnyView {
    AnyView(ResolvedBadgeStyle(base: self, configuration: configuration))
  }
}

// MARK: - BadgeStyleConfiguration

public struct BadgeStyleConfiguration {
  public let label: String
  public let image: Image?
}

extension EnvironmentValues {

  @Entry var badgeStyle: any BadgeStyle = DefaultBadgeStyle()

}

extension View {
  public func badgeStyle(_ style: any BadgeStyle) -> some View {
    environment(\.badgeStyle, style)
  }
}

// MARK: - ResolvedBadgeStyle

struct ResolvedBadgeStyle<Base: BadgeStyle>: View {
  let base: Base
  let configuration: BadgeStyleConfiguration

  var body: some View {
    base.makeBody(configuration: configuration, badgeIconWidth: badgeIconWidth)
  }

  @ScaledMetric(relativeTo: .body) private var badgeIconWidth = 14
}

// MARK: - DefaultBadgeStyle

public struct DefaultBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration, badgeIconWidth: CGFloat) -> some View {
    HStack(spacing: 3) {
      configuration.image?
        .resizable()
        .scaledToFit()
        .frame(width: badgeIconWidth)
        .accessibilityHidden(true)
      Text(configuration.label)
        .font(.custom.footnote)
        .lineLimit(1)
    }
    .padding(.vertical, .x2)
  }
}

// MARK: - InfoBadgeStyle

public struct InfoBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration, badgeIconWidth: CGFloat) -> some View {
    DefaultBadgeStyle().makeBody(configuration: configuration, badgeIconWidth: badgeIconWidth)
      .padding(.horizontal, .x3)
      .background(ThemingAssets.Brand.Bright.navyBlue.swiftUIColor)
      .foregroundStyle(ThemingAssets.Brand.Bright.navyBlueLabel.swiftUIColor)
  }
}

extension BadgeStyle where Self == InfoBadgeStyle {
  public static var info: InfoBadgeStyle {
    InfoBadgeStyle()
  }
}

// MARK: - SuccessBadgeStyle

public struct SuccessBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration, badgeIconWidth: CGFloat) -> some View {
    DefaultBadgeStyle().makeBody(configuration: configuration, badgeIconWidth: badgeIconWidth)
      .padding(.horizontal, .x3)
      .background(ThemingAssets.Brand.Bright.firGreen.swiftUIColor)
      .foregroundStyle(ThemingAssets.Brand.Bright.firGreenLabel.swiftUIColor)
  }
}

extension BadgeStyle where Self == SuccessBadgeStyle {
  public static var success: SuccessBadgeStyle {
    SuccessBadgeStyle()
  }
}

// MARK: - ErrorBadgeStyle

public struct ErrorBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration, badgeIconWidth: CGFloat) -> some View {
    DefaultBadgeStyle().makeBody(configuration: configuration, badgeIconWidth: badgeIconWidth)
      .padding(.horizontal, .x3)
      .background(ThemingAssets.Brand.Bright.swissRed.swiftUIColor)
      .foregroundColor(ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor)
  }
}

extension BadgeStyle where Self == ErrorBadgeStyle {
  public static var error: ErrorBadgeStyle {
    ErrorBadgeStyle()
  }
}

// MARK: - SensitiveBadgeStyle

public struct SensitiveBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration, badgeIconWidth: CGFloat) -> some View {
    DefaultBadgeStyle().makeBody(configuration: configuration, badgeIconWidth: badgeIconWidth)
      .padding(.horizontal, .x3)
      .background(ThemingAssets.Component.Pill.brightPurple.swiftUIColor)
      .foregroundColor(ThemingAssets.Component.Pill.brightPurpleLabel.swiftUIColor)
  }
}

extension BadgeStyle where Self == SensitiveBadgeStyle {
  public static var sensitive: SensitiveBadgeStyle {
    SensitiveBadgeStyle()
  }
}

// MARK: - OutlineBadgeStyle

public struct OutlineBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration, badgeIconWidth: CGFloat) -> some View {
    DefaultBadgeStyle().makeBody(configuration: configuration, badgeIconWidth: badgeIconWidth)
      .padding(.horizontal, .x3)
      .overlay {
        RoundedRectangle(cornerRadius: 50)
          .stroke(ThemingAssets.Brand.Core.black.swiftUIColor.opacity(0.5), lineWidth: 1)
      }
  }
}

extension BadgeStyle where Self == OutlineBadgeStyle {
  public static var outline: OutlineBadgeStyle {
    OutlineBadgeStyle()
  }
}
