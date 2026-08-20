import BITEIDRequest
import BITL10n
import BITNavigation
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - HomeView

struct HomeView: View {

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "homeContent"
  }

  var body: some View {
    content
      .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
      .onAppear(perform: onAppear)
      .onDisappear(perform: viewModel.stopRefresh)
      .navigate(to: $viewModel.destination)
      .navigationCheckpoint(Checkpoints.home) { state in
        Task {
          await viewModel.handleNavigationCheckpoint(state: state)
        }
      }
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModels(with: scheme.rawValue)
      }
      .onChange(of: viewModel.externalURL) { _, externalURL in
        openExternalURL(externalURL)
      }
      .background(ThemingAssets.Background.secondary.swiftUIColor, ignoresSafeAreaEdges: .all)
      .toast($viewModel.toast, verticalPadding: orientation.isPortrait ? .x30 : 0)
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @Environment(\.openURL) private var openURL

  @InjectedObservable(\.homeViewModel) private var viewModel: HomeViewModel

  @Orientation private var orientation

  private func onAppear() {
    Task {
      await viewModel.onAppear()
    }
  }

  private func openExternalURL(_ url: URL?) {
    guard let url else { return }

    openURL(url)
    viewModel.didConsumeExternalURL()
  }
}

// MARK: - Layouts

extension HomeView {

  @ViewBuilder
  private var content: some View {
    if orientation.isPortrait {
      portraitLayout
    } else {
      landscapeLayout
    }
  }

  private var portraitLayout: some View {
    mainContent
      .safeAreaInset(edge: .bottom) { actionButtons }
  }

  private var landscapeLayout: some View {
    ViewThatFits(in: .vertical) {
      landscapeContentLayout
      landscapeScrollableContentLayout
    }
  }

  private var landscapeContentLayout: some View {
    HStack {
      actionButtons
      Spacer()
      mainContent
    }
  }

  private var landscapeScrollableContentLayout: some View {
    HStack {
      actionButtons

      mainContent
        .padding(.x4)
    }
    .padding(.vertical, .x4)
  }

  private var mainContent: some View {
    listContent
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(L10n.tkHomeTitle)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          menuButton
        }
      }
  }
}

// MARK: - Components

extension HomeView {

  private var listContent: some View {
    List {
      RequestCasesListView(viewModel.requestCases)
        .listRowBackground(ThemingAssets.Background.groupedRow.swiftUIColor)

      stateContent
    }
    .refreshable {
      await viewModel.refresh()
    }
    .scrollContentBackground(.hidden)
    .listStyle(.insetGrouped)
  }

  @ViewBuilder
  private var stateContent: some View {
    switch viewModel.state {
    case .results:
      HomeCredentialsList(viewModel.credentials, onSelect: viewModel.openCredential)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor, ThemingAssets.Label.primary.swiftUIColor)
        .listRowBackground(ThemingAssets.Background.groupedRow.swiftUIColor)
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
    case .error(let error):
      HomeErrorStateView(error, onRetry: viewModel.refresh)
    case .empty:
      HomeEmptyStateView(
        onOrderEID: viewModel.openEIDRequest,
        onGetBetaId: viewModel.openBetaId)
        .listRowSeparator(.hidden)
    }
  }

  private var menuButton: some View {
    HomeMenu(
      onAddCredential: viewModel.openBetaId,
      onOrderEID: viewModel.openEIDRequest,
      onOpenSettings: viewModel.openSettings,
      onOpenHelp: viewModel.openHelp)
  }

  private var actionButtons: some View {
    HomeActionButtons(
      onScanAction: { viewModel.openScanner() },
      onQRCodeAction: viewModel.isProximityEnabled ? { viewModel.openScanner(tab: .proximityEngagement) } : nil)
      .padding(.horizontal, .x6)
      .padding(.bottom, .x3)
  }
}

#if DEBUG
#Preview {
  HomeView()
}
#endif
