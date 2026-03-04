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

  public var getActivityUseCase: Factory<GetActivityUseCaseProtocol> {
    self { GetActivityUseCase() }
  }

  public var deleteActivityUseCase: Factory<DeleteActivityUseCaseProtocol> {
    self { DeleteActivityUseCase() }
  }

  public var activityDetailViewProvider: Factory<(any NavigationViewProviding<ActivityExternalViews>)?> {
    self { nil }
  }

  public var isActivityHistoryEnabledUseCase: Factory<IsActivityHistoryEnabledUseCaseProtocol> {
    self { IsActivityHistoryEnabledUseCase() }
  }

  public var setActivityHistoryEnabledUseCase: Factory<SetActivityHistoryEnabledUseCaseProtocol> {
    self { SetActivityHistoryEnabledUseCase() }
  }

  public var deleteAllActivitiesUseCase: Factory<DeleteAllActivitiesUseCaseProtocol> {
    self { DeleteAllActivitiesUseCase() }
  }

  public var activityRepository: Factory<ActivityRepositoryProtocol> {
    self { ActivityRepository() }
  }

  // MARK: Internal

  @MainActor
  var activityListViewModel: ParameterFactory<UUID, ActivityListViewModel> {
    self { ActivityListViewModel($0) }
  }
}
