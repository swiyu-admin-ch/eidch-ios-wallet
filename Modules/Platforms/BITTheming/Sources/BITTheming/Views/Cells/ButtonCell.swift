import SwiftUI

// MARK: - ButtonCell

public struct ButtonCell: View {

  // MARK: Lifecycle

  public init(
    icon: Image,
    title: String,
    role: Role = .default,
    hasDivider: Bool = false,
    action: @escaping () -> Void)
  {
    self.icon = icon
    self.title = title
    self.role = role
    self.hasDivider = hasDivider
    self.action = action
  }

  // MARK: Public

  public enum Role {
    case `default`
    case destructive
  }

  public var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 0) {
          icon
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: iconSize, height: iconSize)
            .foregroundColor(role.foregroundColor)
            .padding(.trailing, .x3)
            .accessibilityHidden(true)
          Text(title)
            .multilineTextAlignment(.leading)
            .font(.custom.body)
            .foregroundColor(role.foregroundColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .x4)
        .frame(minHeight: 58)
        if hasDivider {
          Divider()
            .padding(.leading, iconSize + .x7)
        }
      }
    }
  }

  // MARK: Private

  @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 30

  private let hasDivider: Bool
  private let icon: Image
  private let title: String
  private let role: Role
  private let action: () -> Void
}

extension ButtonCell.Role {
  var foregroundColor: Color {
    switch self {
    case .default:
      ThemingAssets.Label.primary.swiftUIColor
    case .destructive:
      ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor
    }
  }
}
