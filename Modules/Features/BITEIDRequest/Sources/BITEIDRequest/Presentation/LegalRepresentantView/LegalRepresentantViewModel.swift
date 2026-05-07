import Factory
import SwiftUI

@MainActor
@Observable
class LegalRepresentantViewModel {

  // MARK: Internal

  var destination: EIDRequestDestinations?

  func action(_ value: Bool) {
    context.hasLegalRepresentant = value
    destination = .documentSelection
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.eidRequestContext) private var context

}
