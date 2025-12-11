import Factory
import SwiftUI

@MainActor
class LegalRepresentantViewModel: ObservableObject {

  // MARK: Internal

  @Published var destination: EIDRequestDestinations?

  func action(_ value: Bool) {
    context.hasLegalRepresentant = value
    destination = .documentSelection
  }

  // MARK: Private

  @Injected(\.eidRequestContext) private var context

}
