import BITCredential
import BITCredentialShared
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
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
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

  private var content: some View {
    mainContent
      .toast($viewModel.toast)
      .safeAreaInset(edge: .bottom, spacing: 0) {
        if !orientation.isLandscape {
          HomeActionButtons(axis: .horizontal)
            .padding(.horizontal, .x6)
            .padding(.bottom, .x3)
        }
      }
      .safeAreaInset(edge: .leading, spacing: 0) {
        if orientation.isLandscape {
          HomeActionButtons(axis: .vertical)
            .padding(.horizontal, .x6)
        }
      }
  }

  private var mainContent: some View {
    listContent
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(L10n.tkHomeTitle)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HomeMenu()
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
      HomeCredentialsList(viewModel.credentials, onSelect: openCredential)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor, ThemingAssets.Label.primary.swiftUIColor)
        .listRowBackground(ThemingAssets.Background.groupedRow.swiftUIColor)
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
    case .error(let error):
      HomeErrorStateView(error, onRetry: viewModel.refresh)
    case .empty:
      CredentialEmptyStateView()
        .listRowSeparator(.hidden)
    }
  }
}

// MARK: - Navigation

extension HomeView {

  private func openCredential(_ credentialViewModel: any CredentialViewModelProtocol) {
    switch credentialViewModel.credential {
    case let verifiableCredential as VerifiableCredential:
      openVerifiableCredential(verifiableCredential)
    case let deferredCredential as DeferredCredential:
      openDeferredCredential(deferredCredential)
    default: return
    }
  }

  private func openVerifiableCredential(_ verifiableCredential: VerifiableCredential) {
    switch verifiableCredential.progressionState {
    case .accepted:
      navigator.navigate(to: HomeDestinations.external(.credentialDetail(CredentialDetailInput(credential: verifiableCredential))))
    case .unaccepted:
      navigator.navigate(to: HomeDestinations.external(.offer(verifiableCredential)))
    }
  }

  private func openDeferredCredential(_ deferredCredential: DeferredCredential) {
    navigator.navigate(to: HomeDestinations.external(.credentialDetail(CredentialDetailInput(credential: deferredCredential))))
  }
}

#if DEBUG
#Preview {
  HomeView()
}
#endif
