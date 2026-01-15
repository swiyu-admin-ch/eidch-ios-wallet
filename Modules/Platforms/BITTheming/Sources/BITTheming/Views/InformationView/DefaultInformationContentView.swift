import SwiftUI

public struct DefaultInformationContentView: View {

  // MARK: Lifecycle

  public init(
    primary: String,
    primaryAlt: String? = nil,
    secondary: String? = nil,
    secondaryAlt: String? = nil,
    tertiary: String? = nil,
    tertiaryAlt: String? = nil,
    tertiaryAction: (() -> Void)? = nil)
  {
    self.primary = primary
    self.primaryAlt = primaryAlt
    self.secondary = secondary
    self.secondaryAlt = secondaryAlt
    self.tertiary = tertiary
    self.tertiaryAlt = tertiaryAlt
    self.tertiaryAction = tertiaryAction
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: .x6) {
      Text(primary)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(AccessibilityIdentifier.primaryText.rawValue)
        .accessibilityLabel(primaryAlt ?? primary)
        .accessibilityAddTraits(.isHeader)

      if let secondary {
        Text(secondary)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier(AccessibilityIdentifier.secondaryText.rawValue)
          .accessibilityLabel(secondaryAlt ?? secondary)
      }

      if let tertiary {
        if let tertiaryAction {
          ButtonLinkText(tertiary, { tertiaryAction() })
            .font(.custom.footnote)
            .foregroundColor(ThemingAssets.Component.Link.label.swiftUIColor)
            .accessibilityLabel(tertiary)
        } else {
          Text(tertiary)
            .font(.custom.footnote)
            .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier(AccessibilityIdentifier.tertiaryText.rawValue)
            .accessibilityLabel(tertiaryAlt ?? tertiary)
        }
      }
    }
    .accessibilityElement(children: .contain)
    .frame(maxWidth: .infinity)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case primaryText
    case secondaryText
    case tertiaryText
  }

  // MARK: Private

  private let primary: String
  private let primaryAlt: String?
  private let secondary: String?
  private let secondaryAlt: String?
  private let tertiary: String?
  private let tertiaryAlt: String?
  private let tertiaryAction: (() -> Void)?

}
