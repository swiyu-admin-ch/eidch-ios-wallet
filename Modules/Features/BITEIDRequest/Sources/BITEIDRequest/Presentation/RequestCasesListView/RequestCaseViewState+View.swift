import BITL10n
import SwiftUI

extension RequestCaseViewState {

  @ViewBuilder
  func view() -> some View {
    switch self {
    case .agentReview(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent)
    case .readyForFinalEntitlementCheck(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent)
    case .issuing(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent)
    case .inQueue(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent,
        notificationType: viewModel.notificationType)
    case .readyForOnlineSession(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent,
        notificationType: .primary(
          label: viewModel.primaryActionLabel,
          action: viewModel.primaryAction))
    case .expired(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent,
        notificationType: .dismiss {
          Task {
            await viewModel.primaryAction()
          }
        })
    case .refused(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationTitle,
        notificationType: .complete(
          label: viewModel.primaryActionLabel,
          action: viewModel.openFAQ,
          dismissAction: {
            Task {
              await viewModel.deleteRequestCase()
            }
          }))
    case .unknown(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent,
        notificationType: .primary(label: viewModel.primaryActionLabel, action: {
          Task {
            await viewModel.primaryAction()
          }
        }, style: .bezeled))
    case .walletPairing(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent,
        notificationType: .primary(
          label: viewModel.primaryActionLabel,
          action: viewModel.primaryAction))
    case .autoVerification(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent,
        notificationType: viewModel.filesSubmitted ? .default : .primary(label: viewModel.primaryActionLabel, action: viewModel.primaryAction))
    case .closed(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationContent,
        notificationType: .dismiss {
          Task {
            await viewModel.primaryAction()
          }
        })
    case .cancelled(let viewModel):
      RequestCaseNotificationView(
        title: viewModel.notificationTitle,
        content: viewModel.notificationTitle,
        notificationType: .complete(
          label: viewModel.primaryActionLabel,
          action: viewModel.openFAQ,
          dismissAction: {
            Task {
              await viewModel.deleteRequestCase()
            }
          }))
    }
  }
}
