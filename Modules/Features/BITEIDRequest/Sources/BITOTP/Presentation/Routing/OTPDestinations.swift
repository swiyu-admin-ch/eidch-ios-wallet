import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - OTPDestinations

public enum OTPDestinations: NavigationDestination {
  case intro
  case legal
  case email
  case code(email: String, onToastMessage: Callback<String>)
  case error(ErrorDataset)
  case external(OTPExternalViews)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .code,
         .email,
         .error,
         .external,
         .intro,
         .legal:
      .push
    }
  }

  public var body: some View {
    OTPDestinationsView(destination: self)
  }
}

// MARK: - OTPDestinationsView

private struct OTPDestinationsView: View {
  let destination: OTPDestinations
  @Injected(\.otpExternalViewProvider) private var viewProvider

  var body: some View {
    switch destination {
    case .intro:
      OTPIntroView()
    case .legal:
      OTPLegalView()
    case .email:
      OTPEmailView()
    case .code(let email, let onToastMessage):
      OTPCodeView(email: email, onToastMessage: onToastMessage.handler)
    case .error(let dataset):
      ErrorView(dataset: dataset)
    case .external(let externalView):
      viewProvider?.view(for: externalView)
    }
  }
}
