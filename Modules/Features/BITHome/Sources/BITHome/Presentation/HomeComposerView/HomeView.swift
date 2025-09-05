import BITCredential
import BITCredentialShared
import BITEIDRequest
import BITL10n
import BITSettings
import BITTheming
import Factory
import SwiftUI

// MARK: - HomeView

struct HomeView: View {

  // MARK: Lifecycle

  init(router: HomeRouterRoutes) {
    self.router = router

    _viewModel = StateObject(wrappedValue: Container.shared.homeViewModel(router))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "homeContent"
    case scanButton
    case menuButton
    case credential
  }

  enum AccessibilityPriority: Double {
    case x1 = 100
    case x2 = 80
    case x3 = 50
    case x4 = 30
  }

  var body: some View {
    content()
      .onAppear {
        UIAccessibility.post(notification: .screenChanged, argument: L10n.tkHomeHomescreenAlt)
        Task {
          await viewModel.onAppear()
        }

        Task {
          await viewModel.getEIDRequestCases()
        }
      }
      .accessibilityAction(named: L10n.tkGlobalScanPrimarybutton, {
        viewModel.openScanner()
      })
      .accessibilityAction(named: L10n.tkGlobalMoreoptionsAlt, {
        focus = .menu
      })
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModels(with: scheme.rawValue)
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private enum FocusableElement: Hashable {
    case scan, menu, list, emptyState, error
  }

  @StateObject private var viewModel: HomeViewModel
  @Environment(\.sizeCategory) private var sizeCategory
  @AccessibilityFocusState private var focus: FocusableElement?

  @Injected(\.isEIDRequestFeatureEnabled) private var isEIDRequestFeatureEnabled: Bool

  private let router: HomeRouterRoutes

  @Orientation private var orientation

  @ViewBuilder
  private func content() -> some View {
    if orientation.isPortrait {
      portraitLayout()
    } else {
      landscapeLayout()
    }
  }

}

// MARK: - Components

extension HomeView {

  @ViewBuilder
  private func mainContent() -> some View {
    List {
      RequestCasesListView(viewModel.requestCases)
        .listRowSeparator(.hidden)
      switch viewModel.state {
      case .results:
        credentialsList()
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor, ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityFocused($focus, equals: .list)
          .accessibilitySortPriority(10)
      case .error:
        errorView()
      case .empty:
        emptyView()
          .listRowSeparator(.hidden)
      }
    }
    .refreshable {
      async let credentialStatus: Void = viewModel.send(event: .checkCredentialsStatus)
      async let requestCasesStatus: Void = viewModel.fetchEIDRequestStatus()

      _ = await (credentialStatus, requestCasesStatus)
    }
    .listRowSpacing(-10)
    .listStyle(.plain)
    .safeAreaInset(edge: .bottom) {
      if !orientation.isLandscape {
        portraitFooter()
      }
    }
  }

  @ViewBuilder
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

  @ViewBuilder
  private func errorView() -> some View {
    ViewThatFits(in: .vertical) {
      VStack {
        Spacer()
        EmptyStateView(.error(error: viewModel.stateError)) { Text("Refresh") } action: { await viewModel.send(event: .refresh) }
          .padding(.horizontal, .x6)
        Spacer()
      }

      ScrollView {
        EmptyStateView(.error(error: viewModel.stateError)) { Text("Refresh") } action: { await viewModel.send(event: .refresh) }
          .padding(.horizontal, .x6)
      }
    }
  }

  @ViewBuilder
  private func menuButton() -> some View {
    Menu {
      Section {
        Button(action: viewModel.openHelp, label: {
          Label(title: { Text(L10n.tkMenuHomeListHelp) }) { HomeAssets.menuHelp.swiftUIImage }
        })
        Button(action: viewModel.openSettings, label: {
          Label(title: { Text(L10n.tkMenuHomeListSettings) }) { HomeAssets.menuSettings.swiftUIImage }
        })
      }

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
    } label: {
      HomeAssets.menuButton.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 60)
        .accessibilityHidden(true)
    }
    .accessibilityLabel(L10n.tkGlobalMoreoptionsAlt)
    .accessibilityIdentifier(AccessibilityIdentifier.menuButton.rawValue)
    .accessibilitySortPriority(50)
    .accessibilityFocused($focus, equals: .menu)
    .accessibilityAddTraits(.isButton)
  }

  @ViewBuilder
  private func scannerButton() -> some View {
    if sizeCategory.isAccessibilityCategory || orientation.isLandscape {
      Button(action: viewModel.openScanner) {
        HomeAssets.scannerButton.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 60)
      }
      .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
      .accessibilityIdentifier(AccessibilityIdentifier.scanButton.rawValue)
      .accessibilitySortPriority(100)
      .accessibilityFocused($focus, equals: .scan)
    } else {
      Button(action: viewModel.openScanner, label: {
        Label(title: { Text(L10n.tkGlobalScanPrimarybutton) }, icon: { Image(systemName: "qrcode") })
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      })
      .buttonStyle(.filledPrimary)
      .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
      .accessibilityIdentifier(AccessibilityIdentifier.scanButton.rawValue)
      .accessibilitySortPriority(100)
      .frame(height: 60)
      .accessibilityFocused($focus, equals: .scan)
    }
  }

  @ViewBuilder
  private func credentialsList() -> some View {
    ForEach(viewModel.credentialViewModels) { credentialViewModel in
      Button(action: { viewModel.openDetail(for: credentialViewModel.credential) }, label: {
        CredentialCell(credentialViewModel)
          .accessibilityElement(children: .contain)
          .accessibilityIdentifier(AccessibilityIdentifier.credential.rawValue)
      })
    }
  }

  @ViewBuilder
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
        .buttonStyle(.filledSecondary)
        .controlSize(.large)
        .accessibilityLabel(L10n.tkMenuHomeListOrderEid)
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
        .padding(.top, .x6)
      }

      Button(action: viewModel.openBetaId, label: {
        Label(title: { Text(L10n.tkGlobalGetbetaidPrimarybutton) }, icon: { Image(systemName: "arrow.forward") })
      })
      .buttonStyle(.filledSecondary)
      .controlSize(.large)
      .accessibilityLabel(L10n.tkGlobalGetbetaidPrimarybutton)
      .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
      .padding(.top, .x4)
    }
  }
}

// MARK: - Portrait

extension HomeView {
  @ViewBuilder
  private func portraitLayout() -> some View {
    mainContent()
  }

  @ViewBuilder
  private func portraitFooter() -> some View {
    VStack {
      HStack {
        menuButton()
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
}

// MARK: - Landscape

extension HomeView {
  @ViewBuilder
  private func landscapeLayout() -> some View {
    ViewThatFits(in: .vertical) {
      landscapeContentLayout()
      landscapeScrollableContentLayout()
    }
  }

  @ViewBuilder
  private func landscapeContentLayout() -> some View {
    HStack {
      landscapeFooter()
      Spacer()
      mainContent()
    }
  }

  @ViewBuilder
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
    VStack {
      Spacer()
      menuButton()
      scannerButton()
      Spacer()
    }
    .padding(.x4)
    .ignoresSafeArea(edges: .bottom)
  }
}

#if DEBUG
#Preview {
  HomeView(router: HomeRouter())
}
#endif
