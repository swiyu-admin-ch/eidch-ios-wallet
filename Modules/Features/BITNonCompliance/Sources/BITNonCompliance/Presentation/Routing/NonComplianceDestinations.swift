import Factory
import NavigatorUI
import SwiftUI

public enum NonComplianceDestinations: NavigationDestination {
  case categories(activityId: UUID, credentialId: UUID)
  case info(category: NonComplianceCategory, activityId: UUID, credentialId: UUID)
  case form(category: NonComplianceCategory, activityId: UUID, credentialId: UUID)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .categories: .managedSheet
    case .form,
         .info: .push
    }
  }

  public var body: some View {
    switch self {
    case .categories(let activityId, let credendialId): NonComplianceCategorySelectionView(activityId: activityId, credentialId: credendialId)
    case .info(let category, let activityId, let credentialId):
      NonComplianceInfoView(category: category, activityId: activityId, credentialId: credentialId)
    case .form:
      #warning("Implemented in EIDNUCLEUS-442")
      EmptyView()
    }
  }
}
