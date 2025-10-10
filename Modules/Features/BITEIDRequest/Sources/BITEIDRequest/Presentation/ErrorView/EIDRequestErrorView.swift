import BITL10n
import BITPresentation
import BITTheming
import Factory
import SwiftUI


struct EIDRequestErrorView: View {

  // MARK: Lifecycle

  init(delegate: EIDRequestErrorDelegate, error: Error) {
    viewModel = Container.shared.eIDRequestErrorViewModel((delegate, error))
  }

  // MARK: Internal

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      info
        .padding(.vertical, .x6)
      Spacer()
      Button(action: viewModel.primaryAction) {
        Text(viewModel.buttonText)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.primary)
      .controlSize(.large)
      .padding(.bottom, .x4)
    }
    .applyScrollViewIfNeeded()
    .padding(.horizontal, .x6)
    .background {
      ThemingAssets.Background.tertiary.swiftUIColor
        .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
    .navigationBarBackButtonHidden(true)
    .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  @ViewBuilder
  var info: some View {
    VStack(spacing: 0) {
      Assets.error.swiftUIImage
      Text(viewModel.primaryText)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      Text(viewModel.secondaryText)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
      if let url = URL(string: L10n.tkEidRequestHelpLinkValue) {
        Link(destination: url, label: {
          LinkText(L10n.tkEidRequestHelpLinkText)
            .font(.custom.footnote)
            .padding(.top, .x4)
        })
      }
    }
  }

  // MARK: Private

  private var viewModel: EIDRequestErrorViewModel
}
