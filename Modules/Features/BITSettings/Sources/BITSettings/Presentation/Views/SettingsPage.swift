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
      ScrollView {
        VStack(alignment: .leading, spacing: .x10) {
          content
        }
        .padding(.x4)
      }
      .frame(maxWidth: 635)
    }
    .frame(maxWidth: .infinity)
    .background(ThemingAssets.Background.secondary.swiftUIColor)
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: Private

  private let title: String
  private let content: Content
}
