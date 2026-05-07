import XCTest
@testable import BITCredential
@testable import BITCredentialShared

final class SelectCredentialBundleItemUseCaseTests: XCTestCase {

  // MARK: Internal

  func testCallAsFunction_containsUnpresentedItem_returnsFirstUnpresentedItem() throws {
    let firstPresentedItem = BundleItem(payload: Data("first".utf8), presented: true)
    let firstUnpresentedItem = BundleItem(payload: Data("second".utf8), presented: false)
    let secondUnpresentedItem = BundleItem(payload: Data("third".utf8), presented: false)
    let credential = VerifiableCredential(
      bundleItems: [firstPresentedItem, firstUnpresentedItem, secondUnpresentedItem],
      nextPresentableBundleItemId: firstUnpresentedItem.id,
      format: "format",
      issuerUrl: "https://issuer",
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    let result = try useCase(credential)

    XCTAssertEqual(result, firstUnpresentedItem)
  }

  func testCallAsFunction_allItemsPresented_returnsFirstItem() throws {
    let firstPresentedItem = BundleItem(payload: Data("first".utf8), presented: true)
    let secondPresentedItem = BundleItem(payload: Data("second".utf8), presented: true)
    let credential = VerifiableCredential(
      bundleItems: [firstPresentedItem, secondPresentedItem],
      nextPresentableBundleItemId: firstPresentedItem.id,
      format: "format",
      issuerUrl: "https://issuer",
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    let result = try useCase(credential)

    XCTAssertEqual(result, firstPresentedItem)
  }

  func testCallAsFunction_noItems_throwsNoBundleItem() {
    let credential = VerifiableCredential(
      bundleItems: [],
      nextPresentableBundleItemId: UUID(),
      format: "format",
      issuerUrl: "https://issuer",
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    XCTAssertThrowsError(try useCase(credential)) { error in
      XCTAssertEqual(error as? CredentialError, .noBundleItem)
    }
  }

  // MARK: Private

  private let useCase: SelectCredentialBundleItemUseCaseProtocol = SelectCredentialBundleItemUseCase()
}
