import Foundation
import PopupView
import SwiftUI

extension View {
  public func toastMessage(isPresented: Binding<Bool>, message: String?, type: ToastType = .success, clearAction: @escaping () -> Void) -> some View {
    popup(isPresented: isPresented) {
      if let toastMessage = message {
        Text(toastMessage)
          .font(.custom.footnote)
          .foregroundStyle(type.foregroundColor)
          .padding(.horizontal, .x3)
          .padding(.vertical, .x2)
          .background(type.backgroundColor)
          .clipShape(.capsule)
      }
    } customize: {
      $0
        .type(.floater(verticalPadding: .x30, useSafeAreaInset: true))
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

// MARK: - ToastType

public enum ToastType {
  case success
  case error

  // MARK: Fileprivate

  fileprivate var foregroundColor: Color {
    switch self {
    case .error:
      ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor
    case .success:
      ThemingAssets.Brand.Bright.firGreenLabel.swiftUIColor
    }
  }

  fileprivate var backgroundColor: Color {
    switch self {
    case .error:
      ThemingAssets.Brand.Bright.swissRed.swiftUIColor
    case .success:
      ThemingAssets.Brand.Bright.firGreen.swiftUIColor
    }
  }
}
