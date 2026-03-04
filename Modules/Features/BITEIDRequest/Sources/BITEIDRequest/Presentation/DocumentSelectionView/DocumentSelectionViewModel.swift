import AVFoundation
import BITEIDRequestShared
import BITNavigation
import Factory
import SwiftUI

class DocumentSelectionViewModel: ObservableObject {

  // MARK: Internal

  @Published var destination: EIDRequestDestinations?

  func didSelect(_ type: IdentityType) {
    context.identityType = type
    destination = .scanDocumentInformation(isBackEnabled: true)
  }

  func mrzMockData() {
    destination = .mrzMockData
  }

  // MARK: Private

  @Injected(\.eidRequestContext) private var context
}
