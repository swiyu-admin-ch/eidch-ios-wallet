import BITL10n
import Foundation

// MARK: - ErrorDataset

public struct ErrorDataset {

  // MARK: Lifecycle

  public init(
    primary: String = L10n.tkErrorViewDefaultPrimaryButton,
    secondary: String,
    tertiary: String? = nil,
    primaryAction: (() -> Void)? = nil,
    primaryActionLabel: String? = nil,
    secondaryAction: (() -> Void)? = nil,
    secondaryActionLabel: String? = nil,
    tertiaryAction: (() -> Void)? = nil)
  {
    self.primary = primary
    self.secondary = secondary
    self.tertiary = tertiary
    self.tertiaryAction = tertiaryAction
    self.primaryAction = primaryAction
    self.primaryActionLabel = primaryActionLabel
    self.secondaryAction = secondaryAction
    self.secondaryActionLabel = secondaryActionLabel
  }

  public init(_ error: Error, primaryAction: (() -> Void)? = nil) {
    primary = L10n.emptyStateErrorTitle
    secondary = error.localizedDescription
    tertiary = nil
    tertiaryAction = nil
    self.primaryAction = primaryAction
    primaryActionLabel = nil
    secondaryAction = nil
    secondaryActionLabel = nil
  }

  // MARK: Internal

  let primary: String
  let secondary: String
  let tertiary: String?
  let tertiaryAction: (() -> Void)?

  let primaryAction: (() -> Void)?
  let primaryActionLabel: String?
  let secondaryAction: (() -> Void)?
  let secondaryActionLabel: String?

}

// MARK: Hashable

extension ErrorDataset: Hashable {

  public static func == (lhs: ErrorDataset, rhs: ErrorDataset) -> Bool {
    lhs.primary == rhs.primary &&
      lhs.secondary == rhs.secondary &&
      lhs.tertiary == rhs.tertiary &&
      lhs.primaryActionLabel == rhs.primaryActionLabel &&
      lhs.secondaryActionLabel == rhs.secondaryActionLabel
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(primary)
    hasher.combine(secondary)
    hasher.combine(tertiary)
    hasher.combine(primaryActionLabel)
    hasher.combine(secondaryActionLabel)
  }
}
