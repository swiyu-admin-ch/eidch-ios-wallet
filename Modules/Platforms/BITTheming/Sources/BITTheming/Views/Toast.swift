import Foundation
import PopupView
import SwiftUI

extension View {
  public func toastMessage(isPresented: Binding<Bool>, message: String?, clearAction: @escaping () -> Void) -> some View {
    popup(isPresented: isPresented) {
      if let toastMessage = message {
        Text(toastMessage)
          .font(.custom.footnote)
          .foregroundStyle(ThemingAssets.Brand.Bright.firGreenLabel.swiftUIColor)
          .padding(.horizontal, .x3)
          .padding(.vertical, .x2)
          .background(ThemingAssets.Brand.Bright.firGreen.swiftUIColor)
          .clipShape(.capsule)
      }
    } customize: {
      $0
        .type(.floater(verticalPadding: .x20, useSafeAreaInset: true))
        .position(.bottom)
        .autohideIn(5)
        .dragToDismiss(true)
        .animation(.easeInOut)
        .dismissCallback {
          clearAction()
        }
    }
  }
}
