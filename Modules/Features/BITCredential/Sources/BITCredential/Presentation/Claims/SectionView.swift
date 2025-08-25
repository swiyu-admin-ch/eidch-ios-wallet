import BITCredentialShared
import BITTheming
import Foundation
import SwiftUI

// MARK: - SectionView

public struct SectionView<Content: View>: View {

  // MARK: Lifecycle

  public init(title: String? = nil, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: .x2) {
      if let title {
        Text(title)
          .font(.custom.title2Emphasized)
          .padding(.top, .x4)
          .padding(.bottom, .x1)
          .padding(.horizontal, .x6)
          .accessibilityAddTraits(.isHeader)
      }

      VStack(alignment: .leading) {
        content
      }
      .padding(.vertical, .x4)
      .frame(minHeight: 94)
      .background(ThemingAssets.Background.groupedRow.swiftUIColor)
      .clipShape(.rect(cornerRadius: .CornerRadius.m))
    }
    .padding(.horizontal, .x4)
    .accessibilityElement(children: .contain)
  }

  // MARK: Private

  private let title: String?
  private let content: Content

}

#if DEBUG
#Preview {
  ZStack {
    SectionView(title: "Cluster title") {
      Text("Content")
        .padding(.x4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
  .frame(maxHeight: .infinity)
  .background(ThemingAssets.Background.secondary.swiftUIColor)
}
#endif
