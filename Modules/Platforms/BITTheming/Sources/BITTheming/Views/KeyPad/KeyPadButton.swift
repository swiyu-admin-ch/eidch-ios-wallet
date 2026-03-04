import SwiftUI

extension EnvironmentValues {
  public var keyPadPressed: (KeyPadKey) -> Void {
    get { self[KeyPadButton.ActionKey.self] }
    set { self[KeyPadButton.ActionKey.self] = newValue }
  }
}

// MARK: - KeyPadButton

public struct KeyPadButton: View {

  // MARK: Public

  public var key: KeyPadKey

  @Environment(\.keyPadPressed) public var action: (KeyPadKey) -> Void

  public var body: some View {
    Button {
      action(key)
    } label: {
      if let image = key.image {
        Color.clear
          .overlay(image)
          .padding(.vertical)
      } else if let font = key.font {
        Color.clear
          .overlay(Text(key.value ?? ""))
          .font(font)
          .padding(.vertical)
      } else {
        Color.clear
          .overlay(Text(key.value ?? ""))
          .padding(.vertical)
      }
    }
  }

  // MARK: Internal

  enum ActionKey: EnvironmentKey {
    static var defaultValue: (KeyPadKey) -> Void {
      { _ in }
    }
  }

}
