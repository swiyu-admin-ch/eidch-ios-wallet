import BITActivity
import BITCredential
import BITCredentialShared
import BITL10n
import BITNonCompliance
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - ActivityDetailView

struct ActivityDetailView: View {

  // MARK: Lifecycle

  init(_ activity: Activity, credentialId: UUID) {
    _viewModel = StateObject(wrappedValue: Container.shared.activityDetailViewModel((activity, credentialId)))
  }

  // MARK: Internal

  var body: some View {
    ZStack(alignment: .top) {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      content
        .landscapeMaxWidth()
        .applyScrollViewIfNeeded()
    }
    .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
    .navigationTitle(L10n.tkActivityActivityDetailTitle)
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await viewModel.fetchCredential()
    }
    .alert(isPresented: $viewModel.isDeleteConfirmationPresented) {
      Alert(
        title: Text(L10n.tkActivityActivityDetailDeleteConfirmationTitle),
        message: Text(L10n.tkActivityActivityDetailDeleteConfirmationBody),
        primaryButton: .destructive(Text(L10n.tkGlobalDelete), action: {
          viewModel.deleteActivity()
          navigator.returnToCheckpoint(ActivityCheckpoints.activities, value: true)
        }),
        secondaryButton: .cancel(Text(L10n.tkGlobalCancel)))
    }
  }

  // MARK: Private

  @StateObject private var viewModel: ActivityDetailViewModel

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.navigator) private var navigator

  @ViewBuilder
  private var content: some View {
    switch viewModel.state {
    case .result(let activity, let credential):
      resultContent(cellViewModel: activity, credentialViewModel: credential)
    case .error(let error):
      EmptyStateView(.error(error: error)) {}
    }
  }

  private var actorInfo: some View {
    SectionView(title: viewModel.actorTitle, minHeight: nil) {
      HStack(alignment: dynamicTypeSize.isAccessibilitySize ? .top : .center, spacing: .x4) {
        NormalizedLogoCircular(viewModel.actorImage)
        Text(viewModel.actorName ?? L10n.tkErrorNotregisteredTitle)
          .font(.custom.body)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
          .multilineTextAlignment(.leading)
      }
      .padding(.horizontal, .x4)
    }
  }

  private func resultContent(cellViewModel: ActivityCellViewModel, credentialViewModel: ActivityCredentialViewModel?) -> some View {
    VStack(spacing: .x4) {
      SectionView(minHeight: nil) {
        ActivityCell(cellViewModel, configuration: .compact)
          .padding(.vertical, .x1)
          .padding(.horizontal, .x4)
      }
      actorInfo
      if let credentialViewModel {
        credentialInfo(credentialViewModel)
        if !credentialViewModel.clusters.isEmpty {
          ClaimClusterList(credentialViewModel.clusters)
        }
      }
      SectionView(minHeight: nil, hasContentPadding: false) {
        if viewModel.isNonComplianceEnabled, viewModel.activity.type != .issuance, let credentialViewModel {
          ButtonCell(
            icon: Assets.flag.swiftUIImage,
            title: L10n.tkActivityActivityDetailReportIssuerButton,
            role: .destructive,
            hasDivider: true)
          {
            navigator.navigate(to: NonComplianceDestinations.categories(
              activityId: viewModel.activity.id,
              credentialId: credentialViewModel.credentialId)
            )
          }
        }
        ButtonCell(
          icon: Assets.trash.swiftUIImage,
          title: L10n.tkActivityActivityDetailDeleteEntryButton,
          role: .destructive)
        {
          viewModel.showDeleteActivityConfirmation()
        }
      }
    }
    .padding(.vertical, .x4)
  }

  private func credentialInfo(_ viewModel: ActivityCredentialViewModel) -> some View {
    SectionView(title: L10n.tkActivityActivityDetailCredentialTitle, minHeight: nil) {
      HStack(alignment: .center, spacing: .x3) {
        CredentialCard(
          name: viewModel.name,
          summary: viewModel.summary,
          background: viewModel.backgroundColor,
          logoBase64: viewModel.logoBase64,
          environment: viewModel.environment)
          .controlSize(.mini)
        VStack(alignment: .leading, spacing: 0) {
          Text(viewModel.name ?? L10n.tkCredentialFallbackTitle)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .font(.custom.body)
          if let summary = viewModel.summary {
            Text(summary)
              .font(.custom.body)
              .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          }
        }.accessibilityElement(children: .combine)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, .x1)
      .padding(.horizontal, .x4)
    }
  }

}

#if DEBUG
#Preview {
  ActivityDetailView(.Mock.issueTrusted, credentialId: VerifiableCredential.Mock.sample.id)
}
#endif
