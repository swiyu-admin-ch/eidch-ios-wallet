import BITTheming
import SwiftUI

struct SettingsPage<Content: View>: View {

  // MARK: Lifecycle

  init(title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  // MARK: Internal

  var body: some View {
    ZStack {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      List {
        content
          .listRowSeparator(.hidden)
      }
      .frame(maxWidth: 635)
      .scrollContentBackground(.hidden)
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
    }

  }

  // MARK: Private

  private let title: String
  private let content: Content
}
