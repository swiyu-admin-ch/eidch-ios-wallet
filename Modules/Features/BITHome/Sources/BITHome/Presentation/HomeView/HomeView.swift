import BITCore
import BITCredential
import BITCredentialShared
import BITEIDRequest
import BITL10n
import BITNavigation
import BITPresentation
import BITSettings
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - HomeView

struct HomeView: View {

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "homeContent"
    case scanButton
    case menuButton
    case credential
  }

  var body: some View {
    content()
      .onAppear {
        UIAccessibility.post(notification: .screenChanged, argument: L10n.tkHomeHomescreenAlt)
        focus = .scan

        Task {
          await viewModel.onAppear()
        }
      }
      .onDisappear(perform: viewModel.stopRefresh)
      .navigate(to: $viewModel.destination)
      .navigationCheckpoint(Checkpoints.home, completion: { state in
        switch state {
        case .acceptCredential: viewModel.didSaveCredential()
        case .declineCredential: viewModel.didDeclineCredential()
        case .deletedCredential: viewModel.didDeleteCredential()
        case .startRequestCasePolling(let caseId): viewModel.startRequestCasePolling(for: caseId)
        }
      })
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModels(with: scheme.rawValue)
      }
      .onChange(of: viewModel.externalURL) { _, externalURL in
        guard let externalURL else { return }
        openURL(externalURL)
        viewModel.didConsumeExternalURL()
      }
      .toast($viewModel.toast, verticalPadding: orientation.isPortrait ? .x30 : 0)
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private enum FocusableElement: Hashable {
    case scan, menu, list, emptyState, error
  }

  @Environment(\.openURL) private var openURL
  @Environment(\.sizeCategory) private var sizeCategory
  @AccessibilityFocusState private var focus: FocusableElement?

  @InjectedObservable(\.homeViewModel) private var viewModel: HomeViewModel

  @Injected(\.isEIDRequestFeatureEnabled) private var isEIDRequestFeatureEnabled: Bool
  @Injected(\.isProximityEnabled) private var isProximityEnabled: Bool

  @Orientation private var orientation

  @ViewBuilder
  private func content() -> some View {
    if orientation.isPortrait {
      portraitLayout()
    } else {
      landscapeLayout()
    }
  }

  private func openHelp() {
    if let url = URL(string: L10n.tkSettingsGeneralHelpLinkValue) {
      UIApplication.shared.open(url)
    }
  }
}

// MARK: - Components

extension HomeView {

  @ViewBuilder
  private func mainContent() -> some View {
    if isProximityEnabled {
      listContent()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.tkHomeTitle)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            menuButton(label: { menuButtonLabel() })
          }
        }
        .safeAreaInset(edge: .bottom) {
          if !orientation.isLandscape {
            proximityFooter()
          }
        }
    } else {
      listContent()
        .safeAreaInset(edge: .bottom) {
          if !orientation.isLandscape {
            portraitFooter()
          }
        }
    }
  }

  private func listContent() -> some View {
    List {
      RequestCasesListView(viewModel.requestCases)
        .listRowSeparator(.hidden)
      switch viewModel.state {
      case .results:
        credentialsList()
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor, ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityFocused($focus, equals: .list)
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      case .error(let error):
        errorView(error)
      case .empty:
        emptyView()
          .listRowSeparator(.hidden)
      }
    }
    .refreshable {
      await viewModel.refresh()
    }
    .listRowSpacing(-10)
    .listStyle(.plain)
  }

  private func emptyView() -> some View {
    ViewThatFits(in: .vertical) {
      VStack {
        Spacer()
        credentialEmptyStateView()
          .frame(maxWidth: .infinity)
          .padding(.horizontal, .x6)
        Spacer()
      }

      ScrollView {
        credentialEmptyStateView()
          .frame(maxWidth: .infinity)
          .padding(.horizontal, .x6)
      }
    }
  }

  private func errorView(_ error: Error) -> some View {
    ViewThatFits(in: .vertical) {
      VStack {
        Spacer()
        emptyStateView(error)
        Spacer()
      }
      .applyScrollViewIfNeeded()
    }
  }

  private func menuButton(@ViewBuilder label: () -> some View) -> some View {
    Menu {
      Section {
        Button(action: viewModel.openBetaId, label: {
          Label(title: { Text(L10n.tkMenuHomeListAdd) }) { HomeAssets.menuID.swiftUIImage }
        })

        if viewModel.isEIDRequestFeatureEnabled {
          Button(action: viewModel.openEIDRequest, label: {
            Label(title: { Text(L10n.tkMenuHomeListOrderEid) }) { HomeAssets.menuID.swiftUIImage }
          })
        }
      }
      Section {
        Button(action: viewModel.openSettings, label: {
          Label(title: { Text(L10n.tkMenuHomeListSettings) }) { HomeAssets.menuSettings.swiftUIImage }
        })
        Button(action: openHelp, label: {
          Label(title: { Text(L10n.tkMenuHomeListHelp) }) { HomeAssets.menuHelp.swiftUIImage }
        })
        .accessibilityAddTraits(.isLink)
      }
    } label: {
      label()
    }
    .menuOrder(.fixed)
    .accessibilityLabel(L10n.tkGlobalMoreoptionsAlt)
    .accessibilityIdentifier(AccessibilityIdentifier.menuButton.rawValue)
    .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
    .accessibilityFocused($focus, equals: .menu)
    .accessibilityAddTraits(.isButton)
  }

  @ViewBuilder
  private func menuButtonLabel() -> some View {
    if isProximityEnabled {
      HomeAssets.menuButtonSmall.swiftUIImage
        .accessibilityHidden(true)
    } else {
      HomeAssets.menuButton.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 60)
        .accessibilityHidden(true)
    }
  }

  @ViewBuilder
  private func scannerButton() -> some View {
    if sizeCategory.isAccessibilityCategory || orientation.isLandscape {
      Button(action: { viewModel.openScanner() }) {
        HomeAssets.scannerButton.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 60)
      }
      .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
      .accessibilityIdentifier(AccessibilityIdentifier.scanButton.rawValue)
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
      .accessibilityFocused($focus, equals: .scan)
    } else {
      Button(action: { viewModel.openScanner() }, label: {
        Label(title: { Text(L10n.tkGlobalScanPrimarybutton) }, icon: { Image(systemName: "qrcode") })
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      })
      .buttonStyle(.primary)
      .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
      .accessibilityIdentifier(AccessibilityIdentifier.scanButton.rawValue)
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
      .frame(height: 60)
      .accessibilityFocused($focus, equals: .scan)
    }
  }

  private func credentialsList() -> some View {
    ForEach(viewModel.credentials, id: \.id) { credential in
      Button(action: { viewModel.openCredential(credential) }, label: {
        AnyView(credential.view())
      })
      .accessibilityIdentifier(AccessibilityIdentifier.credential.rawValue)
    }
  }

  private func credentialEmptyStateView() -> some View {
    VStack(alignment: .center, spacing: .x1) {
      if !sizeCategory.isAccessibilityCategory {
        HomeAssets.emptyWalletIcon.swiftUIImage
          .padding(.bottom, .x6)
          .accessibilityHidden(true)
      }

      Text(L10n.tkGetBetaIdFirstUseTitle)
        .multilineTextAlignment(.center)
        .font(.custom.title3)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityLabel(L10n.tkGetBetaIdFirstUseTitle)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
        .accessibilityAddTraits(.isHeader)

      Text(L10n.tkGetBetaIdFirstUseBody)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .accessibilityLabel(L10n.tkGetBetaIdFirstUseBody)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)

      if isEIDRequestFeatureEnabled {
        Button(action: viewModel.openEIDRequest, label: {
          Label(L10n.tkMenuHomeListOrderEid, systemImage: "arrow.forward")
        })
        .buttonStyle(.tertiary)
        .controlSize(.large)
        .accessibilityLabel(L10n.tkMenuHomeListOrderEid)
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
        .padding(.top, .x6)
      }

      Button(action: viewModel.openBetaId, label: {
        Label(title: { Text(L10n.tkGlobalGetbetaidPrimarybutton) }, icon: { Image(systemName: "arrow.forward") })
      })
      .buttonStyle(.tertiary)
      .controlSize(.large)
      .accessibilityLabel(L10n.tkGlobalGetbetaidPrimarybutton)
      .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
      .padding(.top, .x4)
    }
  }

  private func emptyStateView(_ error: Error) -> some View {
    EmptyStateView(.error(error: error)) { Text(L10n.tkHomeHomescreenEmptyStateButton) } action: { await viewModel.refresh() }
      .padding(.horizontal, .x6)
  }
}

// MARK: - Portrait

extension HomeView {
  private func portraitLayout() -> some View {
    mainContent()
  }

  private func portraitFooter() -> some View {
    VStack {
      HStack {
        menuButton(label: { menuButtonLabel() })
        scannerButton()
      }
      .padding(.horizontal, .x3)
      .padding(.vertical, 10)
    }
    .background(.ultraThinMaterial)
    .clipShape(.capsule)
    .padding(.horizontal, .x6)
    .padding(.vertical, .x4)
  }

  private func proximityFooter() -> some View {
    HomeActionButtons(
      onScanAction: { viewModel.openScanner() },
      onQRCodeAction: { viewModel.openScanner(tab: .proximityEngagement) })
      .padding(.horizontal, .x6)
      .padding(.bottom, .x6)
  }
}

// MARK: - Landscape

extension HomeView {
  private func landscapeLayout() -> some View {
    ViewThatFits(in: .vertical) {
      landscapeContentLayout()
      landscapeScrollableContentLayout()
    }
  }

  private func landscapeContentLayout() -> some View {
    HStack {
      landscapeFooter()
      Spacer()
      mainContent()
    }
  }

  private func landscapeScrollableContentLayout() -> some View {
    HStack {
      landscapeFooter()

      mainContent()
        .padding(.x4)
    }
    .padding(.vertical, .x4)
  }

  @ViewBuilder
  private func landscapeFooter() -> some View {
    if isProximityEnabled {
      proximityFooter()
    } else {
      VStack {
        Spacer()
        menuButton(label: { menuButtonLabel() })
        scannerButton()
        Spacer()
      }
      .padding(.x4)
      .ignoresSafeArea(edges: .bottom)
    }
  }
}

#if DEBUG
#Preview {
  HomeView()
}
#endif
