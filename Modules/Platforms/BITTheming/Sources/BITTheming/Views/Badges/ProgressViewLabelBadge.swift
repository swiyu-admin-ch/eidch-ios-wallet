import SwiftUI

public struct ProgressViewLabelBadge: View {

  // MARK: Lifecycle

  public init(text: String, background: Color, foreground: Color? = nil, accessibilityLabel: String? = nil) {
    self.text = text
    self.background = background
    self.foreground = foreground
    self.accessibilityLabel = accessibilityLabel

  }

  // MARK: Public

  public var body: some View {
    HStack(spacing: .x2) {
      ProgressView()
        .tint(foreground)
        .accessibilityHidden(true)

      Text(text)
        .font(.custom.footnote)
        .accessibilityLabel(accessibilityLabel ?? text)
    }
    .padding(.horizontal, .x4)
    .padding(.vertical, .x2)
    .background(background)
    .clipShape(.rect(cornerRadius: .x6))
  }

  // MARK: Private

  private let text: String
  private let background: Color
  private let foreground: Color?
  private let accessibilityLabel: String?
}
