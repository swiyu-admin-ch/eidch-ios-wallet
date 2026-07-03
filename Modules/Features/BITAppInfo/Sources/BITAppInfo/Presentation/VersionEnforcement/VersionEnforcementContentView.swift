import BITL10n
import BITTheming
import SwiftUI

// MARK: - VersionEnforcementContentView

struct VersionEnforcementContentView<FooterButtons: View>: View {

  // MARK: Internal

  let title: String
  let content: String
  @ViewBuilder let footerButtons: () -> FooterButtons

  var body: some View {
    ViewThatFits(in: .vertical) {
      contentLayout()
      scrollableContentLayout()
    }
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  private let contentMaxWidth = 530.0

  @Orientation private var orientation
}

// MARK: - Components

extension VersionEnforcementContentView {

  private func mainContent() -> some View {
    VStack(spacing: .x2) {
      Text(title)
        .font(.custom.title)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .accessibilityLabel(title)

      Text(content)
        .font(.custom.body)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .accessibilityLabel(content)
    }
    .padding(.horizontal, .x6)
  }

  @ViewBuilder
  private func footer() -> some View {
    if orientation.isLandscape {
      HStack(spacing: .x4) {
        footerButtons()
      }
      .padding(.bottom, .x4)
    } else {
      VStack(spacing: .x3) {
        footerButtons()
      }
      .padding(.bottom, .x2)
    }
  }

  private func contentLayout() -> some View {
    VStack(spacing: 0) {
      Spacer()
      mainContent()
      Spacer()
      footer()
        .padding(.horizontal, .x4)
    }
    .frame(maxWidth: contentMaxWidth)
  }

  private func scrollableContentLayout() -> some View {
    ZStack(alignment: .bottom) {
      VStack {
        ScrollView(showsIndicators: false) {
          mainContent()
            .frame(maxWidth: contentMaxWidth)
        }

        if sizeCategory.isAccessibilityCategory {
          footer()
        }
      }
    }
    .if(!sizeCategory.isAccessibilityCategory, transform: {
      $0.safeAreaInset(edge: .bottom) {
        footer()
      }
    })
    .overlay(alignment: .top) {
      Color.clear
        .background(ThemingAssets.Brand.Core.white.swiftUIColor)
        .ignoresSafeArea(edges: .top)
        .frame(height: 0)
    }
  }
}
