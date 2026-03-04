#if DEBUG
import Foundation
import SwiftUI

class MockSetupViewModel: SetupViewModel {

  @MainActor
  override func fetchAttestations() async {
    destination = .legalRepresentant
  }

}
#endif
