import BITActivity
import Factory
import Foundation

extension Container {

  @MainActor
  var activityDetailViewModel: ParameterFactory<(Activity, UUID), ActivityDetailViewModel> {
    self { ActivityDetailViewModel($0, credentialId: $1) }
  }
}
