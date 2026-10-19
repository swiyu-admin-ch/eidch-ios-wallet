import BITOpenID
import Foundation
import Spyable

// MARK: - ProximityPresentationRepositoryProtocol

@Spyable
public protocol ProximityPresentationRepositoryProtocol: AnyObject, Sendable {
  func startEngagement() -> AsyncThrowingStream<ProximityEngagementUpdate, Error>
  func startEngagementReverse(qrCode: String) -> AsyncThrowingStream<ProximityEngagementUpdate, Error>
  func submit(authorizationResponse: AuthorizationResponse) -> AsyncThrowingStream<ProximitySubmissionEvent, Error>
  func decline()
}
