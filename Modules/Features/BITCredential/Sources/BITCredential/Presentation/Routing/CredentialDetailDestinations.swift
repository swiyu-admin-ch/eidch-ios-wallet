import NavigatorUI
import SwiftUI

enum CredentialDetailDestinations: NavigationDestination {
  case wrongData

  // MARK: Internal

  var method: NavigationMethod {
    switch self {
    case .wrongData: .managedSheet
    }
  }

  var body: some View {
    switch self {
    case .wrongData:
      CredentialDetailWrongDataView()
    }
  }
}
