import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - NFCScanResultView

struct NFCScanResultView: View {

  // MARK: Lifecycle

  init(packageResult: AVBeamPackageResult) {
    _viewModel = State(initialValue: Container.shared.nfcScanResultViewModel(packageResult))
  }

  // MARK: Internal

  var body: some View {
    VStack {
      switch viewModel.state {
      case .loading:
        ProgressView()
          .controlSize(.large)
      case .results(let entries):
        content(entries)
      case .error(let error):
        Text(error.localizedDescription)
      }
    }
    .background(ThemingAssets.Background.secondary.swiftUIColor)
    .task {
      await viewModel.fetchScanResult()
    }
    .safeAreaInset(edge: .bottom) {
      footer()
        .padding(.horizontal, .x4)
    }
    .defaultEidRequestToolbar()
    .navigate(to: $viewModel.destination)
    .navigationBarBackButtonHidden()
    .navigationTitle(L10n.tkEidRequestNfcScanResultTitle)
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: Private

  @State private var viewModel: NFCScanResultViewModel

  private func content(_ entries: [ScanResultEntryType]) -> some View {
    ZStack {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      List {
        Section {
          ScanResultListView(entries: entries, resizeImages: true)
        }
        .listRowInsets(EdgeInsets())
        .textCase(nil)
      }
      .frame(maxWidth: 635)
      .scrollContentBackground(.hidden)
    }
  }

  private func footer() -> some View {
    Button(action: viewModel.primaryAction, label: {
      Text(L10n.tkGlobalContinue)
        .frame(maxWidth: .infinity)
    })
    .accessibilitySortPriority(AccessibilityPriority.x5.rawValue)
    .buttonStyle(.primary)
    .controlSize(.large)
    .frame(maxWidth: 635)
  }
}
