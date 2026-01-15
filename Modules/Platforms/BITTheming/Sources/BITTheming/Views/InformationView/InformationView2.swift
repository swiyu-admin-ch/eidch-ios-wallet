import NavigatorUI
import SwiftUI

// MARK: - InformationView2

public struct InformationView2: View {

  // MARK: Lifecycle

  public init(
    image: Image,
    contents: [ContentType] = [],
    actions: [ActionType] = [])
  {
    self.image = image
    self.contents = contents
    self.actions = actions
  }

  // MARK: Public

  public var body: some View {
    AdaptiveColumnsView(
      primaryContent: leftContent,
      secondaryContent: rightContent,
      footer: footerContent)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case image
  }

  // MARK: Private

  private var contents: [ContentType]
  private var actions: [ActionType]
  private var image: Image

  @ViewBuilder
  private func leftContent() -> some View {
    Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor), image: image)
      .foregroundStyle(ThemingAssets.Grays.white.swiftUIColor)
      .accessibilityHidden(true)
      .accessibilityIdentifier(AccessibilityIdentifier.image.rawValue)
  }

  @ViewBuilder
  private func rightContent() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      ForEach(contents.indices, id: \.self) { index in
        contents[index].body
      }
    }
    .padding(.horizontal, .x6)
    .accessibilityPriorityFocus()
    .accessibilityElement(children: .contain)
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  private func footerContent() -> some View {
    ButtonSheet {
      VStack(spacing: .x4) {
        ForEach(actions.indices, id: \.self) { index in
          actions[index].body
        }
      }
    }
  }
}

extension InformationView2 {
  public enum ContentType {
    case title(_ label: String, alt: String? = nil, identifier: String? = nil)
    case body(_ label: String, alt: String? = nil, identifier: String? = nil)
    case caption(_ label: String, alt: String? = nil, identifier: String? = nil)
    case captionButton(_ label: String, alt: String? = nil, identifier: String? = nil, (Navigator) -> Void)

    // MARK: Public

    @MainActor public var body: some View {
      ContentTypeView(self)
    }
  }

  // MARK: - ActionType

  public enum ActionType {
    case primary(_ label: String, alt: String? = nil, identifier: String? = nil, (Navigator) -> Void)
    case secondary(_ label: String, alt: String? = nil, identifier: String? = nil, (Navigator) -> Void)

    // MARK: Public

    @MainActor public var body: some View {
      ActionTypeView(self)
    }

  }
}

// MARK: - ContentTypeView

struct ContentTypeView: View {

  // MARK: Lifecycle

  init(_ contentType: InformationView2.ContentType) {
    self.contentType = contentType
  }

  // MARK: Internal

  @Environment(\.navigator) var navigator: Navigator

  var body: some View {
    switch contentType {
    case .title(let label, let alt, let identifier):
      Text(label)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(alt ?? label)
        .accessibilityAddTraits(.isHeader)
        .accessibility(identifier: identifier ?? alt ?? label)
    case .body(let label, let alt, let identifier):
      Text(label)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(alt ?? label)
        .accessibility(identifier: identifier ?? alt ?? label)
    case .caption(let label, let alt, let identifier):
      Text(label)
        .font(.custom.footnote)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(alt ?? label)
        .accessibility(identifier: identifier ?? alt ?? label)
    case .captionButton(let label, let alt, let identifier, let action):
      ButtonLinkText(label, { action(navigator) })
        .font(.custom.footnote)
        .foregroundColor(ThemingAssets.Component.Link.label.swiftUIColor)
        .accessibilityLabel(alt ?? label)
        .accessibility(identifier: identifier ?? alt ?? label)
    }
  }

  // MARK: Private

  private let contentType: InformationView2.ContentType

}

// MARK: - ActionTypeView

struct ActionTypeView: View {

  // MARK: Lifecycle

  init(_ actionType: InformationView2.ActionType) {
    self.actionType = actionType
  }

  // MARK: Internal

  @Environment(\.navigator) var navigator: Navigator

  var body: some View {
    switch actionType {
    case .primary(let label, let alt, let identifier, let action):
      button(label: label, alt: alt, identifier: identifier, action)
    case .secondary(let label, let alt, let identifier, let action):
      button(label: label, alt: alt, identifier: identifier, style: .secondary, action)
    }
  }

  // MARK: Private

  private let actionType: InformationView2.ActionType

  private func button(label: String, alt: String? = nil, identifier: String? = nil, style: CustomButtonStyle = .primary, _ action: @escaping ((Navigator) -> Void)) -> some View {
    Button(action: { action(navigator) }) {
      Text(label)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(style)
    .controlSize(.large)
    .accessibilityLabel(alt ?? label)
    .accessibility(identifier: identifier ?? alt ?? label)
  }
}
