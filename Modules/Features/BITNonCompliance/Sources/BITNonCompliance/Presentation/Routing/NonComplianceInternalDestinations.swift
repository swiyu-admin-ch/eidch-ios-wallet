import BITTheming
import NavigatorUI
import SwiftUI

enum NonComplianceInternalDestinations: NavigationDestination {
  case info(category: NonComplianceCategory, activityId: UUID)
  case form(category: NonComplianceCategory, activityId: UUID)
  case description(value: String)
  case error(dataset: ErrorDataset)

  // MARK: Internal

  var method: NavigationMethod {
    .push
  }

  var body: some View {
    switch self {
    case .info(let category, let activityId):
      NonComplianceInfoView(category: category, activityId: activityId)
    case .form(let category, let activityId):
      NonComplianceFormView(category: category, activityId: activityId)
    case .description(let initialValue):
      NonComplianceDescriptionView(initialValue: initialValue)
    case .error(let dataset):
      ErrorView(dataset: dataset)
    }
  }
}
