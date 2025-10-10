import BITTheming
import SwiftUI

struct SettingsSection<Content: View>: View {

  // MARK: Lifecycle

  init(title: String = "", @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  // MARK: Internal

  var body: some View {
    Section {
      content
    } header: {
      sectionHeader(title)
    }
    .listRowInsets(EdgeInsets())
    .textCase(nil)
  }

  // MARK: Private

  private let title: String
  private let content: Content

  @ViewBuilder
  private func sectionHeader(_ title: String) -> some View {
    if !title.isEmpty {
      Text(title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .font(.custom.body)
        .padding(.top, .x10)
        .padding(.leading, .x2)
        .padding(.bottom, .x3)
        .accessibilityAddTraits(.isHeader)
    }
  }
}
