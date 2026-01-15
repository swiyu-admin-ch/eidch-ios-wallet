import NavigatorUI

public struct ActivityCheckpoints: NavigationCheckpoints {
  public static var activities: NavigationCheckpoint<Bool> { checkpoint() }
  public static var activityDetail: NavigationCheckpoint<Bool> { checkpoint() }
}
