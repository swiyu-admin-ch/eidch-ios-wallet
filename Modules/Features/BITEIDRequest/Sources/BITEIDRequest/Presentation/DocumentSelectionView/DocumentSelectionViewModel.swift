import AVFoundation
import BITEIDRequestShared
import BITNavigation
import Factory
import SwiftUI

class DocumentSelectionViewModel: ObservableObject, NavigationClosable {

  // MARK: Internal

  @Published var isNavigationCloseTriggered = false
  @Published var destination: EIDRequestDestinations?

  func didSelect(_ type: IdentityType) {
    context.identityType = type
    destination = .scanDocument
  }

  func mrzMockData() {
    destination = .mrzMockData
  }

  // MARK: Private

  @Injected(\.eidRequestContext) private var context
}
