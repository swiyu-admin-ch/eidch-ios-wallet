import BITEntities
import Foundation


public struct EIDRequestStatus: Decodable, Equatable {
  let state: State
  let onlineSessionStartCloseAt: Date?
  let queueInformation: QueueInformation?
  let legalRepresentant: LegalRepresentant?

  private enum CodingKeys: String, CodingKey {
    case state
    case queueInformation
    case legalRepresentant
    case onlineSessionStartCloseAt = "onlineSessionStartTimeout"
  }
}

extension EIDRequestStatus {

  // MARK: Public

  public enum State: String, Decodable {
    case inQueue = "IN_QUEUING"
    case readyForOnlineSession = "READY_FOR_ONLINE_SESSION"
    case inTargetWalletPairing = "IN_TARGET_WALLET_PAIRING"
    case inAutoVerification = "IN_AUTO_VERIFICATION"
    case readyForEntitlementCheck = "READY_FOR_FINAL_ENTITLEMENT_CHECK"
    case inIssuing = "IN_ISSUANCE"
    case denied = "REFUSED"
    case cancelled = "CANCELLED"
    case expired = "TIMEOUT"
    case closed = "CLOSED"
    case unknown = "UNKNOWN"

    // MARK: Lifecycle

    init(_ state: EIDRequestStatusStateEntity) {
      switch state {
      case .inQueue:
        self = .inQueue
      case .readyForOnlineSession:
        self = .readyForOnlineSession
      case .inTargetWalletPairing:
        self = .inTargetWalletPairing
      case .inAutoVerification:
        self = .inAutoVerification
      case .readyForEntitlementCheck:
        self = .readyForEntitlementCheck
      case .inIssuing:
        self = .inIssuing
      case .denied:
        self = .denied
      case .cancelled:
        self = .cancelled
      case .expired:
        self = .expired
      case .closed:
        self = .closed
      case .unknown:
        self = .unknown
      }
    }
  }

  // MARK: Internal

  struct QueueInformation: Decodable, Equatable {
    let onlineSessionStartOpenAt: Date

    private let position: Int
    private let total: Int

    private enum CodingKeys: String, CodingKey {
      case onlineSessionStartOpenAt = "expectedOnlineSessionStart"
      case position = "positionInQueue"
      case total = "totalInQueue"
    }
  }

  struct LegalRepresentant: Decodable, Equatable {
    let isVerified: Bool
    private let verificationLink: String

    private enum CodingKeys: String, CodingKey {
      case isVerified = "verified"
      case verificationLink
    }
  }
}
