import BITCredentialShared
import BITL10n
import BITTheming
import Foundation
import PopupView
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
      refreshBatchCredential: viewModel.refreshBatchCredential,
      openLearnMoreLink: openLearnMoreLink)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .disabled(viewModel.isRefreshing)
      .loadingOverlay(
        isPresented: viewModel.isRefreshing,
        accessibility: .voiceOver())
      .animation(.easeInOut(duration: 0.5), value: viewModel.isRefreshing)
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
      .navigationTitle(L10n.tkCredentialIssuanceTypeTitle)
      .navigationBarTitleDisplayMode(.inline)
      .popup(item: $viewModel.notificationState, itemView: notificationView, customize: customizeNotification)
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
      refreshBatchCredential: @escaping () async -> Void,
      openLearnMoreLink: @escaping () -> Void = {})
    {
      self.state = state
      self.refreshBatchCredential = refreshBatchCredential
      self.openLearnMoreLink = openLearnMoreLink
    }

    // MARK: Internal

    var body: some View {
      content
    }

    // MARK: Private

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let state: IssuanceTypeViewModel.State
    private let refreshBatchCredential: () async -> Void
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
        KeyValueCustomCell(key: L10n.tkCredentialIssuanceTypeAvailableCredentialsKey, trailingContent: {
          if !dynamicTypeSize.isLargeAccessibilitySize {
            batchUsageWarningIcon(batchViewModel)
          }
        }) {
          VStack(alignment: .leading, spacing: .x1) {
            if dynamicTypeSize.isLargeAccessibilitySize {
              batchUsageWarningIcon(batchViewModel)
            }

            Text("\(batchViewModel.available)")
              .font(.custom.body)

            Text(
              batchViewModel.isBatchPrivacyWarningVisible ?
                L10n.tkCredentialIssuanceTypeRenewUsagesHint :
                L10n.tkCredentialIssuanceTypeRefreshHint(batchViewModel.refreshThreshold))
              .font(.custom.caption1)
              .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
          }
        }

        if batchViewModel.isBatchPrivacyWarningVisible {
          Button {
            Task {
              await refreshBatchCredential()
            }
          } label: {
            Text(L10n.tkCredentialIssuanceTypeRenewUsagesButton)
              .padding(.vertical, .x2)
          }
          .tint(ThemingAssets.Brand.Accent.link.swiftUIColor)
        }

        KeyValueCell(key: L10n.tkCredentialIssuanceTypeLastRefreshKey, value: timeStamp)
      } header: {
        Text(L10n.tkCredentialIssuanceTypeUsageDetailsTitle)
          .font(.custom.headline)
          .foregroundStyle(ThemingAssets.Label.sectionHeader.swiftUIColor)
      }
      .textCase(nil)
    }

    @ViewBuilder
    private func batchUsageWarningIcon(_ viewModel: IssuanceTypeViewModel.BatchViewModel) -> some View {
      if viewModel.isBatchPrivacyWarningVisible {
        Image(systemName: "exclamationmark.triangle")
          .foregroundStyle(ThemingAssets.Component.Callout.Alert.symbol.swiftUIColor)
          .accessibilityHidden(true)
      }
    }
  }
}

// MARK: - Notification Popups

extension IssuanceTypeView {
  private func notificationView(_ notification: IssuanceTypeViewModel.NotificationState) -> some View {
    let iconSystemName = switch notification {
    case .failure: "exclamationmark.circle"
    case .success: "checkmark.circle"
    }

    let accentColor: Color = switch notification {
    case .failure: ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor
    case .success: ThemingAssets.Brand.Bright.firGreenLabel.swiftUIColor
    }

    let content: String = switch notification {
    case .failure: L10n.tkCredentialIssuanceTypeRenewUsagesFailureToastTitle
    case .success: L10n.tkCredentialIssuanceTypeRenewUsagesSuccessToastTitle
    }

    let background: Color = switch notification {
    case .failure: ThemingAssets.Brand.Bright.swissRed.swiftUIColor
    case .success: ThemingAssets.Brand.Bright.firGreen.swiftUIColor
    }

    return Notification(
      image: Image(systemName: iconSystemName),
      imageColor: accentColor,
      content: content,
      contentColor: accentColor,
      background: background)
      .safeAreaPadding(.horizontal, .x6)
  }

  private func customizeNotification<PopupContent: View>(_ parameters: Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters {
    guard viewModel.notificationState != nil else { return parameters }
    return parameters
      .type(.floater(useSafeAreaInset: true))
      .position(.top)
      .appearFrom(.topSlide)
      .disappearTo(.topSlide)
      .autohideIn(7)
  }

}

#if DEBUG
#Preview("Single") {
  NavigationStack {
    IssuanceTypeView.Content(
      state: .result(type: .single, timeStamp: "04/02/2026 | 03:07 PM"), refreshBatchCredential: {})
  }
}

#Preview("Batch") {
  let batchViewModel = IssuanceTypeViewModel.BatchViewModel(available: 10, refreshThreshold: 2)

  NavigationStack {
    IssuanceTypeView.Content(
      state: .result(type: .batch(batchViewModel), timeStamp: "04/02/2026 | 03:07 PM"), refreshBatchCredential: {})
  }
}
#endif
