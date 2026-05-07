import SwiftUI
import UIKit

// MARK: - TransparentToolbarBackgroundViewModifier

public struct TransparentToolbarBackgroundViewModifier: ViewModifier {

  // MARK: Lifecycle

  public init(isActive: Bool, topInset: CGFloat) {
    self.isActive = isActive
    self.topInset = topInset
  }

  // MARK: Public

  public func body(content: Content) -> some View {
    if isActive {
      content
        .navigationBar(cameraNavigationAppearance)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .overlay(alignment: .top) {
          CameraToolbarBackgroundGradient(height: topInset)
        }
    } else {
      content
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.none, for: .navigationBar)
    }
  }

  // MARK: Private

  private let isActive: Bool
  private let topInset: CGFloat

  private var cameraNavigationAppearance: UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.doneButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    return appearance
  }
}

// MARK: - View Extension

extension View {
  public func transparentToolbarBackground(isActive: Bool, topInset: CGFloat) -> some View {
    modifier(TransparentToolbarBackgroundViewModifier(isActive: isActive, topInset: topInset))
  }
}

// MARK: - CameraToolbarBackgroundGradient

private struct CameraToolbarBackgroundGradient: View {
  let height: CGFloat

  var body: some View {
    Rectangle()
      .fill(
        LinearGradient(
          stops: [
            Gradient.Stop(color: .black.opacity(0), location: 0.00),
            Gradient.Stop(color: .black.opacity(0.6), location: 1.00),
          ],
          startPoint: UnitPoint(x: 0.5, y: 1),
          endPoint: UnitPoint(x: 0.5, y: 0)))
      .frame(height: height)
      .ignoresSafeArea()
  }
}
