import BITEntities
import Foundation


public struct EIDRequestStatus: Decodable, Equatable {
  public let state: State
  public let onlineSessionStartCloseAt: Date?
  public let queueInformation: QueueInformation?
  public let legalRepresentant: LegalRepresentant?
  public let targetWallets: TargetWallet?

  private enum CodingKeys: String, CodingKey {
    case state
    case queueInformation
    case legalRepresentant
    case onlineSessionStartCloseAt = "onlineSessionStartTimeout"
    case targetWallets
  }
}

extension EIDRequestStatus {

  public enum State: String, Codable {
    case inQueue = "IN_QUEUING"
    case readyForOnlineSession = "READY_FOR_ONLINE_SESSION"
    case inTargetWalletPairing = "IN_TARGET_WALLET_PAIRING"
    case agentReview = "WAITING_FOR_VERIFICATION_APPROVAL"
    case cancelled = "CANCELLED"
    case expired = "TIMEOUT"
    case unknown = "UNKNOWN"
    case declined = "DECLINED"

    // MARK: Lifecycle

    init(_ state: EIDRequestStatusStateEntity) {
      switch state {
      case .inQueue:
        self = .inQueue
      case .readyForOnlineSession:
        self = .readyForOnlineSession
      case .inTargetWalletPairing:
        self = .inTargetWalletPairing
      case .cancelled:
        self = .cancelled
      case .expired:
        self = .expired
      case .unknown:
        self = .unknown
      case .agentReview:
        self = .agentReview
      case .declined:
        self = .declined
      }
    }
  }

  public struct QueueInformation: Decodable, Equatable {
    public let onlineSessionStartOpenAt: Date

    private let position: Int
    private let total: Int

    private enum CodingKeys: String, CodingKey {
      case onlineSessionStartOpenAt = "expectedOnlineSessionStart"
      case position = "positionInQueue"
      case total = "totalInQueue"
    }
  }

  public struct LegalRepresentant: Decodable, Equatable {
    public let isVerified: Bool
    private let verificationLink: String

    private enum CodingKeys: String, CodingKey {
      case isVerified = "verified"
      case verificationLink
    }
  }

  public struct TargetWallet: Decodable, Equatable {
    public let limitReached: Bool
    public let pairedWallets: [PairedWallet]

    public struct PairedWallet: Decodable, Equatable {
      public let pairedAt: Date
      public var collectingAt: Date? = nil

      private enum CodingKeys: String, CodingKey {
        case pairedAt = "timestampPairing"
        case collectingAt = "timestampCollecting"
      }
    }
  }
}
