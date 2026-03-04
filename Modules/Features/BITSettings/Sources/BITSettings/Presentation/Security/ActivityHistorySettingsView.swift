import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - ActivityHistorySettingsView

struct ActivityHistorySettingsView: View {

  // MARK: Lifecycle

  init() {
    _viewModel = StateObject(wrappedValue: Container.shared.activityHistorySettingsViewModel())
  }

  // MARK: Internal

  var body: some View {
    Content(
      isActivityHistoryEnabled: $viewModel.isActivityHistoryEnabled,
      isConfirmHistoryDisablingAlertPresented: $viewModel.isConfirmHistoryDisablingAlertPresented,
      isConfirmDeletionAlertPresented: $viewModel.isConfirmDeletionAlertPresented,
      isToastPresented: $viewModel.isToastPresented,
      toastType: viewModel.toastType,
      eventAction: { event in Task { await viewModel.send(event) } })
      .task {
        await viewModel.send(.onAppear)
      }
  }

  // MARK: Private

  @StateObject private var viewModel: ActivityHistorySettingsViewModel
}

// MARK: ActivityHistorySettingsView.Content

extension ActivityHistorySettingsView {
  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      isActivityHistoryEnabled: Binding<Bool>,
      isConfirmHistoryDisablingAlertPresented: Binding<Bool>,
      isConfirmDeletionAlertPresented: Binding<Bool>,
      isToastPresented: Binding<Bool>,
      toastType: ToastType,
      eventAction: @escaping (ActivityHistorySettingsViewModel.Event) -> Void = { _ in })
    {
      self.isActivityHistoryEnabled = isActivityHistoryEnabled
      self.isConfirmHistoryDisablingAlertPresented = isConfirmHistoryDisablingAlertPresented
      self.isConfirmDeletionAlertPresented = isConfirmDeletionAlertPresented
      self.isToastPresented = isToastPresented
      self.toastType = toastType
      self.eventAction = eventAction
    }

    // MARK: Internal

    var body: some View {
      SettingsPage(title: L10n.tkSettingsActivityHistoryTitle) {
        toggleHistorySection
          .alert(isPresented: isConfirmHistoryDisablingAlertPresented) {
            Alert(
              title: Text(L10n.tkSettingsActivityHistoryToggleHistoryConfirmationPrimary),
              message: Text(L10n.tkSettingsActivityHistoryToggleHistoryConfirmationSecondary),
              primaryButton: .default(Text(L10n.tkSettingsActivityHistoryToggleHistoryConfirmationButtonPrimary), action: { eventAction(.confirmHistoryDisabling) }),
              secondaryButton: .cancel(Text(L10n.tkGlobalCancel)))
          }

        deleteHistorySection
          .alert(isPresented: isConfirmDeletionAlertPresented) {
            Alert(
              title: Text(L10n.tkSettingsActivityHistoryDeletionConfirmationPrimary),
              message: Text(L10n.tkSettingsActivityHistoryDeletionConfirmationSecondary),
              primaryButton: .destructive(Text(L10n.tkGlobalDelete), action: { eventAction(.confirmDeletion) }),
              secondaryButton: .cancel(Text(L10n.tkGlobalCancel)))
          }
      }
      .toastMessage(
        isPresented: isToastPresented,
        message: toastType.message,
        type: toastType,
        clearAction: { eventAction(.clearToast) })
    }

    // MARK: Private

    private let isActivityHistoryEnabled: Binding<Bool>
    private let isConfirmHistoryDisablingAlertPresented: Binding<Bool>
    private let isConfirmDeletionAlertPresented: Binding<Bool>
    private let isToastPresented: Binding<Bool>
    private let toastType: ToastType
    private let eventAction: (ActivityHistorySettingsViewModel.Event) -> Void

    private var toggleHistorySection: some View {
      SettingsSection {
        SettingsItem(
          image: Assets.saveActivities.swiftUIImage,
          title: L10n.tkSettingsActivityHistoryToggleHistoryPrimary,
          detail: L10n.tkSettingsActivityHistoryToggleHistorySecondary,
          type: .toggle(isOn: isActivityHistoryEnabled) { eventAction(.toggleActivityHistory) },
          hasDivider: false)
      }
    }

    private var deleteHistorySection: some View {
      SettingsSection {
        SettingsItem(
          image: Assets.trash.swiftUIImage,
          title: L10n.tkSettingsActivityHistoryDeletionPrimary,
          type: .button(isDestructive: true) { eventAction(.deleteActivityHistory) },
          hasDivider: false)
      }
    }

  }
}

#Preview {
  ActivityHistorySettingsView.Content(
    isActivityHistoryEnabled: .constant(true),
    isConfirmHistoryDisablingAlertPresented: .constant(false),
    isConfirmDeletionAlertPresented: .constant(false),
    isToastPresented: .constant(false),
    toastType: .success)
}
