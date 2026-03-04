import Foundation
import SwiftUI

public struct Pager<Content: View>: View {

  // MARK: Lifecycle

  public init(pageCount: Int, currentIndex: Binding<Int>, isSwipeEnabled: Binding<Bool>, @ViewBuilder content: () -> Content) {
    self.pageCount = pageCount
    _currentIndex = currentIndex
    _isSwipeEnabled = isSwipeEnabled
    self.content = content()
  }

  // MARK: Public

  public var body: some View {
    GeometryReader { geometry in
      LazyHStack(spacing: 0) {
        content
          .frame(width: geometry.size.width + (geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing), height: geometry.size.height)
          .accessibilityFocused($isCurrentPageFocused)
      }
      .frame(width: geometry.size.width + (geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing), height: geometry.size.height, alignment: .leading)
      .offset(x: -CGFloat(currentIndex) * (geometry.size.width + ( geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing)))
      .offset(x: translation - geometry.safeAreaInsets.leading)
      .animation(.interactiveSpring(duration: 0.4), value: currentIndex)
      .animation(.interactiveSpring(duration: 0.4), value: translation)
      .gesture(
        DragGesture().updating($translation) { value, state, _ in
          if isSwipeEnabled {
            state = value.translation.width
          }
        }.onEnded { value in
          if isSwipeEnabled {
            let offset = value.translation.width / geometry.size.width
            let index = (CGFloat(currentIndex) - offset).rounded()
            currentIndex = min(max(Int(index), 0), pageCount - 1)
          }

          updateAccessibilityFocus()
        })
      .onAppear {
        updateAccessibilityFocus()
      }
      .onChange(of: UIDevice.current.orientation) { _ in
        // Reapply the focus after orientation change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          updateAccessibilityFocus()
        }
      }
    }
  }

  // MARK: Private

  @Binding private var currentIndex: Int
  @Binding private var isSwipeEnabled: Bool

  @AccessibilityFocusState private var isCurrentPageFocused: Bool

  @GestureState private var translation: CGFloat = 0

  private let pageCount: Int
  private let content: Content

  private func updateAccessibilityFocus() {
    DispatchQueue.main.async {
      isCurrentPageFocused = false // Reset focus
      isCurrentPageFocused = true // Set focus to current page
    }
  }
}
