#if DEBUG
import Foundation

extension EIDRequestCase {
  public struct Mock {

    // MARK: Public

    public static let validSamples: [EIDRequestCase] = [
      sampleInQueue,
      sampleInQueueNotVerified,
      sampleAVReady,
      sampleAVReadyNotVerified,
      sampleWithoutState,
      sampleDeclined,
      sampleExpired,
      sampleWalletPairing,
      sampleAgentReview,
    ]

    // MARK: Internal

    static let sampleInQueue = createRequestCase(createdAt: Date().addingTimeInterval(-4), state: createRequestCaseState(.inQueue, openAt: Date()))
    static let sampleInQueueNotVerified = createRequestCase(state: createRequestCaseState(.inQueue, consent: .notVerified, openAt: Date()))
    static let sampleExpired = createRequestCase(createdAt: Date().addingTimeInterval(-1), state: createRequestCaseState(.expired, openAt: Date()))
    static let sampleCancelled = createRequestCase(createdAt: Date().addingTimeInterval(-2), state: createRequestCaseState(.cancelled, consent: .notRequired))
    static let sampleInQueueNoOnlineSessionStart = createRequestCase(createdAt: Date(), state: createRequestCaseState(.inQueue))
    static let sampleAVReady = createRequestCase(createdAt: Date().addingTimeInterval(-3), state: createRequestCaseState(.readyForOnlineSession, timeoutAt: Date()))
    static let sampleAgentReview = createRequestCase(state: createRequestCaseState(.agentReview, openAt: Date()))
    static let sampleDeclined = createRequestCase(state: createRequestCaseState(.refused, openAt: Date()))
    static let sampleAVReadyNotVerified = createRequestCase(state: createRequestCaseState(.readyForOnlineSession, consent: .notVerified, timeoutAt: Date()))
    static let sampleAVReadyNoOnlineSessionTimeout = createRequestCase(state: createRequestCaseState(.readyForOnlineSession, openAt: Date()))
    static let sampleWithoutState = createRequestCase()
    static let sampleWalletPairing = createRequestCase(state: createRequestCaseState(.inTargetWalletPairing))
    static let sampleAutoVerification = createRequestCase(state: createRequestCaseState(.autoVerification))

    // MARK: Private

    private static func createRequestCase(createdAt: Date = Date(), state: EIDRequestState? = nil, pushId: String = UUID().uuidString) -> EIDRequestCase {
      EIDRequestCase(
        id: UUID().uuidString,
        createdAt: createdAt,
        rawMRZ: [
          "ID<<<I7G<<<<<<3<<<<<<<<<<<<<<<",
          "1001015X3012316<<<<<<<<<<<<<<0",
          "MINDERJAEHRIGE<<ANNETTE<<<<<<<",
        ],
        documentNumber: "A123456789",
        selectedDocumentType: .identityCard,
        lastName: "Do",
        firstName: "John",
        state: state,
        filesSubmitted: false,
        pushId: pushId)
    }

    private static func createRequestCaseState(
      _ state: EIDRequestStatus.State,
      consent: LegalRepresentantConsent = .verified,
      openAt: Date? = nil,
      timeoutAt: Date? = nil)
      -> EIDRequestState
    {
      EIDRequestState(
        id: UUID(),
        state: state,
        legalRepresentantConsent: consent,
        lastPolledAt: Date(),
        onlineSessionStartOpenAt: openAt,
        onlineSessionStartTimeoutAt: timeoutAt)
    }

  }
}
#endif
