import BITTheming
import SwiftUI

// MARK: - SettingsItem

struct SettingsItem: View {

  // MARK: Lifecycle

  init(image: Image, title: String, detail: String? = nil, type: SettingsItemType = .info, hasDivider: Bool = true) {
    self.init(icon: .image(image), title: title, detail: detail, type: type, hasDivider: hasDivider)
  }

  init(icon: SettingsIcon = .none, title: String, detail: String? = nil, type: SettingsItemType = .info, hasDivider: Bool = true) {
    self.icon = icon
    self.title = title
    self.detail = detail
    self.type = type
    self.hasDivider = hasDivider
  }

  // MARK: Internal

  let icon: SettingsIcon
  let title: String
  let detail: String?
  let type: SettingsItemType
  let hasDivider: Bool

  var body: some View {
    switch type {
    case .info:
      content
    case .link(let urlString):
      if let url = URL(string: urlString) {
        Link(destination: url, label: {
          content
        })
      }
    case .navigation(let action),
         .toggle(_, _, let action):
      Button(action: action) {
        content
      }
    }
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory
  @ScaledMetric(relativeTo: .body) private var trailingIconSize: CGFloat = 11
  @ScaledMetric(relativeTo: .body) private var leadingIconSize: CGFloat = 18

  private let itemMinHeight: CGFloat = 44

  private var content: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        leadingIcon()
          .accessibilityHidden(true)
        if sizeCategory.isAccessibilityCategory {
          verticalTexts()
        } else if case .toggle = type {
          verticalTexts()
        } else {
          horizontalTexts()
        }
        trailingView()
      }
      .accessibilityElement(children: .combine)
      .padding(.horizontal, .x6)
      .frame(minHeight: itemMinHeight, alignment: .center)
      if hasDivider {
        let leadingPadding: CGFloat = if case .none = icon { .x6 } else { leadingIconSize + .x12 }
        Divider()
          .padding(.leading, leadingPadding)
      }
    }
  }

  @ViewBuilder
  private func leadingIcon() -> some View {
    switch icon {
    case .image(let image):
      image
        .resizable()
        .scaledToFit()
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .frame(width: leadingIconSize, height: leadingIconSize)
        .padding(.trailing, .x6)
    case .empty:
      Color.clear
        .frame(width: leadingIconSize, height: leadingIconSize)
        .padding(.trailing, .x6)
    case .none:
      EmptyView()
    }
  }

  @ViewBuilder
  private func horizontalTexts() -> some View {
    HStack(spacing: 0) {
      Text(title)
        .multilineTextAlignment(.leading)
        .font(.custom.body)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
      Spacer(minLength: .x2)
      if let detail {
        let trailingPadding: CGFloat = if case .info = type { 0 } else { .x4 }
        Text(detail)
          .font(.custom.caption2)
          .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
          .padding(.trailing, trailingPadding)
      }
    }
    .padding(.vertical, .x2)
  }

  @ViewBuilder
  private func verticalTexts() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title)
        .multilineTextAlignment(.leading)
        .font(.custom.body)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
      if let detail {
        Text(detail)
          .multilineTextAlignment(.leading)
          .font(.custom.caption1)
          .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
      }
    }
    .padding(.vertical, .x2)
    Spacer()
  }

  @ViewBuilder
  private func trailingView() -> some View {
    switch type {
    case .info:
      EmptyView()
    case .link:
      Assets.external.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: trailingIconSize, height: trailingIconSize)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
        .accessibilityHidden(true)
    case .navigation:
      Assets.chevronRight.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: trailingIconSize, height: trailingIconSize)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
        .accessibilityHidden(true)
    case .toggle(let isOn, let isLoading, _):
      Toggle("", isOn: isOn)
        .tint(ThemingAssets.Brand.Core.firGreen.swiftUIColor)
        .labelsHidden()
        .disabled(isLoading.wrappedValue)
        .allowsHitTesting(false)
    }
  }

}

// MARK: - SettingsIcon

enum SettingsIcon {
  case none
  case empty
  case image(Image)
}

// MARK: - SettingsItemType

enum SettingsItemType {
  case info
  case navigation(action: () -> Void)
  case link(_ urlString: String)
  case toggle(isOn: Binding<Bool>, isLoading: Binding<Bool> = .constant(false), action: () -> Void)
}

#Preview {
  SettingsSection {
    VStack(spacing: 0) {
      SettingsItem(title: "Title", detail: "Detail")
      SettingsItem(title: "Title", detail: "Detail", type: .navigation {})
      SettingsItem(icon: .image(Assets.lock.swiftUIImage), title: "Title", type: .navigation {})
      SettingsItem(icon: .image(Assets.lock.swiftUIImage), title: "Title", detail: "Detail", type: .navigation {})
      SettingsItem(icon: .empty, title: "Title", type: .navigation {})
      SettingsItem(icon: .image(Assets.lock.swiftUIImage), title: "Title", type: .link("url"))
      SettingsItem(icon: .image(Assets.lock.swiftUIImage), title: "Title", type: .toggle(isOn: .constant(true), isLoading: .constant(false), action: {}))
      SettingsItem(icon: .image(Assets.lock.swiftUIImage), title: "Title", detail: "Detail", type: .toggle(isOn: .constant(true), isLoading: .constant(false), action: {}))
    }
  }
}
