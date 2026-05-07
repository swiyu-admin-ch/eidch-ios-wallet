import BITL10n
import BITTheming
import Factory
import SwiftUI

struct NewPinCodeView: View {

  // MARK: Lifecycle

  init(_ router: ChangePinCodeInternalRoutes) {
    _viewModel = State(initialValue: Container.shared.newPinCodeViewModel(router))
  }

  // MARK: Internal

  var body: some View {
    PinCodeFormView(
      pinCode: $viewModel.pinCode,
      fieldTitle: L10n.tkGlobalNewpassword,
      inputFieldState: viewModel.inputFieldState,
      inputFieldMessage: viewModel.inputFieldMessage,
      isSubmitEnabled: viewModel.isSubmitEnabled,
      onPressNext: viewModel.submit)
      .navigationTitle(L10n.tkGlobalNewpassword)
      .toast($viewModel.toast)
  }

  // MARK: Private

  @State private var viewModel: NewPinCodeViewModel

}
