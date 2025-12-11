import NavigatorUI

public struct ActivityCheckpoints: NavigationCheckpoints {
  public static var activities: NavigationCheckpoint<Bool> { checkpoint() }
}
