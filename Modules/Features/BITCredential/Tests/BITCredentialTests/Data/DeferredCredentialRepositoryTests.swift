import XCTest
@testable import BITCredential
@testable import BITCredentialShared

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class DeferredCredentialRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    repository = DeferredCredentialRepository()
  }

  func testCreate_success() async throws {
    let deferredCredential = try await repository.create(mockDeferredCredential)
    let savedDeferredCredential = try await repository.get(id: UUID(uuidString: deferredCredential.transactionId)!)

    XCTAssertEqual(deferredCredential, savedDeferredCredential)
  }

  // MARK: Private

  private let mockDeferredCredential = DeferredCredential.Mock.sample
  private var repository: DeferredCredentialRepository!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
