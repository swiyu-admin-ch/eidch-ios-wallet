import BITActivity
import Factory
import Foundation

extension Container {

  @MainActor
  var activityDetailViewModel: ParameterFactory<UUID, ActivityDetailViewModel> {
    self { @MainActor in ActivityDetailViewModel($0) }
  }
}
