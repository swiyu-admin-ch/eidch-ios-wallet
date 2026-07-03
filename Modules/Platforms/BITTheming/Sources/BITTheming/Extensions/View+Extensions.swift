import Foundation
import SwiftUI

extension View {

  public func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      })
      .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }

  public func readSafeAreaInsets(onChange: @escaping (EdgeInsets) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SafeAreaInsetsPreferenceKey.self, value: geometryProxy.safeAreaInsets)
      })
      .onPreferenceChange(SafeAreaInsetsPreferenceKey.self, perform: onChange)
  }

  @ViewBuilder
  public func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }

  @ViewBuilder
  public func `if`<T>(`let` optional: T?, _ transform: (_ value: T, _ view: Self) -> some View) -> some View {
    if let optional {
      transform(optional, self)
    } else {
      self
    }
  }

  /// Tell when a view **is** visible in the given `CGRect` & `CoordinateSpace`
  public func ifVisible(in rect: CGRect, in space: CoordinateSpace, execute: @escaping (CGRect) -> Void) -> some View {
    background(GeometryReader { geometry -> AnyView in
      let frame = geometry.frame(in: space)
      if frame.intersects(rect) {
        execute(frame)
      }
      return AnyView(Rectangle().fill(Color.clear))
    })
  }

  /// Tell when a view **is not** anymore visible in the given `CGRect` & `CoordinateSpace`
  public func ifNotVisible(in rect: CGRect, in space: CoordinateSpace, execute: @escaping (CGRect) -> Void) -> some View {
    background(GeometryReader { geometry -> AnyView in
      let frame = geometry.frame(in: space)
      if !frame.intersects(rect) {
        execute(frame)
      }
      return AnyView(Rectangle().fill(Color.clear))
    })
  }

  /// Reads the information of a given `CGRect` in some `CoordinateSpace
  /// - Note: To be used with `.coordinateSpace(name: "space")` & `.rectReader($viewport, in: .named("space"))`
  public func rectReader(_ binding: Binding<CGRect>, in space: CoordinateSpace) -> some View {
    background(GeometryReader { geometry -> AnyView in
      let rect = geometry.frame(in: space)
      DispatchQueue.main.async {
        binding.wrappedValue = rect
      }
      return AnyView(Rectangle().fill(Color.clear))
    })
  }
}

// MARK: - SizePreferenceKey

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue = CGSize.zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

// MARK: - SafeAreaInsetsPreferenceKey

private struct SafeAreaInsetsPreferenceKey: PreferenceKey {
  static var defaultValue = EdgeInsets()
  static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
    value = EdgeInsets(top: value.top.rounded(), leading: value.leading.rounded(), bottom: value.bottom.rounded(), trailing: value.trailing.rounded())
  }
}
