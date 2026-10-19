import Foundation
import Testing
@testable import BITActivity
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// MARK: - ActivityIssuanceTests

struct ActivityIssuanceTests {

  // MARK: Internal

  @Test
  func init_mapsDataCorrectly() throws {
    let activity = Activity(credential: credentialMock, trustInformation: trustInformationMock, actorCompliance: .compliant)

    #expect(activity.type == .issuance)
    #expect(activity.actorTrust == .trusted)
    #expect(activity.vcSchemaTrust == .trusted)
    #expect(activity.nonComplianceData == nil)

    #expect(activity.actorDisplays.count == credentialMock.issuerDisplays.count)
    for display in activity.actorDisplays {
      let issuerDisplay = try #require(credentialMock.issuerDisplays.first { $0.locale == display.locale })
      #expect(display.name == issuerDisplay.name)
      #expect(display.image == issuerDisplay.image)
    }
  }

  @Test
  func init_severalBundleItems_snapshotsThePresentableOne() throws {
    var credential = credentialMock
    var presentable = try #require(credential.presentableBundleItem)
    presentable.status = .suspended
    credential.bundleItems = [BundleItem(payload: Data("other-token".utf8), status: .valid), presentable]

    let activity = Activity(credential: credential, trustInformation: trustInformationMock, actorCompliance: .compliant)

    #expect(activity.bundleItem?.statusListState == .suspended)
    #expect(activity.bundleItem?.payload == presentable.payload)
  }

  @Test
  func init_noPresentableBundleItem_snapshotsNoBundleItem() {
    var credential = credentialMock
    credential.bundleItems = []

    let activity = Activity(credential: credential, trustInformation: trustInformationMock, actorCompliance: .compliant)

    #expect(activity.bundleItem == nil)
  }

  // MARK: Private

  private let credentialMock = VerifiableCredential.Mock.sample
  private let trustInformationMock = TrustInformation.Mock.fullyTrusted
}
