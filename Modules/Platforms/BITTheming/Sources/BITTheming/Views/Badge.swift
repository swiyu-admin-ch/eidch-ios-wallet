import SwiftUI

// MARK: - Badge

public struct Badge<Content>: View where Content: View {

  // MARK: Lifecycle

  public init(@ViewBuilder label: @escaping () -> Content) {
    content = label
  }

  // MARK: Public

  public var body: some View {
    style
      .makeBody(configuration: BadgeStyleConfiguration(
        label: BadgeStyleConfiguration.Label(content: content()))
      )
      .clipShape(.capsule(style: .continuous))
  }

  // MARK: Private

  @Environment(\.badgeStyle) private var style

  @ViewBuilder private var content: () -> Content

}

// MARK: - BadgeStyle

public protocol BadgeStyle {
  associatedtype Body: View
  typealias Configuration = BadgeStyleConfiguration

  func makeBody(configuration: Self.Configuration) -> Self.Body
}

// MARK: - BadgeStyleConfiguration

public struct BadgeStyleConfiguration {

  /// A type-erased label of a Card.
  public struct Label: View {
    public init(content: some View) {
      body = AnyView(content)
    }

    public var body: AnyView
  }

  public let label: BadgeStyleConfiguration.Label
}

// MARK: - AnyBadgeStyle

public struct AnyBadgeStyle: BadgeStyle {
  private var _makeBody: (Configuration) -> AnyView

  public init(style: some BadgeStyle) {
    _makeBody = { configuration in
      AnyView(style.makeBody(configuration: configuration))
    }
  }

  public func makeBody(configuration: Configuration) -> some View {
    _makeBody(configuration)
      .labelStyle(.badge)
      .font(.custom.footnote)
      .lineLimit(1)
  }
}

// MARK: - BadgeStyleKey

public struct BadgeStyleKey: EnvironmentKey {
  public static var defaultValue = AnyBadgeStyle(style: DefaultBadgeStyle())
}

extension EnvironmentValues {
  public var badgeStyle: AnyBadgeStyle {
    get { self[BadgeStyleKey.self] }
    set { self[BadgeStyleKey.self] = newValue }
  }
}

extension View {
  public func badgeStyle(_ style: some BadgeStyle) -> some View {
    environment(\.badgeStyle, AnyBadgeStyle(style: style))
  }
}

// MARK: - BezeledGrayBadgeStyle

public struct BezeledGrayBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, .x3)
      .padding(.vertical, .x2)
      .background(ThemingAssets.Brand.Bright.navyBlue.swiftUIColor)
      .foregroundStyle(ThemingAssets.Brand.Bright.navyBlueLabel.swiftUIColor)
  }
}

extension BadgeStyle where Self == BezeledGrayBadgeStyle {
  public static var bezeledGray: BezeledGrayBadgeStyle { BezeledGrayBadgeStyle() }
}

// MARK: - DefaultBadgeStyle

public struct DefaultBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, .x3)
      .padding(.vertical, .x2)
      .background(Color.white.opacity(0.8))
  }
}

extension BadgeStyle where Self == DefaultBadgeStyle {
  public static var standard: DefaultBadgeStyle { DefaultBadgeStyle() }
}

// MARK: - PlainBadgeStyle

public struct PlainBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
  }
}

extension BadgeStyle where Self == PlainBadgeStyle {
  public static var plain: PlainBadgeStyle { PlainBadgeStyle() }
}

// MARK: - SuccessBadgeStyle

public struct SuccessBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, .x3)
      .padding(.vertical, .x2)
      .background(ThemingAssets.Brand.Bright.firGreen.swiftUIColor)
      .foregroundStyle(ThemingAssets.Brand.Bright.firGreenLabel.swiftUIColor)
  }
}

extension BadgeStyle where Self == SuccessBadgeStyle {
  public static var success: SuccessBadgeStyle { SuccessBadgeStyle() }
}

// MARK: - ErrorBadgeStyle

public struct ErrorBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, .x3)
      .padding(.vertical, .x2)
      .background(ThemingAssets.Brand.Bright.swissRed.swiftUIColor)
      .foregroundColor(ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor)
      .preferredColorScheme(.light)
  }
}

extension BadgeStyle where Self == ErrorBadgeStyle {
  public static var error: ErrorBadgeStyle { ErrorBadgeStyle() }
}

// MARK: - WarningBadgeStyle

public struct WarningBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, .x3)
      .padding(.vertical, .x2)
      .background(ThemingAssets.orange2.swiftUIColor)
      .foregroundColor(ThemingAssets.Brand.Accent.orange.swiftUIColor)
  }
}

extension BadgeStyle where Self == WarningBadgeStyle {
  public static var warning: WarningBadgeStyle { WarningBadgeStyle() }
}

// MARK: - OutlineBadgeStyle

public struct OutlineBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, .x3)
      .padding(.vertical, .x2)
      .overlay {
        RoundedRectangle(cornerRadius: 50)
          .stroke(ThemingAssets.Brand.Core.black.swiftUIColor.opacity(0.5), lineWidth: 1)
      }
  }
}

extension BadgeStyle where Self == OutlineBadgeStyle {
  public static var outline: OutlineBadgeStyle { OutlineBadgeStyle() }
}

// MARK: - InfoBadgeStyle

public struct InfoBadgeStyle: BadgeStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.horizontal, .x3)
      .padding(.vertical, .x2)
      .background(ThemingAssets.Brand.Bright.navyBlue.swiftUIColor)
      .foregroundColor(ThemingAssets.Brand.Bright.navyBlueLabel.swiftUIColor)
  }
}

extension BadgeStyle where Self == InfoBadgeStyle {
  public static var info: InfoBadgeStyle { InfoBadgeStyle() }
}

// MARK: - BadgeLabelStyle

public struct BadgeLabelStyle: LabelStyle {
  private var spacing = 0.0

  public init(spacing: Double) {
    self.spacing = spacing
  }

  public func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: spacing) {
      configuration.icon
        .scaleEffect(0.8)
      configuration.title
    }
  }
}

extension LabelStyle where Self == BadgeLabelStyle {
  public static var badge: BadgeLabelStyle { BadgeLabelStyle(spacing: 2) }
}
