import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - NFCScanResultView

struct NFCScanResultView: View {

  // MARK: Lifecycle

  init(packageResult: AVBeamPackageResult) {
    _viewModel = StateObject(wrappedValue: Container.shared.nfcScanResultViewModel(packageResult))
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
    .toolbarBackground(ThemingAssets.Background.secondary.swiftUIColor)
    .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  @StateObject private var viewModel: NFCScanResultViewModel

  @ViewBuilder
  private func content(_ entries: [NFCScanResultViewModel.NFCScanResultEntryType]) -> some View {
    ZStack {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      List {
        Section {
          NFCScanResultListView(entries: entries)
        } header: {
          Text(L10n.tkEidRequestNfcScanResultTitle)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .font(.custom.title2Emphasized)
            .padding(.top, .x10)
            .padding(.bottom, .x6)
            .accessibilityAddTraits(.isHeader)
        }
        .listRowInsets(EdgeInsets())
        .textCase(nil)
      }
      .scrollContentBackground(.hidden)
    }
  }

  @ViewBuilder
  private func footer() -> some View {
    Button(action: viewModel.primaryAction, label: {
      Text(L10n.tkGlobalContinue)
        .frame(maxWidth: .infinity)
    })
    .accessibilitySortPriority(AccessibilityPriority.x5.rawValue)
    .buttonStyle(.primary)
    .controlSize(.large)
  }
}
