import Factory
import Foundation
import NavigatorUI

extension Container {

  // MARK: Public

  public var activityService: Factory<ActivityServiceProtocol> {
    self { ActivityService() }
  }

  public var getCredentialActivitiesUseCase: Factory<GetCredentialActivitiesUseCaseProtocol> {
    self { GetCredentialActivitiesUseCase() }
  }

  public var getActivityDetailUseCase: Factory<GetActivityDetailUseCaseProtocol> {
    self { GetActivityDetailUseCase() }
  }

  public var deleteActivityUseCase: Factory<DeleteActivityUseCaseProtocol> {
    self { DeleteActivityUseCase() }
  }

  public var activityExternalViewProvider: Factory<(any NavigationViewProviding<ActivityExternalViews>)?> {
    self { nil }
  }

  public var getActivityHistoryEnabledSubjectUseCase: Factory<GetActivityHistoryEnabledSubjectUseCaseProtocol> {
    self { GetActivityHistoryEnabledSubjectUseCase() }
  }

  public var setActivityHistoryEnabledUseCase: Factory<SetActivityHistoryEnabledUseCaseProtocol> {
    self { SetActivityHistoryEnabledUseCase() }
  }

  public var deleteAllActivitiesUseCase: Factory<DeleteAllActivitiesUseCaseProtocol> {
    self { DeleteAllActivitiesUseCase() }
  }

  public var activityRepository: Factory<ActivityRepositoryProtocol> {
    self { ActivityRepository() }.cached
  }

  public var activityActorDisplayFactory: Factory<ActivityActorDisplayFactoryProtocol> {
    self { ActivityActorDisplayFactory() }
  }

  public var activityDetailFactory: Factory<ActivityDetailFactoryProtocol> {
    self { ActivityDetailFactory() }
  }

  public var activityListItemFactory: Factory<ActivityListItemFactoryProtocol> {
    self { ActivityListItemFactory() }
  }

  // MARK: Internal

  @MainActor
  var activityListViewModel: ParameterFactory<UUID, ActivityListViewModel> {
    self { @MainActor in ActivityListViewModel($0) }
  }

  var activityDetailCredentialFactory: Factory<ActivityDetailCredentialFactoryProtocol> {
    self { ActivityDetailCredentialFactory() }
  }

  var nonComplianceReasonDisplayFactory: Factory<NonComplianceReasonDisplayFactoryProtocol> {
    self { NonComplianceReasonDisplayFactory() }
  }
}
