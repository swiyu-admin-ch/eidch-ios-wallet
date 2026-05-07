import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - PinCodeInformationView

struct PinCodeInformationView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    _viewModel = State(initialValue: Container.shared.pinCodeInformationViewModel(router))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "pinCodeInformationContent"
  }

  @State var viewModel: PinCodeInformationViewModel

  var body: some View {
    InformationView(
      image: viewModel.image,
      backgroundImage: viewModel.backgroundImage,
      content: {
        DefaultInformationContentView(
          primary: viewModel.primaryText,
          secondary: viewModel.secondaryText)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: viewModel.buttonLabelText,
          primaryButtonAction: viewModel.nextOnboardingStep)
      })
      .onAppear {
        viewModel.onAppear()
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }
}
