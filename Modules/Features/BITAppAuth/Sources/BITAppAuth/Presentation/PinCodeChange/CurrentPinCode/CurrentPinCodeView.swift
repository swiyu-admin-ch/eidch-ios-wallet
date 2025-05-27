import BITL10n
import BITTheming
import Factory
import SwiftUI

struct CurrentPinCodeView: View {

  // MARK: Lifecycle

  init(_ router: ChangePinCodeInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.currentPinCodeViewModel(router))
  }

  // MARK: Internal

  var body: some View {
    PinCodeFormView(
      pinCode: $viewModel.pinCode,
      fieldTitle: L10n.tkChangepasswordStep1Note1,
      inputFieldState: viewModel.inputFieldState,
      inputFieldMessage: viewModel.inputFieldMessage,
      attempts: viewModel.attempts,
      isSubmitEnabled: viewModel.isSubmitEnabled,
      onPressNext: viewModel.submit)
      .onAppear { viewModel.onAppear() }
      .navigationTitle(L10n.tkGlobalChangepassword)
  }

  // MARK: Private

  @StateObject private var viewModel: CurrentPinCodeViewModel

}
