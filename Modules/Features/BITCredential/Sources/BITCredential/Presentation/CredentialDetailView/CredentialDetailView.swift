import BITActivity
import BITCredentialShared
import BITL10n
import BITNavigation
import BITTheming
import Factory
import NavigatorUI
import Refresher
import SwiftUI

// MARK: - CredentialDetailView

struct CredentialDetailView: View {

  // MARK: Lifecycle

  init(credential: CredentialProtocol) {
    _viewModel = State(initialValue: Container.shared.credentialDetailViewModel(credential))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "credentialDetailContent"
    case closeButton
    case menuButton
    case deleteButton
    case wrongDataButton
    case card
  }

  var body: some View {
    content()
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

  @Orientation private var orientation

  @ToolbarContentBuilder
  private var navigationToolbar: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      if let credentialViewModel = viewModel.credentialViewModel {
        menu(credentialViewModel)
      }
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      Button(action: { navigator.dismiss() }, label: {
        ThemingAssets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClosedetailsAlt)
      .accessibilityIdentifier(AccessibilityIdentifier.closeButton.rawValue)
    }
  }

  @ViewBuilder
  private func content() -> some View {
    if orientation.isPortrait {
      portraitLayout()
    } else {
      landscapeLayout()
    }
  }

}

// MARK: - Portrait layout

extension CredentialDetailView {
  private func portraitLayout() -> some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: .x6) {
        if let credentialViewModel = viewModel.credentialViewModel {
          credentialCard(credentialViewModel)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, .x4)
            .padding(.top, .defaultVertical)
        }

        contentSection()
      }
    }
    .refresher {
      await viewModel.refresh()
    }
  }
}

// MARK: - Landscape layout

extension CredentialDetailView {
  private func landscapeLayout() -> some View {
    HStack(alignment: .top, spacing: .x6) {
      if let credentialViewModel = viewModel.credentialViewModel {
        credentialCard(credentialViewModel)
          .frame(maxWidth: .infinity)
          .padding(.top, .x4)
      }

      ScrollView(showsIndicators: false) {
        contentSection()
      }
      .refresher {
        await viewModel.refresh()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}

// MARK: - Components

extension CredentialDetailView {

  @ViewBuilder
  private func contentSection() -> some View {
    switch viewModel.credentialViewModel {
    case let verifiableCredential as VerifiableCredentialViewModel:
      verifiableCredentialContent(verifiableCredential)
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
      .accessibilityPriorityFocus()
      .controlSize(.large)
  }

  private func menu(_ credentialViewModel: CredentialCardViewModelProtocol) -> some View {
    Menu {
      if credentialViewModel is VerifiableCredentialViewModel {
        Section {
          Button(action: { navigator.navigate(to: CredentialDestinations.wrongData) }, label: {
            Label(title: { Text(L10n.tkGlobalWrongdata) }, icon: { Assets.warning.swiftUIImage })
          })
          .accessibilityLabel(L10n.tkGlobalWrongdata)
          .accessibilityIdentifier(AccessibilityIdentifier.wrongDataButton.rawValue)
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
      ThemingAssets.elipsis.swiftUIImage
        .colorMultiply(ThemingAssets.Brand.Core.black.swiftUIColor)
        .frame(width: 32, height: 32)
        .background(ThemingAssets.navigationAccent.swiftUIColor.opacity(0.12))
        .clipShape(.circle)
    }
    .accessibilityLabel(L10n.tkGlobalMoreoptionsAlt)
    .accessibilityIdentifier(AccessibilityIdentifier.menuButton.rawValue)
    .accessibilityActions {
      if credentialViewModel is VerifiableCredentialViewModel {
        Button(L10n.tkGlobalWrongdata) {
          navigator.navigate(to: CredentialDestinations.wrongData)
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

  @ViewBuilder
  private var issuerSection: some View {
    if let issuer = viewModel.credentialViewModel?.issuerDisplay {
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
      }
    }
  }

  private var wrongDataSection: some View {
    SectionView {
      IconCell(
        image: Assets.warning.swiftUIImage,
        text: L10n.tkReceiveIncorrectdataTitle,
        disclosureIndicator: .navigation,
        onTap: { navigator.navigate(to: CredentialDestinations.wrongData) })
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .padding(.horizontal, .x6)
        .padding(.vertical, .x2)
    }
  }

  private func verifiableCredentialContent(_ verifiableCredentialViewModel: VerifiableCredentialViewModel) -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      RecentActivitiesWidget(viewModel.activities, credentialId: viewModel.credential.id, isActivityHistoryEnabled: viewModel.isActivityHistoryEnabled)
      ClaimClusterList(verifiableCredentialViewModel.credential.clusters)
      issuerSection
      wrongDataSection
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

  @ViewBuilder
  private func deferredCredentialContent(_ deferredCredentialViewModel: DeferredCredentialViewModel) -> some View {
    switch deferredCredentialViewModel.credential.progressionState {
    case .inProgress:
      inProgressContent
    case .invalid:
      invalidContent
    }
  }

}

#if DEBUG
#Preview {
  CredentialDetailView(credential: DeferredCredential.Mock.sample)
}
#endif
