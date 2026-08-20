import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - UnregisteredRequestView

struct UnregisteredRequestView: View {

  // MARK: Lifecycle

  init(context: PresentationRequestContext) {
    _viewModel = State(wrappedValue: Container.shared.unregisteredRequestViewModel(context))
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      image: Assets.warningShield.swiftUIImage,
      contents: [
        .title(L10n.tkPresentUnregisteredRequestTitle),
        .body(L10n.tkPresentUnregisteredRequestBody),
      ],
      actions: [
        .secondary(L10n.tkPresentUnregisteredRequestPrimaryButton) { _ in
          viewModel.proceed()
        },
        .anyView {
          Button {
            viewModel.cancel(navigator)
          } label: {
            Text(L10n.tkGlobalCancel)
              .padding(.vertical, .x3)
              .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          }
        },
      ])
      .navigationBarBackButtonHidden()
      .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator: Navigator
  @State private var viewModel: UnregisteredRequestViewModel
}

#if DEBUG
#Preview {
  UnregisteredRequestView(context: .Mock.vcSdJwtSample)
}
#endif
