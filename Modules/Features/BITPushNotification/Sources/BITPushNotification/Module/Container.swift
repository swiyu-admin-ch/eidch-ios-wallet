import Factory
import UserNotifications

extension Container {

  // MARK: Public

  public var requestPushPermissionUseCase: Factory<RequestPushPermissionUseCaseProtocol> {
    self { RequestPushPermissionUseCase() }
  }

  public var getPushPermissionStatusUseCase: Factory<GetPushPermissionStatusUseCaseProtocol> {
    self { GetPushPermissionStatusUseCase() }
  }

  public var deletePushIdUseCase: Factory<DeletePushIdUseCaseProtocol> {
    self { DeletePushIdUseCase() }
  }

  public var pushNotificationUrl: Factory<URL> {
    self {
      guard let url = URL(string: "https://push-api.trust-infra.swiyu.admin.ch") else {
        fatalError("No valid Push notification service URL")
      }
      return url
    }
  }

  public var pushNotificationRepository: Factory<PushNotificationRepositoryProtocol> {
    self { PushNotificationRepository() }
  }

  public var pushTokenRepository: Factory<PushTokenRepositoryProtocol> {
    self { PushTokenRepository() }
  }

  public var pushDataSource: Factory<PushDataSourceProtocol> {
    self { PushDataSource() }.singleton
  }

  public var notificationLocalizationService: Factory<NotificationLocalizationServiceProtocol> {
    self { NotificationLocalizationService() }
  }

  // MARK: Internal

  var pushNotificationCenterRepository: Factory<PushNotificationCenterRepositoryProtocol> {
    self { UNUserNotificationCenter.current() }
  }

  var pushPermissionViewModel: ParameterFactory<(() -> Void, () -> Void), PushPermissionViewModel> {
    self { @MainActor in PushPermissionViewModel(onGrantedAction: $0, onErrorAction: $1) }
  }
}
