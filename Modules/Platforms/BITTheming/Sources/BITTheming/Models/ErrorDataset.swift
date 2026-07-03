import BITL10n
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - ErrorDataset

public struct ErrorDataset {

  // MARK: Lifecycle

  public init(
    primary: String = L10n.tkErrorViewDefaultPrimaryButton,
    secondary: String,
    tertiary: String? = nil,
    primaryAction: (() -> Void)? = nil,
    primaryActionLabel: String? = L10n.tkErrorViewDefaultPrimaryButton,
    secondaryAction: (() -> Void)? = nil,
    secondaryActionLabel: String? = nil,
    tertiaryAction: (() -> Void)? = nil)
  {
    var contents = [InformationView2.ContentType]()
    var actions = [InformationView2.ActionType]()

    contents.append(.title(primary))
    contents.append(.body(secondary))
    if let tertiary {
      if let tertiaryAction {
        contents.append(.captionButton(tertiary, { _ in tertiaryAction() }))
      } else {
        contents.append(.caption(tertiary))
      }
    }

    if let primaryAction, let primaryActionLabel {
      actions.append(.primary(primaryActionLabel, { _ in
        primaryAction()
      }))
    }
    if let secondaryAction, let secondaryActionLabel {
      actions.append(.secondary(secondaryActionLabel, { _ in
        secondaryAction()
      }))
    }

    self.init(contents, actions: actions)
  }

  public init(_ contents: [InformationView2.ContentType], actions: [InformationView2.ActionType] = []) {
    self.contents = contents
    if self.contents.containsHero() == false {
      self.contents = [.hero(image: ThemingAssets.closeCircle.swiftUIImage)] + self.contents
    }
    self.actions = actions
  }

  public init(_ error: Error, _ actions: [InformationView2.ActionType]) {
    self.init([
      .title(L10n.tkErrorGenericPrimary),
      .body(L10n.tkErrorGenericSecondary),
      .captionButton(L10n.tkErrorGenericHelpLinkLabel, { _ in
        guard let url = URL(string: L10n.tkErrorGenericHelpLinkValue) else { return }
        UIApplication.shared.open(url)
      }),
      .captionErrorDescription(error),
    ], actions: actions)
  }

  @MainActor
  public init(_ error: Error) {
    self.init([
      .title(L10n.tkErrorGenericPrimary),
      .body(L10n.tkErrorGenericSecondary),
      .captionButton(L10n.tkErrorGenericHelpLinkLabel, { _ in
        guard let url = URL(string: L10n.tkErrorGenericHelpLinkValue) else { return }
        UIApplication.shared.open(url)
      }),
      .captionErrorDescription(error),
    ], actions: [
      .primary(L10n.tkErrorGenericButtonPrimary) { $0.pop() },
    ])
  }

  // MARK: Internal

  var contents: [InformationView2.ContentType]
  let actions: [InformationView2.ActionType]

}

extension ErrorDataset {
  public static func retry(_ error: Error, _ action: @escaping (Navigator) -> Void) -> Self {
    ErrorDataset(error, [.primary(L10n.tkErrorGenericButtonPrimary, action)])
  }
}

// MARK: Hashable

extension ErrorDataset: Hashable {

  // MARK: Public

  public static func == (lhs: ErrorDataset, rhs: ErrorDataset) -> Bool {
    lhs.contentLabels == rhs.contentLabels && lhs.actionLabels == rhs.actionLabels
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(contentLabels)
    hasher.combine(actionLabels)
  }

  // MARK: Private

  private var contentLabels: [String] {
    contents.compactMap { content in
      switch content {
      case .body(let label, _, _):
        label
      case .bodyBold(let label, _, _):
        label
      case .caption(let label, _, _):
        label
      case .captionButton(let label, _, _, _):
        label
      case .title(let label, _, _):
        label
      case .captionErrorDescription(let error, _, _):
        "\(String(describing: error))\n\(error.localizedDescription)"
      case .anyView,
           .hero,
           .spacer: nil
      }
    }
  }

  private var actionLabels: [String] {
    actions.compactMap { action in
      switch action {
      case .primary(let label, _, _, _, _),
           .primaryAsync(let label, _, _, _, _),
           .secondary(let label, _, _, _),
           .secondaryAsync(let label, _, _, _, _):
        label
      case .anyView:
        nil
      }
    }
  }

}
