import BITCredentialShared
import BITL10n
import BITTheming
import Foundation
import SwiftUI

// MARK: - IssuanceTypeView

struct IssuanceTypeView: View {

  // MARK: Lifecycle

  init(credentialId: UUID) {
    _viewModel = State(initialValue: IssuanceTypeViewModel(credentialId: credentialId))
  }

  // MARK: Internal

  var body: some View {
    Content(
      state: viewModel.state,
      openLearnMoreLink: openLearnMoreLink)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
      .navigationTitle(L10n.tkCredentialIssuanceTypeTitle)
      .navigationBarTitleDisplayMode(.inline)
      .task {
        await viewModel.onAppear()
      }
  }

  // MARK: Private

  @Environment(\.openURL) private var openURL
  @State private var viewModel: IssuanceTypeViewModel

  private func openLearnMoreLink() {
    guard let url = URL(string: L10n.tkCredentialIssuanceTypeMoreInformationLinkValue) else { return }
    openURL(url)
  }

}

// MARK: IssuanceTypeView.Content

extension IssuanceTypeView {
  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      state: IssuanceTypeViewModel.State,
      openLearnMoreLink: @escaping () -> Void = {})
    {
      self.state = state
      self.openLearnMoreLink = openLearnMoreLink
    }

    // MARK: Internal

    var body: some View {
      content
    }

    // MARK: Private

    private let state: IssuanceTypeViewModel.State
    private let openLearnMoreLink: () -> Void

    @ViewBuilder
    private var content: some View {
      switch state {
      case .loading:
        loadingView()
      case .result(let type, let timeStamp):
        resultView(type: type, timeStamp: timeStamp)
      case .error(let error):
        EmptyStateView(.error(error: error)) {}
      }
    }

    private func loadingView() -> some View {
      VStack {
        Spacer()
        ProgressView()
          .controlSize(.large)
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func resultView(type: IssuanceTypeViewModel.IssuanceType, timeStamp: String) -> some View {
      List {
        switch type {
        case .single:
          IssuanceSummarySection(
            image: Assets.defaultCredential.swiftUIImage,
            title: L10n.tkCredentialIssuanceTypeSingleTitle,
            description: L10n.tkCredentialIssuanceTypeSingleBody,
            openLearnMoreLink: openLearnMoreLink)
            .listRowInsets(EdgeInsets())
        case .batch(let batchViewModel):
          IssuanceSummarySection(
            image: Assets.batchCredential.swiftUIImage,
            title: L10n.tkCredentialIssuanceTypeBatchTitle,
            description: L10n.tkCredentialIssuanceTypeBatchBody,
            openLearnMoreLink: openLearnMoreLink)
            .listRowInsets(EdgeInsets())
          batchUsageDetailsSection(batchViewModel: batchViewModel, timeStamp: timeStamp)
        }
      }
      .listStyle(.insetGrouped)
      .scrollIndicators(.hidden)
      .scrollContentBackground(.hidden)
    }

    private func batchUsageDetailsSection(batchViewModel: IssuanceTypeViewModel.BatchViewModel, timeStamp: String) -> some View {
      Section {
        KeyValueCustomCell(key: L10n.tkCredentialIssuanceTypeAvailableCredentialsKey, trailingContent: { EmptyView() }) {
          VStack(alignment: .leading, spacing: .zero) {
            Text(L10n.tkCredentialIssuanceTypeAvailableCredentialsValue(batchViewModel.available, batchViewModel.total))
              .font(.custom.body)

            Text(L10n.tkCredentialIssuanceTypeRefreshHint(batchViewModel.refreshThreshold))
              .font(.custom.caption1)
              .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
          }
        }

        KeyValueCell(key: L10n.tkCredentialIssuanceTypeLastRefreshKey, value: timeStamp)
      } header: {
        Text(L10n.tkCredentialIssuanceTypeUsageDetailsTitle)
          .font(.custom.headline)
          .foregroundStyle(ThemingAssets.Label.sectionHeader.swiftUIColor)
      }
      .textCase(nil)
    }
  }
}

#if DEBUG
#Preview("Single") {
  NavigationStack {
    IssuanceTypeView.Content(
      state: .result(type: .single, timeStamp: "04/02/2026 | 03:07 PM"))
  }
}

#Preview("Batch") {
  let batchViewModel = IssuanceTypeViewModel.BatchViewModel(available: 10, total: 10, refreshThreshold: 2)

  NavigationStack {
    IssuanceTypeView.Content(
      state: .result(type: .batch(batchViewModel), timeStamp: "04/02/2026 | 03:07 PM"))
  }
}
#endif
