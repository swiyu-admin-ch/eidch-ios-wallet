import BITL10n
import BITTheming
import Factory
import SwiftUI
import UIKit

// MARK: - PushPermissionView

public struct PushPermissionView: View {

  // MARK: Lifecycle

  public init(
    permissionNotDeterminedTitle: String,
    permissionNotDeterminedBody: String,
    permissionDeniedTitle: String,
    permissionDeniedBody: String,
    primaryButtonNotDeterminatedTitle: String,
    primaryButtonDeniedTitle: String,
    onSkipAction: @escaping () -> Void,
    onErrorAction: @escaping () -> Void,
    onGrantPermissionAction: @escaping () -> Void,
    onDeniedPermissionAction: @escaping () -> Void,
    onCloseAction: @escaping () -> Void)
  {
    self.permissionNotDeterminedTitle = permissionNotDeterminedTitle
    self.permissionNotDeterminedBody = permissionNotDeterminedBody
    self.permissionDeniedTitle = permissionDeniedTitle
    self.permissionDeniedBody = permissionDeniedBody
    self.primaryButtonDeniedTitle = primaryButtonDeniedTitle
    self.primaryButtonNotDeterminatedTitle = primaryButtonNotDeterminatedTitle
    self.onSkipAction = onSkipAction
    self.onDeniedPermissionAction = onDeniedPermissionAction
    self.onCloseAction = onCloseAction

    _viewModel = State(initialValue: Container.shared.pushPermissionViewModel((onGrantPermissionAction, onErrorAction)))
  }

  // MARK: Public

  public var body: some View {
    VStack {
      if viewModel.isLoading {
        ProgressView()
          .accessibilityHidden(true)
      } else {
        informationView
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onAppear {
      Task {
        await viewModel.refreshPermissionStatus()
      }
    }
    .toolbar { CloseButtonToolbar(action: onCloseAction) }
    .navigationBarBackButtonHidden()
  }

  // MARK: Private

  @State private var viewModel: PushPermissionViewModel

  private let onSkipAction: () -> Void
  private let onCloseAction: () -> Void
  private let onDeniedPermissionAction: () -> Void

  private let permissionNotDeterminedTitle: String
  private let permissionNotDeterminedBody: String
  private let permissionDeniedTitle: String
  private let permissionDeniedBody: String
  private let primaryButtonDeniedTitle: String
  private let primaryButtonNotDeterminatedTitle: String

  private var informationView: some View {
    InformationView2(
      image: image,
      contents: [
        .title(title),
        .body(content),
      ],
      actions: [
        .primaryAsync(primaryButtonTitle) { _ in
          if viewModel.permissionStatus == .denied {
            return onDeniedPermissionAction()
          }

          await viewModel.requestPermission()
        },
        .secondary(L10n.tkPushNotificationPermissionSecondaryButton, { _ in
          onSkipAction()
        }),
      ])
  }
}

extension PushPermissionView {

  private var image: Image {
    switch viewModel.permissionStatus {
    case .denied:
      Image(decorative: Assets.alarmOff)
    default:
      Image(decorative: Assets.alarm)
    }
  }

  private var title: String {
    switch viewModel.permissionStatus {
    case .denied:
      permissionDeniedTitle
    default:
      permissionNotDeterminedTitle
    }
  }

  private var content: String {
    switch viewModel.permissionStatus {
    case .denied:
      permissionDeniedBody
    default:
      permissionNotDeterminedBody
    }
  }

  private var primaryButtonTitle: String {
    switch viewModel.permissionStatus {
    case .denied:
      primaryButtonDeniedTitle
    default:
      primaryButtonNotDeterminatedTitle
    }
  }
}
