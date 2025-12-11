import SwiftUI

class AVWelcomeViewModel: ObservableObject {

  @Published var destination: EIDRequestDestinations?

  func primaryAction() {
    destination = .walletPairing
  }
}
