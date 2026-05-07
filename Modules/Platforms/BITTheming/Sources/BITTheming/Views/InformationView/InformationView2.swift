import BITL10n
import NavigatorUI
import SwiftUI

// MARK: - InformationView2

public struct InformationView2: View {

  // MARK: Lifecycle

  public init(
    contents: [ContentType] = [],
    actions: [ActionType] = [])
  {
    self.contents = contents
    self.actions = actions
  }

  public init(
    image: Image,
    contents: [ContentType] = [],
    actions: [ActionType] = [])
  {
    self.contents = [.hero(image: image)] + contents
    self.actions = actions
  }

  // MARK: Public

  public var body: some View {
    AdaptiveColumnsView(
      primaryContent: leftContent,
      secondaryContent: rightContent,
      footer: footerContent)
      .navigationBar(.default, scrollEdgeAppearance: .default)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case image
  }

  // MARK: Private

  private var contents: [ContentType]
  private var actions: [ActionType]

  private var heroContent: ContentType? {
    contents.first(where: \.isHero)
  }

  private var bodyContents: [ContentType] {
    contents.filter { $0.isHero == false }
  }

  private func leftContent() -> some View {
    heroContent?.body
  }

  private func rightContent() -> some View {
    VStack(alignment: .leading, spacing: .x3) {
      ForEach(bodyContents.indices, id: \.self) { index in
        bodyContents[index].body
      }
    }
    .padding(.horizontal, .x6)
    .accessibilityElement(children: .contain)
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  private func footerContent() -> some View {
    if actions.isEmpty {
      EmptyView()
    } else {
      ButtonSheet {
        VStack(spacing: .x2) {
          ForEach(actions.indices, id: \.self) { index in
            actions[index].body
          }
        }
      }
    }
  }

}

extension InformationView2 {
  public enum Hero {
    case image(Image)
    case view(AnyView)
    case card(AnyView)

    @ViewBuilder
    var body: some View {
      switch self {
      case .image(let image):
        image
          .resizable()
          .scaledToFit()
      case .view(let view):
        view
      case .card(let view):
        view
      }
    }
  }

  public enum ContentType {
    case title(_ label: String, alt: String? = nil, identifier: String? = nil)
    case body(_ label: String, alt: String? = nil, identifier: String? = nil)
    case bodyBold(_ label: String, alt: String? = nil, identifier: String? = nil)
    case spacer(_ size: CGFloat = .x4)
    case caption(_ label: String, alt: String? = nil, identifier: String? = nil)
    case captionErrorDescription(_ error: Error, alt: String? = nil, identifier: String? = nil)
    case captionButton(_ label: String, alt: String? = nil, identifier: String? = nil, (Navigator) -> Void)
    case hero(Hero)
    case anyView(AnyView)

    // MARK: Public

    @MainActor public var body: some View {
      ContentTypeView(self)
    }

    public static func hero(image: Image) -> ContentType {
      .hero(.image(image))
    }

    public static func hero(@ViewBuilder _ content: () -> some View) -> ContentType {
      .hero(.view(AnyView(content())))
    }

    public static func heroCard(@ViewBuilder _ content: () -> some View) -> ContentType {
      .hero(.card(AnyView(content())))
    }

    public static func anyView(@ViewBuilder _ content: () -> some View) -> ContentType {
      .anyView(AnyView(content()))
    }

    // MARK: Internal

    var isHero: Bool {
      if case .hero = self {
        return true
      }
      return false
    }
  }

  // MARK: - ActionType

  public enum ActionType {
    case primary(_ label: String, alt: String? = nil, identifier: String? = nil, (Navigator) -> Void)
    case secondary(_ label: String, alt: String? = nil, identifier: String? = nil, (Navigator) -> Void)
    case primaryAsync(_ label: String, alt: String? = nil, identifier: String? = nil, actionOptions: Set<AsyncActionOption> = Set(AsyncActionOption.allCases), (Navigator) async -> Void)
    case secondaryAsync(_ label: String, alt: String? = nil, identifier: String? = nil, actionOptions: Set<AsyncActionOption> = Set(AsyncActionOption.allCases), (Navigator) async -> Void)
    case anyView(AnyView)

    // MARK: Public

    @MainActor public var body: some View {
      ActionTypeView(self)
    }

    public static func anyView(@ViewBuilder _ content: () -> some View) -> ActionType {
      .anyView(AnyView(content()))
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
        .accessibilityPriorityFocus()
    case .body(let label, let alt, let identifier):
      Text(label)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(alt ?? label)
        .accessibility(identifier: identifier ?? alt ?? label)
    case .bodyBold(let label, let alt, let identifier):
      Text(label)
        .font(.custom.bodyBold)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(alt ?? label)
        .accessibility(identifier: identifier ?? alt ?? label)
    case .spacer(let size):
      Spacer()
        .frame(height: size)
    case .caption(let label, let alt, let identifier):
      Text(label)
        .font(.custom.footnote)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(alt ?? label)
        .accessibility(identifier: identifier ?? alt ?? label)
    case .captionErrorDescription(let error, let alt, let identifier):
      let label = "\(String(describing: error))\n\(error.localizedDescription)"
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
        .accessibilityLabel((alt ?? label) + ", " + L10n.tkGlobalExternalLinkAlt)
        .accessibilityAddTraits(.isLink)
        .accessibility(identifier: identifier ?? alt ?? label)
    case .anyView(let view):
      view
    case .hero(let hero):
      switch hero {
      case .image(let image):
        Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor), image: image)
          .accessibilityHidden(true)
          .accessibilityIdentifier(InformationView2.AccessibilityIdentifier.image.rawValue)
      case .view(let view):
        view
          .accessibilityIdentifier(InformationView2.AccessibilityIdentifier.image.rawValue)
      case .card(let view):
        Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) { view }
          .accessibilityHidden(true)
          .accessibilityIdentifier(InformationView2.AccessibilityIdentifier.image.rawValue)
      }
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
    case .primaryAsync(let label, let alt, let identifier, let actionOptions, let action):
      asyncButton(label: label, alt: alt, identifier: identifier, actionOptions: actionOptions, action)
    case .secondaryAsync(let label, let alt, let identifier, let actionOptions, let action):
      asyncButton(label: label, alt: alt, identifier: identifier, actionOptions: actionOptions, style: .secondary, action)
    case .anyView(let view):
      view
    }
  }

  // MARK: Private

  private let actionType: InformationView2.ActionType

  private func button(
    label: String, alt: String? = nil, identifier: String? = nil,
    style: CustomButtonStyle = .primary, _ action: @escaping ((Navigator) -> Void))
    -> some View
  {
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

  private func asyncButton(label: String, alt: String? = nil, identifier: String? = nil, actionOptions: Set<AsyncActionOption> = Set(AsyncActionOption.allCases), style: CustomButtonStyle = .primary, _ action: @escaping ((Navigator) async -> Void)) -> some View {
    AsyncButton(action: { await action(navigator) }, actionOptions: actionOptions) {
      AnyView(
        Text(label)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity))
    }
    .buttonStyle(style)
    .controlSize(.large)
    .accessibilityLabel(alt ?? label)
    .accessibility(identifier: identifier ?? alt ?? label)
  }
}

extension [InformationView2.ContentType] {
  public func containsHero() -> Bool {
    contains(where: \.isHero)
  }
}

#if DEBUG
#Preview {
  NavigationStack {
    InformationView2(
      image: ThemingAssets.camera.swiftUIImage,
      contents: [
        InformationView2.previewContentTitle,
        InformationView2.previewContentBody,
        .spacer(),
        .bodyBold("At vero eos et accusam et justo duo dolores et ea rebum."),
      ],
      actions: InformationView2.previewActions)
  }
}

#Preview("Error") {
  NavigationStack {
    InformationView2(
      image: ThemingAssets.closeCircle.swiftUIImage,
      contents: [
        InformationView2.previewContentTitle,
        InformationView2.previewContentBody,
        .spacer(),
        .captionErrorDescription(CredentialErrorMock.expiredInvitation),
      ],
      actions: InformationView2.previewActions)
  }
}

extension InformationView2 {
  fileprivate static let previewActions = [
    ActionType.primary("Primary", { _ in }),
    ActionType.secondary("Secondary", { _ in }),
  ]
  fileprivate static let previewContentTitle = ContentType.title("Lorem ipsum")
  fileprivate static let previewContentBody = ContentType.body("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.")
}

// MARK: - CredentialErrorMock

private enum CredentialErrorMock: LocalizedError {
  case expiredInvitation
  var errorDescription: String? {
    "access token is expired"
  }
}
#endif
