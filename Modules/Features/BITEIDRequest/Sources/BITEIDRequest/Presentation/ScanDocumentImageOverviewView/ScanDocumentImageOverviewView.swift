import BITL10n
import BITTheming
import Factory
import SwiftUI

struct ScanDocumentImageOverviewView: View {

  // MARK: Lifecycle

  init(image: ScanResultEntryImage) {
    _viewModel = State(initialValue: Container.shared.scanDocumentImageOverviewViewModel(image))
  }

  // MARK: Internal

  var body: some View {
    Image(data: viewModel.image.value, rotation: viewModel.imageRotation)?
      .resizable()
      .scaledToFit()
      .frame(maxWidth: 635)
      .accessibilityLabel(viewModel.image.accessibilityLabel)
      .zoomable()
      .safeAreaInset(edge: .bottom) {
        closeButton
      }
      .toolbar {
        CloseButtonToolbar(action: { navigator.dismiss() })
      }
      .presentationDragIndicator(.visible)
      .navigationTitle(viewModel.image.key)
      .navigationBarTitleDisplayMode(.inline)
      .onFirstAppear {
        viewModel.rotateImageIfNeeded()
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @State private var viewModel: ScanDocumentImageOverviewViewModel

  private var closeButton: some View {
    Button {
      navigator.dismiss()
    } label: {
      Text(L10n.tkEidRequestScanDocumentOverviewCloseButtonTitle)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.primary)
    .controlSize(.large)
    .padding(.x4)
  }

}
