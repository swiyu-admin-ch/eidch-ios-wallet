import SwiftUI

// MARK: - SectionView

public struct SectionView<Content: View>: View {

  // MARK: Lifecycle

  public init(title: String? = nil, minHeight: CGFloat? = 94, hasContentPadding: Bool = true, @ViewBuilder content: () -> Content) {
    self.title = title
    self.minHeight = minHeight
    self.hasContentPadding = hasContentPadding
    self.content = content()
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: .x2) {
      if let title {
        Text(title)
          .font(.custom.title2Emphasized)
          .padding(.top, .x4)
          .padding(.horizontal, .x4)
          .accessibilityAddTraits(.isHeader)
      }

      VStack(alignment: .leading, spacing: hasContentPadding ? nil : 0) {
        content
      }
      .padding(.vertical, hasContentPadding ? .x2 : 0)
      .frame(minHeight: minHeight)
      .background(ThemingAssets.Background.groupedRow.swiftUIColor)
      .clipShape(.rect(cornerRadius: .CornerRadius.m))
      .accessibilityElement(children: .contain)
    }
    .padding(.horizontal, .x4)
    .accessibilityElement(children: .contain)
  }

  // MARK: Private

  private let title: String?
  private let minHeight: CGFloat?
  private let hasContentPadding: Bool
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
