import NavigatorUI

struct OTPCheckpoints: NavigationCheckpoints {
  static var email: NavigationCheckpoint<Void> {
    checkpoint()
  }
}
