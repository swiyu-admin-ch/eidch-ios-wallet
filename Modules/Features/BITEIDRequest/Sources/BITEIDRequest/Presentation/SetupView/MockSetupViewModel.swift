#if DEBUG
import Foundation
import SwiftUI

@MainActor
class MockSetupViewModel: SetupViewModel {

  @MainActor
  override func fetchAttestations() async {
    destination = .legalRepresentant
  }

}
#endif
