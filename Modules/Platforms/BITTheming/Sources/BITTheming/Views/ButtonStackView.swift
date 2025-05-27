import Foundation
import SwiftUI

// MARK: - ButtonStackView

public struct ButtonStackView<Content: View>: View {

  // MARK: Lifecycle

  public init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
  }

  // MARK: Public

  public var body: some View {
    layout {
      content()
    }
  }

  // MARK: Internal

  @Environment(\.sizeCategory) var sizeCategory

  let content: () -> Content

  // MARK: Private

  private var layout: AnyLayout {
    sizeCategory.isAccessibilityCategory ? AnyLayout(VStackLayout(spacing: .x2)) : AnyLayout(HStackLayout(spacing: .x2))
  }

}
