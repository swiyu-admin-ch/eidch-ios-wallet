// swiftlint: disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITDataStore
@testable import BITEntities
@testable import BITNonCompliance

final class NonComplianceActivityFactoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    Container.shared.configureInMemoryDataStore()
    factory = NonComplianceActivityFactory()
  }

  func testCallAsFunction_success() throws {
    let activityEntity = try CredentialActivityEntity.Mock.create(nonComplianceData: Self.nonComplianceDataMock, createdAt: Self.createdAtMock, createParent: false)
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create(issuer: Self.issuerMock)
    _ = try CredentialEntity.Mock.create(verifiableCredential: verifiableCredential, activities: [activityEntity])

    let activity = try factory(activityEntity)

    XCTAssertEqual(activity.nonComplianceData, Self.nonComplianceDataMock)
    XCTAssertEqual(activity.createdAt, Self.createdAtMock)
    XCTAssertEqual(activity.issuer, Self.issuerMock)
  }

  func testCallAsFunction_noCredential_throwsError() throws {
    let activity = try CredentialActivityEntity.Mock.create(createParent: false)

    XCTAssertThrowsError(try factory(activity)) { error in
      XCTAssertEqual(error as? NonComplianceActivityFactoryError, .credentialNotFound)
    }
  }

  func testCallAsFunction_noVerifiableCredential_throwsError() throws {
    let activity = try CredentialActivityEntity.Mock.create(createParent: false)
    _ = try CredentialEntity.Mock.create(verifiableCredential: nil, activities: [activity])

    XCTAssertThrowsError(try factory(activity)) { error in
      XCTAssertEqual(error as? NonComplianceActivityFactoryError, .credentialNotFound)
    }
  }

  // MARK: Private

  private static let issuerMock = "issuer"
  private static let createdAtMock = Date()
  private static let nonComplianceDataMock = "nonComplianceData"

  private var factory: NonComplianceActivityFactory!
}
