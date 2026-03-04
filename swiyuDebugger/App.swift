import Factory
import SwiftUI

@main
struct SwiyuDebuggerApp: App {

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      HomeView()
    }
  }

  // MARK: Private

  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

}
