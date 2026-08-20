import Foundation
import Testing
@testable import BITAnyCredentialFormat
@testable import BITCredentialShared

struct CredentialDisplayOrderTests {

  // MARK: Internal

  @Test
  func displayOrder_unacceptedVerifiableCredential_isReadyForActivation() {
    let credential = makeVerifiable(progressionState: .unaccepted)

    #expect(credential.displayOrder == .readyForActivation)
  }

  @Test
  func displayOrder_acceptedValidStatus_isActive() {
    let credential = makeVerifiable(progressionState: .accepted, status: .valid)

    #expect(credential.displayOrder == .active)
  }

  @Test
  func displayOrder_acceptedNotYetValidStatus_isInProgress() {
    let credential = makeVerifiable(progressionState: .accepted, status: .notYetValid)

    #expect(credential.displayOrder == .inProgress)
  }

  @Test(arguments: [CredentialStatus.unknown, .unsupported])
  func displayOrder_acceptedGhostStatus_isGhost(status: CredentialStatus) {
    let credential = makeVerifiable(progressionState: .accepted, status: status)

    #expect(credential.displayOrder == .ghost)
  }

  @Test(arguments: [CredentialStatus.businessExpired, .expired, .revoked, .suspended])
  func displayOrder_acceptedRejectedStatus_isRejected(status: CredentialStatus) {
    let credential = makeVerifiable(progressionState: .accepted, status: status)

    #expect(credential.displayOrder == .rejected)
  }

  @Test
  func displayOrder_inProgressDeferredCredential_isInProgress() {
    let credential = makeDeferred(progressionState: .inProgress)

    #expect(credential.displayOrder == .inProgress)
  }

  @Test(arguments: [DeferredCredential.ProgressionState.invalid, .issuanceFailed])
  func displayOrder_failedDeferredCredential_isRejected(state: DeferredCredential.ProgressionState) {
    let credential = makeDeferred(progressionState: state)

    #expect(credential.displayOrder == .rejected)
  }

  // MARK: Private

  // swiftlint:disable force_unwrapping
  private let issuerUrl = URL(string: "https://issuer.domain.ch")!

  // swiftlint:enable force_unwrapping

  private func makeVerifiable(
    progressionState: VerifiableCredential.ProgressState,
    status: CredentialStatus = .valid)
    -> VerifiableCredential
  {
    let bundleItemId = UUID()
    return VerifiableCredential(
      progressionState: progressionState,
      bundleItems: [BundleItem(id: bundleItemId, payload: Data("payload".utf8), status: status)],
      nextPresentableBundleItemId: bundleItemId,
      format: .vcSdJwt,
      issuerUrl: issuerUrl,
      issuer: "did:example:123",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
  }

  private func makeDeferred(
    progressionState: DeferredCredential.ProgressionState)
    -> DeferredCredential
  {
    DeferredCredential(
      transactionId: "transactionId",
      progressionState: progressionState,
      endpoint: "https://endpoint",
      format: .vcSdJwt,
      issuerUrl: issuerUrl,
      authentication: CredentialAuthentication(accessToken: "accessToken"))
  }
}
