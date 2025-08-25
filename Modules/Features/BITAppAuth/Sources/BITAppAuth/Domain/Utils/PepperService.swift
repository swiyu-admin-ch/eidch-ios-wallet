import BITCrypto
import Factory
import Foundation

struct PepperService: PepperServiceProtocol {

  // MARK: Lifecycle

  init(
    pepperKeyInitialVectorLength: Int = Container.shared.pepperKeyInitialVectorLength(),
    pepperRepository: PepperRepositoryProtocol = Container.shared.pepperRepository())
  {
    self.pepperKeyInitialVectorLength = pepperKeyInitialVectorLength
    self.pepperRepository = pepperRepository
  }

  // MARK: Internal

  func generatePepper() throws -> SecKey {
    try generateInitialVector()
    return try pepperRepository.createPepperKey()
  }

  // MARK: Private

  private let pepperKeyInitialVectorLength: Int
  private let pepperRepository: PepperRepositoryProtocol

  private func generateInitialVector() throws {
    let initialVector = try Data.random(length: pepperKeyInitialVectorLength)
    try pepperRepository.setPepperInitialVector(initialVector)
  }

}
