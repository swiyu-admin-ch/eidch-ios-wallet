import NavigatorUI

// MARK: - Checkpoints

public struct Checkpoints: NavigationCheckpoints {

  public static var home: NavigationCheckpoint<HomeCheckpointsState> {
    checkpoint()
  }
}

// MARK: - HomeCheckpointsState

public enum HomeCheckpointsState: Hashable {
  case acceptCredential
  case declineCredential
  case deletedCredential
  case startRequestCasePolling(caseId: String)
}
