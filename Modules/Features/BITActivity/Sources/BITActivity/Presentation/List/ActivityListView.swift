import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - ActivityListView

public struct ActivityListView: View {

  // MARK: Lifecycle

  public init(credentialId: UUID) {
    self.credentialId = credentialId
    _viewModel = StateObject(wrappedValue: Container.shared.activityListViewModel(credentialId))
  }

  // MARK: Public

  public var body: some View {
    content
      .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
      .navigationTitle(L10n.tkActivityActivityListTitle)
      .navigationBarTitleDisplayMode(.inline)
      .navigationCheckpoint(ActivityCheckpoints.activities) { showToast in
        if showToast {
          viewModel.showActivityDeleted()
        }
      }
      .task {
        await viewModel.fetchActivities()
      }
      .toastMessage(
        isPresented: $viewModel.isToastPresented,
        message: viewModel.toastMessage,
        clearAction: viewModel.clearToast)
  }

  // MARK: Private

  @StateObject private var viewModel: ActivityListViewModel
  @Environment(\.navigator) private var navigator

  private let credentialId: UUID

  @ViewBuilder
  private var content: some View {
    ZStack {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      stateContent
        .landscapeMaxWidth()
    }
  }

  @ViewBuilder
  private var stateContent: some View {
    switch viewModel.state {
    case .result(let viewModels):
      list(viewModels)
    case .loading:
      ProgressView()
        .controlSize(.large)
    case .error(let error):
      EmptyStateView(.error(error: error)) {}
    }
  }

  @ViewBuilder
  private func list(_ viewModels: [ActivityCellViewModel]) -> some View {
    List(viewModels) { viewModel in
      ActivityCell(viewModel) {
        navigator.navigate(
          to: ActivityDestinations.activityDetail(activity: viewModel.activity, credentialId: credentialId))
      }
      .listRowBackground(ThemingAssets.Background.groupedRow.swiftUIColor)
    }
    .listStyle(.insetGrouped)
    .scrollIndicators(.hidden)
    .scrollContentBackground(.hidden)
    .overlay(alignment: .top) {
      if viewModels.isEmpty {
        SectionView {
          ActivityEmptyCell()
        }
        .padding(.top, .x4)
      }
    }
  }
}
