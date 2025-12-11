#if DEBUG
import Foundation
import SwiftUI

class MockValidateAttestationsViewModel: ValidateAttestationsViewModel {

  @MainActor
  override func fetchAttestations() async {
    destination = .legalRepresentant
  }

}
#endif
