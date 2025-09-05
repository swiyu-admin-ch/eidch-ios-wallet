import Foundation
import SwiftUI

public struct FooterView<Content: View>: View {

  // MARK: Lifecycle

  public init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
  }

  // MARK: Public

  public var body: some View {
    Group {
      if !sizeCategory.isAccessibilityCategory {
        ViewThatFits(in: .horizontal) {
          HStack(spacing: .x2) {
            content()
          }

          VStack(spacing: .x2) {
            content()
          }
        }
      } else {
        VStack(spacing: .x2) {
          content()
        }
      }
    }
    .padding(.vertical, .x4)
    .padding(.horizontal, .x4)
    .background(ThemingAssets.Materials.chrome.swiftUIColor)
  }

  // MARK: Internal

  @Environment(\.sizeCategory) var sizeCategory

  let content: () -> Content

}
