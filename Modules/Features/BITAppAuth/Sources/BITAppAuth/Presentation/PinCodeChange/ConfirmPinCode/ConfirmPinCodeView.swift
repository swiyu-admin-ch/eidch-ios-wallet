import BITL10n
import Factory
import Foundation
import SwiftUI

struct ConfirmPinCodeView: View {

  init(_ router: ChangePinCodeInternalRoutes) {
    _viewModel = State(initialValue: Container.shared.confirmPinCodeViewModel(router))
  }

  var body: some View {
    PinCodeFormView(
      pinCode: $viewModel.pinCode,
      fieldTitle: L10n.tkChangepasswordStep3Note1,
      inputFieldState: viewModel.inputFieldState,
      inputFieldMessage: viewModel.inputFieldMessage,
      attempts: viewModel.attempts,
      onPressNext: viewModel.submit)
      .navigationTitle(L10n.tkGlobalNewpassword)
  }

  @State private var viewModel: ConfirmPinCodeViewModel

}
