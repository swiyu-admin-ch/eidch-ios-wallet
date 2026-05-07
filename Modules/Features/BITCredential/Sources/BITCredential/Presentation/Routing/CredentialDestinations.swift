import BITCredentialShared
import NavigatorUI
import SwiftUI

public enum CredentialDestinations: NavigationDestination {
  case detail(CredentialDetailInput)
  case wrongData

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .detail,
         .wrongData: .managedSheet
    }
  }

  public var body: some View {
    switch self {
    case .detail(let input):
      CredentialDetailView(credential: input.credential)
    case .wrongData:
      CredentialDetailWrongDataView()
    }
  }
}
