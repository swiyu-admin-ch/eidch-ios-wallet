import Factory
import Foundation
import Testing
@testable import BITActivity
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - ActivityPresentationTests

struct ActivityPresentationTests {

  // MARK: Internal

  enum RequestObjectKind: CaseIterable {
    case plain
    case jwt

    var activityType: ActivityType {
      switch self {
      case .plain: .presentationAccepted
      case .jwt: .presentationDeclined
      }
    }
  }

  @Test(arguments: RequestObjectKind.allCases)
  func init_mapsDataCorrectly(requestObject: RequestObjectKind) throws {
    let context = makeContext(requestObject)

    let activity = try Activity(context: context, credential: #require(context.selectedCredential), type: requestObject.activityType)

    assertActivity(
      activity,
      type: requestObject.activityType,
      verifierDisplays: context.verifierDisplays)
  }

  @Test
  func init_severalBundleItems_snapshotsThePresentedOne() throws {
    let credential = try makeCredential(presentedStatus: .revoked, otherStatus: .valid)
    let presented = try #require(credential.presentableBundleItem)

    let activity = Activity(context: contextMock, credential: CompatibleCredential(credential: credential, presentingPaths: []), type: .presentationAccepted)

    #expect(activity.bundleItem?.statusListState == .revoked)
    #expect(activity.bundleItem?.payload == presented.payload)
  }

  @Test
  func init_noPresentableBundleItem_snapshotsNoBundleItem() {
    var credential = VerifiableCredential.Mock.sample
    credential.bundleItems = []

    let activity = Activity(context: contextMock, credential: CompatibleCredential(credential: credential, presentingPaths: []), type: .presentationAccepted)

    #expect(activity.bundleItem == nil)
  }

  // MARK: Private

  private static let rawRequestObjectMock = Data("rawRequestObject".utf8)

  private let contextMock = PresentationRequestContext.Mock.vcSdJwtSample
  private let jwtContextMock = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.sample, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.trustedIdentity)

  private func makeContext(_ kind: RequestObjectKind) -> PresentationRequestContext {
    switch kind {
    case .plain:
      contextMock.requestObject.raw = Self.rawRequestObjectMock
      return contextMock
    case .jwt:
      return jwtContextMock
    }
  }

  private func makeCredential(presentedStatus: CredentialStatus, otherStatus: CredentialStatus) throws -> VerifiableCredential {
    var credential = VerifiableCredential.Mock.sample
    var presented = try #require(credential.presentableBundleItem)
    presented.status = presentedStatus
    let other = BundleItem(payload: Data("other-token".utf8), status: otherStatus)
    credential.bundleItems = [other, presented]
    return credential
  }

  private func assertActivity(_ activity: Activity, type: ActivityType, verifierDisplays: [VerifierDisplay]) {
    #expect(activity.type == type)
    #expect(activity.actorTrust == .trusted)
    #expect(activity.vcSchemaTrust == .notProtected)

    #expect(activity.claims.count == 2)
    let paths = activity.claims.map(\.path)
    #expect(paths.contains("[\"firstName\"]"))
    #expect(paths.contains("[\"lastName\"]"))

    #expect(activity.actorDisplays.count == verifierDisplays.count)
    for display in activity.actorDisplays {
      guard let verifierDisplay = verifierDisplays.first(where: { $0.locale == display.locale }) else {
        Issue.record("Missing verifier display for locale \(String(describing: display.locale))")
        continue
      }
      #expect(display.name == verifierDisplay.name)
      #expect(display.image == verifierDisplay.logo)
    }
  }
}
