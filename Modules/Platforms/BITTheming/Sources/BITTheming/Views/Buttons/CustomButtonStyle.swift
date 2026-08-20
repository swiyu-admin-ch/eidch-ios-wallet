import SwiftUI

extension ButtonStyle where Self == CustomButtonStyle {
  public static var bezeled: CustomButtonStyle {
    CustomButtonStyle(buttonConfiguration: .bezeled)
  }

  public static var secondary: CustomButtonStyle {
    CustomButtonStyle(buttonConfiguration: .secondary)
  }

  public static var destructive: CustomButtonStyle {
    CustomButtonStyle(buttonConfiguration: .destructive)
  }

  public static var primary: CustomButtonStyle {
    CustomButtonStyle(buttonConfiguration: .primary)
  }

  public static var tertiary: CustomButtonStyle {
    CustomButtonStyle(buttonConfiguration: .tertiary)
  }

  public static var firGreen: CustomButtonStyle {
    CustomButtonStyle(buttonConfiguration: .firGreen)
  }

  public static var navyBlue: CustomButtonStyle {
    CustomButtonStyle(buttonConfiguration: .navyBlue)
  }

  public static var warning: CustomButtonStyle {
    CustomButtonStyle(buttonConfiguration: .warning)
  }
}

// MARK: - CircleButton

public struct CircleButton<Label: View>: View {

  // MARK: Lifecycle

  public init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
    self.action = action
    self.label = label
  }

  public init(action: @escaping () -> Void, imageSystemName: String) where Label == Image {
    self.action = action
    label = { Image(systemName: imageSystemName) }
  }

  public init(action: @escaping () -> Void, imageName: String) where Label == Image {
    self.action = action
    label = { Image(imageName) }
  }

  // MARK: Public

  @MainActor public var body: some View {
    Button(action: action, label: label)
      .clipShape(.circle)
      .contentShape(.accessibility, .circle)
  }

  // MARK: Internal

  var action: () -> Void
  var label: () -> Label

}

// MARK: - CustomButton

public struct CustomButton: View {

  // MARK: Lifecycle

  public init(
    configuration: ButtonStyle.Configuration,
    buttonConfiguration: CustomButtonConfiguration)
  {
    self.configuration = configuration
    self.buttonConfiguration = buttonConfiguration
  }

  // MARK: Public

  public var body: some View {
    configuration.label
      .lineLimit(sizeCategory.isAccessibilityCategory ? nil : 1)
      .padding(.horizontal, horizontalPadding)
      .padding(.vertical, verticalPadding)
      .font(font)
      .background(isEnabled ? buttonConfiguration.backgroundColor : buttonConfiguration.backgroundColorDisabled)
      .if(buttonConfiguration.isMaterialEnabled, transform: {
        $0.background(isEnabled ? .thinMaterial : .ultraThinMaterial, in: .capsule)
      })
      .background(configuration.isPressed ? .black.opacity(0.3) : .clear)
      .foregroundColor(isEnabled ? buttonConfiguration.foregroundColor : buttonConfiguration.foregroundColorDisabled)
      .progressViewStyle(CircularProgressViewStyle(tint: isEnabled ? buttonConfiguration.progressViewTint : ThemingAssets.Label.tertiary.swiftUIColor))
      .clipShape(shape)
      .contentShape(.accessibility, shape)
      .overlay {
        shape.stroke(buttonConfiguration.borderColor, lineWidth: buttonConfiguration.borderWidth)
      }
      .scaleEffect(configuration.isPressed ? CGSize(width: 0.95, height: 0.95) : CGSize(width: 1.0, height: 1.0))
      .animation(.interactiveSpring, value: configuration.isPressed)
      .border(width: accessibilityShowButtonShapes ? 1 : 0, color: ThemingAssets.Brand.Core.black.swiftUIColor)
  }

  // MARK: Internal

  let configuration: ButtonStyle.Configuration
  let buttonConfiguration: CustomButtonConfiguration

  // MARK: Private

  @Environment(\.controlSize) private var controlSize
  @Environment(\.accessibilityShowButtonShapes) private var accessibilityShowButtonShapes
  @Environment(\.isEnabled) private var isEnabled: Bool
  @Environment(\.sizeCategory) private var sizeCategory

  private var horizontalPadding: CGFloat {
    switch controlSize {
    case .mini: .x2
    case .small: .x3
    case .regular: .x4
    case .large: .x6
    case .extraLarge: .x8
    @unknown default:
      .x4
    }
  }

  private var verticalPadding: CGFloat {
    switch controlSize {
    case .mini,
         .small: .x1
    case .regular: .x2
    case .large: .x3
    case .extraLarge: .x4
    @unknown default:
      .x2
    }
  }

  private var font: SwiftUI.Font {
    switch controlSize {
    case .mini,
         .regular,
         .small:
      .custom.subheadline
    case .extraLarge,
         .large:
      .custom.body
    @unknown default:
      .custom.body
    }
  }

  private var shape: RoundedRectangle {
    RoundedRectangle(cornerRadius: cornerRadius)
  }

  private var cornerRadius: CGFloat {
    buttonConfiguration.cornerRadius ?? (sizeCategory.isAccessibilityCategory ? .x6 : .x30)
  }

}

// MARK: - CustomButtonStyle

public struct CustomButtonStyle: ButtonStyle {

  private var buttonConfiguration: CustomButtonConfiguration

  public init(buttonConfiguration: CustomButtonConfiguration) {
    self.buttonConfiguration = buttonConfiguration
  }

  public func makeBody(configuration: Configuration) -> some View {
    CustomButton(configuration: configuration, buttonConfiguration: buttonConfiguration)
  }
}
