import NavigatorUI

public struct PresentationCheckpoints: NavigationCheckpoints {

  public static var didFinish: NavigationCheckpoint<PresentationRequestResultState> {
    checkpoint()
  }
}
