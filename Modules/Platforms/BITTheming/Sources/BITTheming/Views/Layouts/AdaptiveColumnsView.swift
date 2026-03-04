import SwiftUI

// MARK: - AdaptiveColumnsView

public struct AdaptiveColumnsView<PrimaryContent: View, SecondaryContent: View, FooterContent: View>: View {

  // MARK: Public

  public var body: some View {
    let isPortrait = orientation.isPortrait || orientation.isFlat
    if isPortrait {
      portrait()
    } else {
      landscape()
    }
  }

  // MARK: Internal

  let spacing: (portrait: CGFloat, landscape: CGFloat)
  let primary: PrimaryContent
  let secondary: SecondaryContent
  let footerContent: FooterContent?

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  @Orientation private var orientation

  private func portrait() -> some View {
    VStack(spacing: spacing.portrait) {
      primaryContent()
      secondaryContent()
        .padding(.top, .x4)
      Spacer()
    }
    .applyScrollViewIfNeeded()
    .safeAreaInset(edge: .bottom) {
      footer()
    }
  }

  private func landscape() -> some View {
    GeometryReader { geometry in
      HStack(alignment: .top, spacing: spacing.landscape) {
        primaryContent()
          .frame(
            width: (geometry.size.width - spacing.landscape) / 2,
            height: geometry.size.height)

        secondaryContent()
          .frame(width: (geometry.size.width - spacing.landscape) / 2)
      }
    }
  }

  private func primaryContent() -> some View {
    primary
      .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  private func secondaryContent() -> some View {
    let isPortrait = orientation.isPortrait || orientation.isFlat

    if isPortrait {
      secondary
    } else {
      ViewThatFits(in: .vertical) {
        VStack {
          secondary
          Spacer()
          footer()
        }

        ScrollView {
          secondary
        }
        .safeAreaInset(edge: .bottom) {
          footer()
        }
      }
    }
  }

  @ViewBuilder
  private func footer() -> some View {
    if let footerContent {
      footerContent
        .frame(maxWidth: .infinity)
    }
  }

}

// MARK: - AdaptiveColumnsView Extensions

extension AdaptiveColumnsView {

  public init(
    spacing: CGFloat = 16,
    @ViewBuilder primaryContent: () -> PrimaryContent,
    @ViewBuilder secondaryContent: () -> SecondaryContent,
    @ViewBuilder footer: () -> FooterContent)
  {
    self.spacing = (spacing, spacing)
    primary = primaryContent()
    secondary = secondaryContent()
    footerContent = footer()
  }

  public init(
    portraitSpacing: CGFloat,
    landscapeSpacing: CGFloat,
    @ViewBuilder primaryContent: () -> PrimaryContent,
    @ViewBuilder secondaryContent: () -> SecondaryContent,
    @ViewBuilder footer: () -> FooterContent)
  {
    spacing = (portraitSpacing, landscapeSpacing)
    primary = primaryContent()
    secondary = secondaryContent()
    footerContent = footer()
  }
}

extension AdaptiveColumnsView where FooterContent == EmptyView {

  public init(
    spacing: CGFloat = 16,
    @ViewBuilder primaryContent: () -> PrimaryContent,
    @ViewBuilder secondaryContent: () -> SecondaryContent)
  {
    self.spacing = (spacing, spacing)
    primary = primaryContent()
    secondary = secondaryContent()
    footerContent = nil
  }

  public init(
    portraitSpacing: CGFloat,
    landscapeSpacing: CGFloat,
    @ViewBuilder primaryContent: () -> PrimaryContent,
    @ViewBuilder secondaryContent: () -> SecondaryContent)
  {
    spacing = (portraitSpacing, landscapeSpacing)
    primary = primaryContent()
    secondary = secondaryContent()
    footerContent = nil
  }
}
