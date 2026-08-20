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

  init(_ activityId: UUID) {
    _viewModel = State(initialValue: Container.shared.activityDetailViewModel(activityId))
  }

  // MARK: Internal

  var body: some View {
    Content(
      state: viewModel.state,
      isDeleteConfirmationPresented: $viewModel.isDeleteConfirmationPresented,
      toast: $viewModel.toast,
      eventAction: { event in Task { await viewModel.send(event) } })
      .onColorSchemeChange { scheme in
        Task {
          await viewModel.send(.onColorSchemeChange(colorScheme: scheme.rawValue))
        }
      }
  }

  // MARK: Private

  @State private var viewModel: ActivityDetailViewModel
}

// MARK: ActivityDetailView.Content

extension ActivityDetailView {
  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      state: ActivityDetailState,
      isDeleteConfirmationPresented: Binding<Bool>,
      toast: Binding<Toast?>,
      eventAction: @escaping (ActivityDetailViewModel.Event) -> Void = { _ in })
    {
      self.state = state
      self.isDeleteConfirmationPresented = isDeleteConfirmationPresented
      self.toast = toast
      self.eventAction = eventAction
    }

    // MARK: Internal

    var body: some View {
      ZStack(alignment: .top) {
        ThemingAssets.Background.secondary.swiftUIColor
          .frame(maxWidth: .infinity)
          .ignoresSafeArea()
        ScrollView(showsIndicators: false) {
          content
            .landscapeMaxWidth()
        }
      }
      .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
      .navigationTitle(L10n.tkActivityActivityDetailTitle)
      .navigationBarTitleDisplayMode(.inline)
      .navigationCheckpoint(ActivityCheckpoints.activityDetail) { submitted in
        guard submitted else { return }
        eventAction(.nonComplianceReportSent)
      }
      .alert(isPresented: isDeleteConfirmationPresented) {
        Alert(
          title: Text(L10n.tkActivityActivityDetailDeleteConfirmationTitle),
          message: Text(L10n.tkActivityActivityDetailDeleteConfirmationBody),
          primaryButton: .destructive(Text(L10n.tkGlobalDelete), action: {
            eventAction(.activityDeletionConfirmed)
            navigator.returnToCheckpointSafely(ActivityCheckpoints.activities, value: true)
          }),
          secondaryButton: .cancel(Text(L10n.tkGlobalCancel)))
      }
      .toast(toast)
    }

    // MARK: Private

    @Environment(\.navigator) private var navigator

    private let state: ActivityDetailState
    private let isDeleteConfirmationPresented: Binding<Bool>
    private let toast: Binding<Toast?>
    private let eventAction: (ActivityDetailViewModel.Event) -> Void

    @Injected(\.isNonComplianceEnabled) private var isNonComplianceEnabled

    @ViewBuilder
    private var content: some View {
      switch state {
      case .loading:
        ProgressView()
          .controlSize(.large)
      case .result(let result):
        resultContent(result: result)
      case .error(let error):
        EmptyStateView(.error(error: error)) {}
      }
    }

    private func actorInfo(actor: ActivityDetailState.Actor, activityType: ActivityType) -> some View {
      SectionView(title: actor.title, footer: activityType.actorTrustFooter, minHeight: nil, hasContentPadding: false) {
        ActorHeaderView(viewModel: actor.viewModel) { actorInformation in
          navigator.navigate(
            to: ActivityDetailInternalDestinations.actorInformation(actorInformation))
        }
        .padding(.bottom, .x1)
      }
    }

    private func resultContent(result: ActivityDetailState.Result) -> some View {
      VStack(spacing: .x4) {
        SectionView(minHeight: nil) {
          ActivityCell(result.activity, configuration: .compact)
            .padding(.vertical, .x1)
            .padding(.horizontal, .x4)
        }
        actorInfo(actor: result.actor, activityType: result.activity.type)
        credentialInfo(result.credential, title: result.activity.type.credentialInfoTitle)
        if !result.credential.clusters.isEmpty {
          ClaimClusterList(result.credential.clusters)
        }
        SectionView(minHeight: nil, hasContentPadding: false) {
          if isNonComplianceEnabled, result.actor.isReportAllowed {
            ButtonCell(
              icon: Assets.flag.swiftUIImage,
              title: result.activity.type.reportActorButtonTitle,
              role: .destructive,
              hasDivider: true)
            {
              navigator.navigate(to: NonComplianceDestinations.categories(activityType: result.activity.type, activityId: result.activity.id))
            }
          }
          ButtonCell(
            icon: Assets.trash.swiftUIImage,
            title: L10n.tkActivityActivityDetailDeleteEntryButton,
            role: .destructive)
          {
            eventAction(.deleteActivity)
          }
        }
      }
      .padding(.vertical, .x4)
    }

    private func credentialInfo(_ viewModel: ActivityCredentialViewModel, title: String?) -> some View {
      VStack(alignment: .leading, spacing: 0) {
        if let title {
          Text(title)
            .fontWeight(.medium)
            .font(.custom.title3)
            .padding(.top, .x4)
            .padding(.horizontal, .x8)
            .accessibilityAddTraits(.isHeader)
        }
        SectionView(title: L10n.tkActivityActivityDetailCredentialTitle, footer: L10n.tkActivityActivityDetailCredentialFooter, minHeight: nil) {
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
  }
}

#if DEBUG
#Preview {
  ActivityDetailView.Content(
    state: .Mock.result,
    isDeleteConfirmationPresented: .constant(false),
    toast: .constant(nil))
}
#endif
