import BITActivity
import BITCredentialShared
import BITL10n
import BITNavigation
import BITTheming
import Factory
import Foundation
import NavigatorUI
import Refresher
import SwiftUI

// MARK: - CredentialDetailView

struct CredentialDetailView: View {

  // MARK: Lifecycle

  init(credentialId: UUID) {
    _viewModel = State(initialValue: Container.shared.credentialDetailViewModel(credentialId))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "credentialDetailContent"
    case closeButton
    case menuButton
    case refreshButton
    case batchPrivacyWarning
    case batchPrivacyWarningButton
    case deleteButton
    case card
  }

  var body: some View {
    content
      .alert(isPresented: $viewModel.isDeleteCredentialAlertPresented) {
        Alert(
          title: Text(L10n.tkDisplaydeleteCredentialdeleteTitle),
          message: Text(L10n.tkDisplaydeleteCredentialdeleteBody),
          primaryButton: .destructive(Text(L10n.tkGlobalDelete), action: {
            Task {
              await viewModel.deleteCredential()
            }
          }),
          secondaryButton: .cancel(Text(L10n.tkGlobalCancel)))
      }
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
      .toast($viewModel.toast, position: .top)
      .navigationCheckpoint(CredentialDetailCheckpoints.refreshedCredential) { refreshedCredential in
        viewModel.handleCredentialRefreshed(refreshedCredential)
      }
      .navigationBarBackButtonHidden()
      .navigationTitle(viewModel.credentialViewModel?.credentialDisplay?.name ?? "")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        navigationToolbar
      }
      .navigationReturnToCheckpoint(
        trigger: $viewModel.isCredentialDeleted,
        checkpoint: Checkpoints.home,
        value: HomeCheckpointsState.deletedCredential)
      .task {
        await viewModel.onAppear()
        isNavigationBarAccessibilityHidden = false
      }
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModel(with: scheme.rawValue)
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.navigator) private var navigator

  @State private var viewModel: CredentialDetailViewModel
  @State private var isNavigationBarAccessibilityHidden = true

  @Orientation private var orientation

  @ToolbarContentBuilder
  private var navigationToolbar: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      if let credentialViewModel = viewModel.credentialViewModel {
        menu(credentialViewModel)
      }
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      Button(action: { navigator.returnToHomeSafely() }, label: {
        Image(systemName: "xmark")
      })
      .accessibilityLabel(L10n.tkGlobalClosedetailsAlt)
      .accessibilityIdentifier(AccessibilityIdentifier.closeButton.rawValue)
    }
  }

  @ViewBuilder
  private var content: some View {
    if viewModel.isLoading {
      loadingView
    } else if let error = viewModel.error {
      errorView(error)
    } else if orientation.isPortrait {
      portraitLayout
    } else {
      landscapeLayout
    }
  }

  private var loadingView: some View {
    VStack {
      Spacer()
      ProgressView()
        .controlSize(.large)
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private func errorView(_ error: Error) -> some View {
    EmptyStateView(.error(error: error)) {}
  }

}

// MARK: - Portrait layout

extension CredentialDetailView {
  private var portraitLayout: some View {
    ScrollView(showsIndicators: false) {
      LazyVStack(spacing: .x6) {
        header

        contentSection(containsBatchPrivacyWarning: false)
      }
      .padding(.top, .defaultVertical)
    }
    .refresher {
      await viewModel.refresh()
    }
  }

  @ViewBuilder
  private var header: some View {
    if let credentialViewModel = viewModel.credentialViewModel {
      if viewModel.isBatchPrivacyWarningVisible {
        batchWarningHeader(credentialViewModel)
      } else {
        credentialCardHeader(credentialViewModel)
          .accessibilityPriorityFocus()
      }
    }
  }

  @ViewBuilder
  private func batchWarningHeader(_ credentialViewModel: any CredentialViewModelProtocol & CredentialCardViewModelProtocol) -> some View {
    batchPrivacyWarningSection(credentialViewModel.credential.id)
      .accessibilityPriorityFocus()
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

    credentialCardHeader(credentialViewModel)
  }

  private func credentialCardHeader(_ credentialViewModel: any CredentialViewModelProtocol & CredentialCardViewModelProtocol) -> some View {
    credentialCard(credentialViewModel)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, .x4)
  }
}

// MARK: - Landscape layout

extension CredentialDetailView {
  private var landscapeLayout: some View {
    HStack(alignment: .top, spacing: .x6) {
      if let credentialViewModel = viewModel.credentialViewModel {
        credentialCard(credentialViewModel)
          .frame(maxWidth: .infinity)
          .accessibilityPriorityFocus()
      }

      ScrollView(showsIndicators: false) {
        contentSection()
      }
      .refresher {
        await viewModel.refresh()
      }
    }
    .safeAreaPadding(.top, .x4)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

// MARK: - Components

extension CredentialDetailView {

  @ViewBuilder
  private func contentSection(containsBatchPrivacyWarning: Bool = true) -> some View {
    switch viewModel.credentialViewModel {
    case let verifiableCredential as VerifiableCredentialViewModel:
      verifiableCredentialContent(verifiableCredential, containsBatchPrivacyWarning: containsBatchPrivacyWarning)
    case let deferredCredential as DeferredCredentialViewModel:
      deferredCredentialContent(deferredCredential)
    default: EmptyView()
    }
  }

  private func credentialCard(_ credentialViewModel: CredentialCardViewModelProtocol) -> some View {
    CredentialCard(
      name: credentialViewModel.credentialDisplay?.name,
      summary: credentialViewModel.credentialDisplay?.summary,
      background: credentialViewModel.credentialDisplay?.backgroundColor,
      logoBase64: credentialViewModel.credentialDisplay?.logoBase64,
      environment: credentialViewModel.environment,
      statusBadgeLabel: credentialViewModel.statusText,
      statusBadgeImage: credentialViewModel.statusImage,
      statusBadgeStyle: credentialViewModel.cardStatusBadgeStyle,
      style: credentialViewModel.cardStyle)
      .accessibilityElement(children: .combine)
      .accessibilityIdentifier(AccessibilityIdentifier.card.rawValue)
      .controlSize(.large)
  }

  private func menu(_ credentialViewModel: CredentialCardViewModelProtocol) -> some View {
    Menu {
      if credentialViewModel is VerifiableCredentialViewModel {
        Section {
          Button(action: {
            if credentialViewModel.isRefreshable, let credential = viewModel.credential {
              navigator.navigate(to: CredentialDestinations.refresh(CredentialDetailRefreshInput(credential: credential)))
            } else {
              navigator.navigate(to: CredentialDestinations.updateCredentialInfo(credentialViewModel.issuerDisplay))
            }
          }, label: {
            Text(L10n.tkDisplayrefreshMenuPrimarybutton)
          })
          .accessibilityLabel(L10n.tkDisplayrefreshMenuPrimarybutton)
          .accessibilityIdentifier(AccessibilityIdentifier.refreshButton.rawValue)
        }
      }

      Button(role: .destructive, action: {
        viewModel.isDeleteCredentialAlertPresented.toggle()
      }, label: {
        Label(L10n.tkDisplaydeleteCredentialmenuPrimarybutton, systemImage: "trash")
      })
      .accessibilityLabel(L10n.tkDisplaydeleteCredentialmenuPrimarybutton)
      .accessibilityIdentifier(AccessibilityIdentifier.deleteButton.rawValue)
    } label: {
      Image(systemName: "ellipsis")
        .accessibilityHidden(true)
    }
    .menuOrder(.fixed)
    .accessibilityHidden(isNavigationBarAccessibilityHidden)
    .accessibilityLabel(L10n.tkGlobalMoreoptionsAlt)
    .accessibilityIdentifier(AccessibilityIdentifier.menuButton.rawValue)
    .accessibilityActions {
      if credentialViewModel is VerifiableCredentialViewModel {
        Button(L10n.tkDisplayrefreshMenuPrimarybutton) {
          if credentialViewModel.isRefreshable, let credential = viewModel.credential {
            navigator.navigate(to: CredentialDestinations.refresh(CredentialDetailRefreshInput(credential: credential)))
          } else {
            navigator.navigate(to: CredentialDestinations.updateCredentialInfo(credentialViewModel.issuerDisplay))
          }
        }
      }

      Button(L10n.tkDisplaydeleteCredentialmenuPrimarybutton) {
        viewModel.isDeleteCredentialAlertPresented.toggle()
      }
    }
  }
}

// MARK: - Verifiable Credential

extension CredentialDetailView {

  private func batchPrivacyWarningSection(_ credentialId: UUID) -> some View {
    VStack(alignment: .leading, spacing: .x4) {
      batchPrivacyWarningHeader {
        Image(systemName: "exclamationmark.triangle")
          .foregroundStyle(ThemingAssets.Component.Callout.Alert.symbol.swiftUIColor)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 0) {
          Text(L10n.tkDisplaybatchPrivacyWarningTitle)
            .font(.custom.bodyEmphasized)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)

          Text(L10n.tkDisplaybatchPrivacyWarningBody)
            .font(.custom.body)
            .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
            .multilineTextAlignment(.leading)
        }
      }

      Button(action: {
        navigator.navigate(to: CredentialDestinations.issuanceType(credentialId))
      }) {
        Text(L10n.tkDisplaybatchPrivacyWarningButton)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)
          .frame(maxWidth: .infinity)
          .frame(minHeight: .x8)
      }
      .background(ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
      .clipShape(.capsule)
      .accessibilityIdentifier(AccessibilityIdentifier.batchPrivacyWarningButton.rawValue)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.x4)
    .background(ThemingAssets.Background.groupedRow.swiftUIColor)
    .clipShape(RoundedRectangle(cornerRadius: .x5))
    .contentShape(.accessibility, .rect(cornerRadius: .x5))
    .padding(.horizontal, .x4)
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier(AccessibilityIdentifier.batchPrivacyWarning.rawValue)
  }

  @ViewBuilder
  private func issuerSection(_ verifiableCredentialViewModel: VerifiableCredentialViewModel) -> some View {
    if let issuer = verifiableCredentialViewModel.issuerDisplay {
      SectionView(title: L10n.tkDisplaydeleteDisplaycredential1Title5) {
        HStack(alignment: .center, spacing: .x3) {
          if !dynamicTypeSize.isAccessibilitySize {
            NormalizedLogoCircular(issuer.image)
              .controlSize(.mini)
          }
          Text(issuer.name ?? L10n.tkErrorNotregisteredTitle)
            .font(.custom.body)
            .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilityLabel(issuer.name ?? L10n.tkErrorNotregisteredTitle)
            .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .x6)
        .padding(.vertical, .x2)

        Divider()
          .padding(.leading, .x6)
        issuanceTypeView(
          title: verifiableCredentialViewModel.issuanceTypeTitle,
          credential: verifiableCredentialViewModel.credential)
      }
    }
  }

  @ViewBuilder
  private func batchPrivacyWarningHeader(@ViewBuilder content: () -> some View) -> some View {
    if dynamicTypeSize.isAccessibilitySize {
      VStack(alignment: .leading, spacing: .x2, content: content)
    } else {
      HStack(alignment: .top, spacing: .x2, content: content)
    }
  }

  private func verifiableCredentialContent(
    _ verifiableCredentialViewModel: VerifiableCredentialViewModel,
    containsBatchPrivacyWarning: Bool = true)
    -> some View
  {
    VStack(alignment: .leading, spacing: .x6) {
      if containsBatchPrivacyWarning {
        batchPrivacyWarningSection(verifiableCredentialViewModel.credential.id)
      }
      RecentActivitiesWidget(viewModel.activities, credentialId: verifiableCredentialViewModel.credential.id, isActivityHistoryEnabled: viewModel.isActivityHistoryEnabled)
      ClaimClusterList(verifiableCredentialViewModel.credential.resolvedClusters)
      issuerSection(verifiableCredentialViewModel)
    }
  }

  private func issuanceTypeView(title: String, credential: VerifiableCredential) -> some View {
    Button(action: { navigator.navigate(to: CredentialDestinations.issuanceType(credential.id)) }) {
      KeyValueCell(key: L10n.tkCredentialIssuanceTypeTitle, value: title) {
        HStack(spacing: .x4) {
          if viewModel.isBatchPrivacyWarningVisible {
            Image(systemName: "exclamationmark.triangle")
              .foregroundStyle(ThemingAssets.Component.Callout.Alert.symbol.swiftUIColor)
          }

          Image(systemName: "chevron.right")
            .font(.system(size: 14))
        }
        .accessibilityHidden(true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, .x6)
    }
  }
}

// MARK: - Deferred Credential

extension CredentialDetailView {

  private var inProgressContent: some View {
    SectionView {
      VStack(alignment: .leading) {
        Text(L10n.tkDeferredCredentialDetailsInProgressContentTitle)
          .font(.custom.bodyBold)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityAddTraits(.isHeader)
        Text(L10n.tkDeferredCredentialDetailsInProgressContentBody)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, .x6)
      .padding(.vertical, .x4)
    }
  }

  private var invalidContent: some View {
    SectionView {
      VStack(alignment: .leading) {
        VStack(alignment: .leading) {
          Text(L10n.tkDeferredCredentialDetailsInvalidContentTitle)
            .font(.custom.bodyBold)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilityAddTraits(.isHeader)
          Text(L10n.tkDeferredCredentialDetailsInvalidContentBody)
            .font(.custom.body)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .leading) {
          Text(L10n.tkDeferredCredentialDetailsInvalidContentTitle2)
            .font(.custom.bodyBold)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilityAddTraits(.isHeader)
          Text(L10n.tkDeferredCredentialDetailsInvalidContentBody2)
            .font(.custom.body)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .x2)

        Button(action: { viewModel.isDeleteCredentialAlertPresented.toggle() }) {
          Text(L10n.tkDeferredCredentialDetailsInvalidButton)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.tertiary)
        .controlSize(.regular)
        .padding(.top, .x2)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, .x6)
      .padding(.vertical, .x4)
    }
  }

  private var issuanceFailedContent: some View {
    SectionView {
      VStack(alignment: .leading) {
        Text(L10n.tkDeferredCredentialDetailsIssuanceFailedContentTitle)
          .font(.custom.bodyBold)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityAddTraits(.isHeader)
        Text(L10n.tkDeferredCredentialDetailsIssuanceFailedContentBody)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, .x6)
      .padding(.vertical, .x4)
    }
  }

  @ViewBuilder
  private func deferredCredentialContent(_ deferredCredentialViewModel: DeferredCredentialViewModel) -> some View {
    switch deferredCredentialViewModel.credential.progressionState {
    case .inProgress:
      inProgressContent
    case .invalid:
      invalidContent
    case .issuanceFailed:
      issuanceFailedContent
    }
  }

}

#if DEBUG
#Preview {
  CredentialDetailView(credentialId: DeferredCredential.Mock.sample.id)
}
#endif
