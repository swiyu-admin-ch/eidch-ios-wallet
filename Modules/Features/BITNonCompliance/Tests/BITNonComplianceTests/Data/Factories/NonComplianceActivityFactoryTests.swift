import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITDataStore
@testable import BITEntities
@testable import BITNonCompliance

// MARK: - NonComplianceActivityFactoryTests

@MainActor
@Suite(.container)
struct NonComplianceActivityFactoryTests {

  // MARK: Lifecycle

  init() {
    Container.shared.configureInMemoryDataStore()
    factory = NonComplianceActivityFactory()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success() throws {
    let activityEntity = try CredentialActivityEntity.Mock.create(
      nonComplianceData: Self.nonComplianceDataMock,
      createdAt: Self.createdAtMock,
      issuer: Self.issuerMock,
      createParent: false)

    let activity = try factory(activityEntity)

    #expect(activity.nonComplianceData == Self.nonComplianceDataMock)
    #expect(activity.createdAt == Self.createdAtMock)
    #expect(activity.issuer == Self.issuerMock)
  }

  @Test
  func callAsFunction_noIssuer_throws() throws {
    let activity = try CredentialActivityEntity.Mock.create(createParent: false)

    #expect(throws: NonComplianceActivityFactoryError.issuerNotFound) {
      _ = try factory(activity)
    }
  }

  // MARK: Private

  private static let issuerMock = "issuer"
  private static let createdAtMock = Date()
  private static let nonComplianceDataMock = "nonComplianceData"

  private let factory: NonComplianceActivityFactory
}
