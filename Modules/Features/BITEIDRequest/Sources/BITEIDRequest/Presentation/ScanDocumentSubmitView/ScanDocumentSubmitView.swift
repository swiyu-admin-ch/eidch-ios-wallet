import BITL10n
import BITTheming
import Factory
import SwiftUI

struct ScanDocumentSubmitView: View {

  // MARK: Lifecycle

  init(_ scanDocumentOutput: ScanDocumentOutput) {
    _viewModel = State(initialValue: Container.shared.scanDocumentSubmitViewModel(scanDocumentOutput))
  }

  // MARK: Internal

  var body: some View {
    ZStack {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      List {
        Section {
          ScanResultListView(entries: viewModel.scanImages, buttonAction: viewModel.displayScanImageOverview)
        }
        .listRowInsets(EdgeInsets())
        .textCase(nil)
      }
      .frame(maxWidth: 635)
      .scrollContentBackground(.hidden)
    }
    .safeAreaInset(edge: .bottom) {
      VStack(spacing: .x4) {
        AsyncButton(action: viewModel.submit, label: {
          Text(L10n.tkGlobalContinue)
            .frame(maxWidth: .infinity)
        })
        .buttonStyle(.primary)
        .controlSize(.large)

        Button(action: {
          navigator.returnToCheckpointSafely(EIDRequestCheckpoints.scanDocumentInformation)
        }, label: {
          Text(L10n.tkEidRequestScanDocumentSubmitSecondaryButton)
            .frame(maxWidth: .infinity)
        })
        .buttonStyle(.secondary)
        .controlSize(.large)
      }
      .padding(.horizontal, .x4)
    }
    .defaultEidRequestToolbar()
    .navigate(to: $viewModel.destination)
    .toolbarBackground(ThemingAssets.Background.secondary.swiftUIColor)
    .navigationBarBackButtonHidden()
    .navigationTitle(L10n.tkEidRequestScanDocumentSubmitTitle)
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @State private var viewModel: ScanDocumentSubmitViewModel
}
