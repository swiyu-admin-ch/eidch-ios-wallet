import AVFoundation
import BITEIDRequestShared
import BITNavigation
import Factory
import SwiftUI

@Observable
class DocumentSelectionViewModel {

  // MARK: Internal

  var destination: EIDRequestDestinations?

  func didSelect(_ type: IdentityType) {
    context.identityType = type
    destination = .scanDocumentInformation(isBackEnabled: true)
  }

  func mrzMockData() {
    destination = .mrzMockData
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.eidRequestContext) private var context
}
