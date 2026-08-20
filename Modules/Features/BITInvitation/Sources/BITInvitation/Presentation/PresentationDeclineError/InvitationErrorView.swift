import BITL10n
import BITOpenID
import BITPresentation
import BITTheming
import NavigatorUI
import SwiftUI
import UIKit

struct InvitationErrorView: View {

  // MARK: Lifecycle

  init(
    dataset: ErrorDataset,
    presentationResponse: PresentationResponse?,
    onClose: @escaping () -> Void)
  {
    self.dataset = dataset
    self.presentationResponse = presentationResponse
    self.onClose = onClose
  }

  // MARK: Internal

  var body: some View {
    ErrorView(dataset: dataset, onClose: onClose)
      .safeAreaInset(edge: .bottom) {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalClose,
          primaryButtonAction: close)
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private let dataset: ErrorDataset
  private let presentationResponse: PresentationResponse?
  private let onClose: () -> Void

  private func close() {
    guard let redirectUri = presentationResponse?.redirectUri else {
      onClose()
      navigator.dismiss()
      return
    }

    UIApplication.shared.open(redirectUri) { _ in
      onClose()
      navigator.dismiss()
    }
  }
}
