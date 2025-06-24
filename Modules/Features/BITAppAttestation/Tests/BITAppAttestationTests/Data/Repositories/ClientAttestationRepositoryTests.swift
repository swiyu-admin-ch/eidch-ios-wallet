// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import RealmSwift
import XCTest
@testable import BITAppAttestation

final class ClientAttestationRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.realmDataStoreConfiguration.register { Realm.Configuration(inMemoryIdentifier: "inMemory") }
    repository = ClientAttestationRepository()
  }

  func testCreate_success() async throws {
    let result = try await repository.create(mockClientAttestation)
    XCTAssertEqual(result, mockClientAttestation)
  }

  func testGetClientAttestation_success() async throws {
    let result = try await repository.create(mockClientAttestation)
    let clientAttestation = try await repository.getClientAttestation()

    XCTAssertEqual(result, clientAttestation)
  }

  func testGetClientAttestation_noClientAttestation_throwsError() async throws {
    do {
      _ = try await repository.getClientAttestation()
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? ClientAttestationRepositoryError, .notFound)
    }
  }

  // MARK: Private

  private let mockClientAttestation = ClientAttestationPayload.Mock.sample
  private var repository: ClientAttestationRepositoryProtocol!
}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
