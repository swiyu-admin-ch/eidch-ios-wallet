import BITActivity
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - NonComplianceFormView

struct NonComplianceFormView: View {

  // MARK: Lifecycle

  init(category: NonComplianceCategory, activityId: UUID) {
    _viewModel = StateObject(wrappedValue: NonComplianceFormViewModel(category: category, activityId: activityId))
  }

  // MARK: Internal

  var body: some View {
    Content(
      state: viewModel.state,
      description: $viewModel.description,
      email: $viewModel.email,
      eventAction: { event in await viewModel.send(event) })
      .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
      .navigate(to: $viewModel.destination)
      .navigationTitle(viewModel.title)
      .navigationBarTitleDisplayMode(.inline)
      .navigationCheckpoint(NonComplianceCheckpoints.form) { update in
        Task { await viewModel.send(.updateForm(update)) }
      }
      .toolbar {
        CloseButtonToolbar(action: {
          navigator.dismiss()
        })
      }
      .onChange(of: viewModel.state) { state in
        guard state == .final else { return }
        navigator.returnToCheckpoint(ActivityCheckpoints.activityDetail, value: true)
        navigator.dismiss()
      }
      .task {
        await viewModel.send(.fetchActivity)
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @StateObject private var viewModel: NonComplianceFormViewModel
}

// MARK: NonComplianceFormView.Content

extension NonComplianceFormView {
  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      state: NonComplianceFormViewState,
      description: Binding<String>,
      email: Binding<String>,
      eventAction: @escaping (NonComplianceFormViewModel.Event) async -> Void = { _ in })
    {
      self.state = state
      _description = description
      _email = email
      self.eventAction = eventAction
    }

    // MARK: Internal

    var body: some View {
      ZStack(alignment: .top) {
        ThemingAssets.Background.secondary.swiftUIColor
          .frame(maxWidth: .infinity)
          .ignoresSafeArea()
        content
          .landscapeMaxWidth()
      }
    }

    // MARK: Private

    @Binding private var description: String
    @Binding private var email: String

    @Environment(\.navigator) private var navigator
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let state: NonComplianceFormViewState
    private let eventAction: (NonComplianceFormViewModel.Event) async -> Void

    @ViewBuilder
    private var content: some View {
      switch state {
      case .loading:
        ProgressView()
      case .result(let result):
        resultContent(result)
      case .error(let error):
        EmptyStateView(.error(error: error)) {}
      case .final:
        EmptyView()
      }
    }

    private func resultContent(_ result: NonComplianceFormViewState.Result) -> some View {
      Form {
        actorView(actorImage: result.actorImage, actorName: result.actorName)
        formFields(result)
      }
      .landscapeMaxWidth()
      .scrollContentBackground(.hidden)
      .safeAreaInset(edge: .bottom) {
        button(isEnabled: result.isSendingEnabled)
      }
    }

    private func formFields(_ result: NonComplianceFormViewState.Result) -> some View {
      Section {
        Button {
          navigator.navigate(to: NonComplianceInternalDestinations.description(value: description))
        } label: {
          NonComplianceFormCell(
            viewModel: NonComplianceFormCellViewModel(
              field: .description,
              value: $description,
              validation: result.validations[.description]))
        }

        NonComplianceFormCell(
          viewModel: NonComplianceFormCellViewModel(
            field: .email,
            value: $email,
            validation: result.validations[.email]))
      } header: {
        Text(L10n.tkNonComplianceReportFormReportSectionTitle)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .font(.custom.title2Emphasized)
          .accessibilityAddTraits(.isHeader)
      } footer: {
        Text(L10n.tkNonComplianceReportFormContactFooter)
      }
      .textCase(nil)
    }

    private func actorView(actorImage: Data?, actorName: String?) -> some View {
      Section {
        HStack(alignment: dynamicTypeSize.isAccessibilitySize ? .top : .center, spacing: .x4) {
          NormalizedLogoCircular(actorImage)
            .accessibilityHidden(true)
          Text(actorName ?? L10n.tkErrorNotregisteredTitle)
            .font(.custom.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
            .multilineTextAlignment(.leading)
            .accessibilityLabel(Text(actorName ?? L10n.tkErrorNotregisteredTitle))
        }
      } footer: {
        Text(L10n.tkNonComplianceReportFormActorFooter)
      }
    }

    private func button(isEnabled: Bool) -> some View {
      ButtonSheet(colorConfig: .secondary) {
        AsyncButton {
          await eventAction(.sendReport)
        } label: {
          Text(L10n.tkNonComplianceReportFormSendButton)
            .frame(maxWidth: .infinity)
        }
        .disabled(!isEnabled)
        .buttonStyle(.primary)
        .controlSize(.large)
      }
    }
  }
}

#if DEBUG
#Preview {
  NonComplianceFormView.Content(
    state: .Mock.resultValid,
    description: .constant("description"),
    email: .constant("email@example.com"))
}
#endif
