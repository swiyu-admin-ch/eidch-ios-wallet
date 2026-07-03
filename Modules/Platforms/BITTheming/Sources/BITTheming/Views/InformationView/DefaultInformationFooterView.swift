import SwiftUI

public struct DefaultInformationFooterView: View {

  // MARK: Lifecycle

  public init(
    primaryButtonLabel: String,
    primaryButtonLabelAlt: String? = nil,
    primaryButtonLabelHint: String? = nil,
    primaryButtonStyle: CustomButtonStyle = .primary,
    primaryButtonAction: @escaping (() -> Void),
    secondaryButtonLabel: String? = nil,
    secondaryButtonLabelAlt: String? = nil,
    secondaryButtonStyle: CustomButtonStyle = .secondary,
    secondaryButtonAction: (() -> Void)? = nil,
    secondaryButtonDisabled: Bool = false)
  {
    self.primaryButtonLabel = primaryButtonLabel
    self.primaryButtonLabelAlt = primaryButtonLabelAlt
    self.primaryButtonLabelHint = primaryButtonLabelHint
    self.primaryButtonStyle = primaryButtonStyle
    self.primaryButtonAction = primaryButtonAction
    self.secondaryButtonLabel = secondaryButtonLabel
    self.secondaryButtonLabelAlt = secondaryButtonLabelAlt
    self.secondaryButtonAction = secondaryButtonAction
    self.secondaryButtonStyle = secondaryButtonStyle
    self.secondaryButtonDisabled = secondaryButtonDisabled
  }

  // MARK: Public

  public var body: some View {
    ButtonSheet {
      VStack(spacing: .x4) {
        Button(action: { primaryButtonAction() }) {
          Text(primaryButtonLabel)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(primaryButtonStyle)
        .controlSize(.large)
        .accessibilityIdentifier(AccessibilityIdentifier.primaryButton.rawValue)
        .accessibilityLabel(primaryButtonLabelAlt ?? primaryButtonLabel)
        .if(let: primaryButtonLabelHint) { value, view in
          view.accessibilityHint(value)
        }

        if let secondaryButtonLabel {
          Button(action: { secondaryButtonAction?() }) {
            Text(secondaryButtonLabel)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity)
          }
          .disabled(secondaryButtonDisabled)
          .buttonStyle(secondaryButtonStyle)
          .controlSize(.large)
          .accessibilityIdentifier(AccessibilityIdentifier.secondaryButton.rawValue)
          .accessibilityLabel(secondaryButtonLabelAlt ?? secondaryButtonLabel)
        }
      }
    }
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case primaryButton
    case secondaryButton
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  private let primaryButtonLabel: String
  private let primaryButtonLabelAlt: String?
  private let primaryButtonLabelHint: String?
  private let primaryButtonStyle: CustomButtonStyle
  private let primaryButtonAction: () -> Void
  private let secondaryButtonLabel: String?
  private let secondaryButtonLabelAlt: String?
  private let secondaryButtonStyle: CustomButtonStyle
  private let secondaryButtonAction: (() -> Void)?
  private let secondaryButtonDisabled: Bool
}
