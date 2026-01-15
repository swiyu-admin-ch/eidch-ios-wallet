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

  // MARK: Internal

  var activityRepository: Factory<ActivityRepositoryProtocol> {
    self { ActivityRepository() }
  }

  @MainActor
  var activityListViewModel: ParameterFactory<UUID, ActivityListViewModel> {
    self { ActivityListViewModel($0) }
  }
}
