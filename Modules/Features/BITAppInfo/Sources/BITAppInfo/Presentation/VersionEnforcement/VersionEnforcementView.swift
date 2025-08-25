import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - VersionEnforcementView

struct VersionEnforcementView: View {

  // MARK: Lifecycle

  init(viewModel: VersionEnforcementViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  // MARK: Internal

  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Environment(\.verticalSizeClass) var verticalSizeClass
  @Environment(\.sizeCategory) var sizeCategory

  var body: some View {
    ZStack {
      Rectangle()
        .overlay(
          ThemingAssets.Gradient.gradient4.swiftUIImage
            .resizable()
            .scaledToFill()
            .clipped()
            .overlay(.black.opacity(Defaults.overlayDimming))
        )
        .clipped()
        .ignoresSafeArea()
        .accessibilityHidden(true)

      content()
    }
    .environment(\.colorScheme, .light)
  }

  // MARK: Private

  private enum Defaults {
    static let overlayDimming = 0.21
    static let contentMaxWidth = 530.0
  }

  @StateObject private var viewModel: VersionEnforcementViewModel

  @ViewBuilder
  private func content() -> some View {
    ViewThatFits(in: .vertical) {
      contentLayout()
      scrollableContentLayout()
    }
  }
}

// MARK: - Components

extension VersionEnforcementView {
  @ViewBuilder
  private func mainContent() -> some View {
    VStack(spacing: .x2) {
      Text(viewModel.title)
        .font(.custom.title)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .accessibilityLabel(viewModel.title)

      Text(viewModel.content)
        .font(.custom.body)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .accessibilityLabel(viewModel.content)
    }
    .padding(.horizontal, .x6)
  }

  @ViewBuilder
  private func footer() -> some View {
    Button(action: viewModel.openAppStore) {
      Text(L10n.versionEnforcementButton)
    }
    .padding(.bottom, .x2)
    .controlSize(.large)
    .buttonStyle(.filledPrimary)
    .accessibilityLabel(L10n.versionEnforcementButton)
  }

  @ViewBuilder
  private func contentLayout() -> some View {
    VStack(spacing: 0) {
      Spacer()
      mainContent()
      Spacer()
      footer()
    }
    .frame(maxWidth: Defaults.contentMaxWidth)
  }

  @ViewBuilder
  private func scrollableContentLayout() -> some View {
    ZStack(alignment: .bottom) {
      VStack {
        ScrollView(showsIndicators: false) {
          mainContent()
            .frame(maxWidth: Defaults.contentMaxWidth)
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
