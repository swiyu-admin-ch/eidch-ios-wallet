import BITEntities
import Foundation


public struct EIDRequestStatus: Decodable, Equatable {

  // MARK: Public

  public let state: State
  public let onlineSessionStartCloseAt: Date?
  public let queueInformation: QueueInformation?
  public let legalRepresentant: LegalRepresentant?
  public let targetWallets: TargetWallet?

  // MARK: Private

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
    case refused = "REFUSED"
    case autoVerification = "IN_AUTO_VERIFICATION"
    case closed = "CLOSED"
    case issuing = "IN_ISSUANCE"
    case readyForFinalEntitlementCheck = "READY_FOR_FINAL_ENTITLEMENT_CHECK"
  }

  public struct QueueInformation: Decodable, Equatable {

    // MARK: Public

    public let onlineSessionStartOpenAt: Date

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case onlineSessionStartOpenAt = "expectedOnlineSessionStart"
      case position = "positionInQueue"
      case total = "totalInQueue"
    }

    private let position: Int
    private let total: Int

  }

  public struct LegalRepresentant: Decodable, Equatable {

    // MARK: Public

    public let isVerified: Bool

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case isVerified = "verified"
      case verificationLink
    }

    private let verificationLink: String

  }

  public struct TargetWallet: Decodable, Equatable {

    public struct PairedWallet: Decodable, Equatable {

      // MARK: Public

      public let pairedAt: Date
      public var collectingAt: Date? = nil
      public let walletPairingId: String

      // MARK: Private

      private enum CodingKeys: String, CodingKey {
        case pairedAt = "timestampPairing"
        case collectingAt = "timestampCollecting"
        case walletPairingId
      }
    }

    public let limitReached: Bool
    public let pairedWallets: [PairedWallet]

  }
}
