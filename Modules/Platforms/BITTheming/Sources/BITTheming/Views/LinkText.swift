import BITL10n
import SwiftUI

// MARK: - CustomLink

public struct CustomLink: View {

  // MARK: Lifecycle

  public init(to url: URL, label: String) {
    self.label = label
    self.url = url
  }

  // MARK: Public

  public var body: some View {
    Link(destination: url) {
      HStack(alignment: .lastTextBaseline, spacing: .x1) {
        Text(label)
          .font(.custom.footnote)
        Image(systemName: "chevron.right")
          .font(.caption)
      }
      .multilineTextAlignment(.leading)
      .foregroundStyle(ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor)
    }
    .accessibilityLabel(accessibilityText)
    .accessibilityElement(children: .combine)
    .accessibilityRemoveTraits(.isLink)
    .accessibilityRemoveTraits(.isButton)
  }

  // MARK: Private

  private let label: String
  private let url: URL

  private var accessibilityText: String {
    label + ", " + L10n.tkGlobalExternalLinkAlt
  }
}

// MARK: - ButtonLinkText

public struct ButtonLinkText: View {

  // MARK: Lifecycle

  public init(_ text: String, _ action: @escaping () -> Void) {
    self.text = text
    self.action = action
  }

  // MARK: Public

  public var body: some View {
    Button(action: action, label: {
      HStack(alignment: .lastTextBaseline, spacing: .x1) {
        Text(text)
        Image(systemName: "chevron.right")
          .font(.caption)
      }
      .multilineTextAlignment(.leading)
    })
    .accessibilityElement(children: .combine)
    .accessibilityLabel(text)
    .accessibilityHint(L10n.tkGlobalExternalLinkAlt)
    .accessibilityRemoveTraits(.isButton)
    .accessibilityAddTraits(.isLink)
  }

  // MARK: Private

  private let text: String
  private let action: () -> Void

}

#Preview {
  ButtonLinkText("Test", {})
}

#if DEBUG
// swiftlint: disable force_unwrapping
#Preview {
  CustomLink(to: URL("www.admin.ch")!, label: "Test")
}
#endif
