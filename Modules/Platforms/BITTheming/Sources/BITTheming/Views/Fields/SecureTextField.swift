import BITL10n
import Foundation
import SwiftUI
import UIKit

// MARK: - SecureTextField

public struct SecureTextField: UIViewRepresentable {

  // MARK: Lifecycle

  public init(text: Binding<String>, prompt: String? = nil, textColor: UIColor? = nil, tintColor: UIColor, onSubmit: @escaping () -> Void = {}) {
    _text = text
    self.prompt = prompt
    self.onSubmit = onSubmit
    self.textColor = textColor
    self.tintColor = tintColor
  }

  // MARK: Public

  public class Coordinator: NSObject, UITextFieldDelegate {

    // MARK: Lifecycle

    init(_ parent: SecureTextField) {
      self.parent = parent
    }

    // MARK: Public

    public func textFieldDidChangeSelection(_ textField: UITextField) {
      parent.text = textField.text ?? ""
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      parent.onSubmit()
      return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      preventDotWhenAddingMultipleSpaces(textField, range, string)
    }

    // MARK: Internal

    var parent: SecureTextField
    weak var textField: UITextField?

    @objc
    func togglePasswordVisibility() {
      isSecure.toggle()
      textField?.isSecureTextEntry = isSecure

      let button = textField?.rightView as? UIButton
      let imageName = isSecure ? "eye.slash" : "eye"
      button?.setImage(UIImage(systemName: imageName), for: .normal)
      button?.accessibilityLabel = isSecure ? L10n.tkGlobalInvisibleAlt : L10n.tkGlobalVisibleAlt
    }

    // MARK: Private

    private var isSecure = true

    ///
    /// Prevent the dot entry in the input field when the user enters 2 or more spaces.
    ///
    private func preventDotWhenAddingMultipleSpaces(_ textField: UITextField, _ range: NSRange, _ string: String) -> Bool {
      guard range.location > 0, !string.isEmpty else { return true }

      let whitespace = CharacterSet.whitespaces
      let textStartIndex = string.unicodeScalars.startIndex

      guard let currentText = textField.text else { return true }

      let previousCharIndex = currentText.unicodeScalars.index(currentText.unicodeScalars.startIndex, offsetBy: range.location - 1)

      if
        whitespace.contains(string.unicodeScalars[textStartIndex]) &&
        whitespace.contains(currentText.unicodeScalars[previousCharIndex])
      {

        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: " ")
        textField.text = updatedText

        if let position = textField.position(from: textField.beginningOfDocument, offset: range.location + 1) {
          textField.selectedTextRange = textField.textRange(from: position, to: position)
        }

        return false
      }
      return true
    }
  }

  public func makeUIView(context: Context) -> UITextField {
    let textField = textField(context: context)
    let toggleButton = toggleButton(context: context)

    textField.rightView = toggleButton
    textField.rightViewMode = .always
    textField.shouldGroupAccessibilityChildren = false

    textField.accessibilityIdentifier = accessibilityIdentifier

    context.coordinator.textField = textField

    return textField
  }

  public func updateUIView(_ uiView: UITextField, context: Context) {
    uiView.text = text
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  // MARK: Internal

  @Binding var text: String

  // MARK: Private

  @Environment(\.secureTextFieldAccessibilityIdentifier) private var accessibilityIdentifier: String?

  private var prompt: String?
  private var onSubmit: () -> Void
  private let tintColor: UIColor
  private var textColor: UIColor?

  private func textField(context: Context) -> UITextField {
    let textField = UITextField()
    if let prompt {
      textField.attributedPlaceholder = NSAttributedString(string: prompt, attributes: [.foregroundColor: tintColor])
    }

    textField.textColor = textColor
    textField.isSecureTextEntry = true
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textField.keyboardType = .asciiCapable
    textField.returnKeyType = .done

    if
      let currentStyle = textField.defaultTextAttributes[.paragraphStyle, default: NSParagraphStyle()] as? NSParagraphStyle,
      let style = currentStyle.mutableCopy() as? NSMutableParagraphStyle
    {
      style.lineBreakMode = .byTruncatingHead
      textField.defaultTextAttributes[.paragraphStyle] = style
    }

    textField.delegate = context.coordinator
    textField.accessibilityIdentifier = accessibilityIdentifier
    return textField
  }

  private func toggleButton(context: Context) -> UIButton {
    let toggleButton = UIButton(type: .custom)
    toggleButton.setImage(UIImage(systemName: "eye.slash")?.withTintColor(tintColor, renderingMode: .alwaysOriginal), for: .normal)
    toggleButton.addTarget(context.coordinator, action: #selector(Coordinator.togglePasswordVisibility), for: .touchUpInside)
    toggleButton.isAccessibilityElement = true

    return toggleButton
  }

}

// MARK: - SecureTextFieldAccessibilityIdentifier

extension View {
  public func secureTextFieldAccessibilityIdentifier(_ identifier: String? = nil) -> some View {
    environment(\.secureTextFieldAccessibilityIdentifier, identifier)
  }
}

extension EnvironmentValues {
  @Entry var secureTextFieldAccessibilityIdentifier: String?
}
