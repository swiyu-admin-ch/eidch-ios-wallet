import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// swiftlint: disable implicitly_unwrapped_optional force_unwrapping

final class RotateNextPresentableBundleItemUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    credentialRepository = CredentialRepositoryProcotolSpy()
    Container.shared.credentialRepository.register { self.credentialRepository }
    useCase = RotateNextPresentableBundleItemUseCase()
  }

  func testCallAsFunction_setsCurrentItemPresentedAndAdvancesToNextUnpresentedItem() async throws {
    let firstBundleItem = BundleItem(payload: Data("first".utf8))
    let secondBundleItem = BundleItem(payload: Data("second".utf8))
    let thirdBundleItem = BundleItem(payload: Data("third".utf8), presented: true)
    let credential = credential(
      bundleItems: [firstBundleItem, secondBundleItem, thirdBundleItem],
      nextPresentableBundleItemId: firstBundleItem.id)

    credentialRepository.updateVerifiableCredentialReturnValue = credential

    _ = try await useCase(credential)

    let updatedCredential = try XCTUnwrap(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential)
    XCTAssertTrue(updatedCredential.bundleItems[0].presented)
    XCTAssertEqual(updatedCredential.nextPresentableBundleItemId, secondBundleItem.id)
  }

  func testCallAsFunction_wrapsToEarlierUnpresentedItemWhenNeeded() async throws {
    let firstBundleItem = BundleItem(payload: Data("first".utf8))
    let secondBundleItem = BundleItem(payload: Data("second".utf8))
    let thirdBundleItem = BundleItem(payload: Data("third".utf8), presented: true)
    let credential = credential(
      bundleItems: [firstBundleItem, secondBundleItem, thirdBundleItem],
      nextPresentableBundleItemId: secondBundleItem.id)

    credentialRepository.updateVerifiableCredentialReturnValue = credential

    _ = try await useCase(credential)

    let updatedCredential = try XCTUnwrap(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential)
    XCTAssertTrue(updatedCredential.bundleItems[1].presented)
    XCTAssertEqual(updatedCredential.nextPresentableBundleItemId, firstBundleItem.id)
  }

  func testCallAsFunction_allItemsAlreadyPresented_keepsSelectingRandomExistingBundleItem() async throws {
    let firstBundleItem = BundleItem(payload: Data("first".utf8), presented: true)
    let secondBundleItem = BundleItem(payload: Data("second".utf8), presented: true)
    let credential = credential(
      bundleItems: [firstBundleItem, secondBundleItem],
      nextPresentableBundleItemId: firstBundleItem.id)

    credentialRepository.updateVerifiableCredentialReturnValue = credential

    _ = try await useCase(credential)

    let updatedCredential = try XCTUnwrap(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential)
    XCTAssertTrue(updatedCredential.bundleItems[0].presented)
    XCTAssertTrue([firstBundleItem.id, secondBundleItem.id].contains(updatedCredential.nextPresentableBundleItemId))
  }

  func testCallAsFunction_missingCurrentBundleItem_throwsNoBundleItem() async {
    let bundleItem = BundleItem(payload: Data("first".utf8))
    let credential = credential(
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: UUID())

    await XCTAssertThrowsErrorAsync(try await useCase(credential)) { error in
      XCTAssertEqual(error as? CredentialError, .noBundleItem)
      XCTAssertFalse(self.credentialRepository.updateVerifiableCredentialCalled)
    }
  }

  func testCallAsFunction_updateFails_rethrowsError() async {
    let bundleItem = BundleItem(payload: Data("first".utf8))
    let credential = credential(
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: bundleItem.id)
    credentialRepository.updateVerifiableCredentialThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase(credential)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: RotateNextPresentableBundleItemUseCase!
  private var credentialRepository: CredentialRepositoryProcotolSpy!

  private func credential(bundleItems: [BundleItem], nextPresentableBundleItemId: UUID) -> VerifiableCredential {
    VerifiableCredential(
      bundleItems: bundleItems,
      nextPresentableBundleItemId: nextPresentableBundleItemId,
      format: "format",
      issuerUrl: "https://issuer",
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
  }
}
