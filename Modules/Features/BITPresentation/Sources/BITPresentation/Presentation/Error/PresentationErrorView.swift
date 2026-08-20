import BITL10n
import BITNavigation
import BITOpenID
import BITTheming
import NavigatorUI
import SwiftUI
import UIKit

struct PresentationErrorView: View {

  // MARK: Lifecycle

  init(dataset: ErrorDataset, presentationResponse: PresentationResponse?) {
    self.dataset = dataset
    self.presentationResponse = presentationResponse
  }

  // MARK: Internal

  var body: some View {
    ErrorView(dataset: dataset)
      .safeAreaInset(edge: .bottom) {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: close)
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private let dataset: ErrorDataset
  private let presentationResponse: PresentationResponse?

  private func close() {
    guard let redirectUri = presentationResponse?.redirectUri else {
      navigator.returnToHomeSafely()
      return
    }

    UIApplication.shared.open(redirectUri) { _ in
      navigator.returnToHomeSafely()
    }
  }
}
