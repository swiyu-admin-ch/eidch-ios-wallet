import Foundation
import PopupView
import SwiftUI

// MARK: - Toast

public struct Toast: Equatable {

  // MARK: Lifecycle

  public init(_ message: String, type: ToastType = .success) {
    self.message = message
    self.type = type
  }

  // MARK: Public

  public let message: String
  public let type: ToastType
}

// MARK: - View + toast

extension View {

  public func toast(
    _ toast: Binding<Toast?>,
    verticalPadding: CGFloat = .x10)
    -> some View
  {
    modifier(ToastViewModifier(toast: toast, verticalPadding: verticalPadding))
  }
}

// MARK: - ToastViewModifier

private struct ToastViewModifier: ViewModifier {

  // MARK: Internal

  @Binding var toast: Toast?

  let verticalPadding: CGFloat

  func body(content: Content) -> some View {
    let displayedToast = toast ?? lastToast
    content
      .popup(isPresented: isPresentedBinding) {
        if let displayedToast {
          Text(displayedToast.message)
            .font(.custom.footnote)
            .foregroundStyle(displayedToast.type.foregroundColor)
            .padding(.horizontal, .x3)
            .padding(.vertical, .x2)
            .background(displayedToast.type.backgroundColor)
            .clipShape(.capsule)
            .accessibilityHidden(true)
            .shadow(color: ThemingAssets.Brand.Core.black.swiftUIColor.opacity(0.1), radius: 6, x: 0, y: 2)
        }
      } customize: {
        $0
          .type(.floater(verticalPadding: verticalPadding, useSafeAreaInset: true))
          .position(.bottom)
          .autohideIn(5)
          .dragToDismiss(true)
          .animation(.interpolatingSpring)
          .dismissCallback {
            lastToast = nil
            toast = nil
          }
      }
      .onChange(of: toast) { _, newToast in
        if let newToast {
          lastToast = newToast
          annoucement(newToast.message)
        }
      }
  }

  // MARK: Private

  @State private var lastToast: Toast?

  private var isPresentedBinding: Binding<Bool> {
    Binding(
      get: { toast != nil },
      set: { isPresented in
        if !isPresented {
          toast = nil
        }
      })
  }

  private func annoucement(_ message: String) {
    var announcement = AttributedString(message)
    announcement.accessibilitySpeechAnnouncementPriority = .high
    AccessibilityNotification.Announcement(announcement).post()
  }
}

// MARK: - ToastType

public enum ToastType: Equatable {
  case success
  case error

  // MARK: Internal

  var foregroundColor: Color {
    switch self {
    case .error:
      ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor
    case .success:
      ThemingAssets.Brand.Bright.firGreenLabel.swiftUIColor
    }
  }

  var backgroundColor: Color {
    switch self {
    case .error:
      ThemingAssets.Brand.Bright.swissRed.swiftUIColor
    case .success:
      ThemingAssets.Brand.Bright.firGreen.swiftUIColor
    }
  }
}
