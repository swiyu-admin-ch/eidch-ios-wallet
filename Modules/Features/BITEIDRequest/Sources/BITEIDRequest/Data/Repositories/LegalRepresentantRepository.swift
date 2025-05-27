import Foundation
import Spyable

// MARK: - LegalRepresentantRepositoryProcotol

@Spyable
protocol LegalRepresentantRepositoryProcotol {
  func set(_ value: Bool)
  func get() -> Bool
}

// MARK: - LegalRepresentantRepository

class LegalRepresentantRepository: LegalRepresentantRepositoryProcotol {

  // MARK: Internal

  func set(_ value: Bool) {
    hasLegalRepresentant = value
  }

  func get() -> Bool {
    hasLegalRepresentant
  }

  // MARK: Private

  private var hasLegalRepresentant = false

}
