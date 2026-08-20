import SwiftUI

extension TextField where Label == Text {
  public init(_ placeholder: String, text: Binding<String>, placeholderColor: Color, axis: Axis? = nil) {
    let prompt = Text(placeholder).foregroundStyle(placeholderColor)
    if let axis {
      self.init(placeholder, text: text, prompt: prompt, axis: axis)
    } else {
      self.init(placeholder, text: text, prompt: prompt)
    }
  }
}
