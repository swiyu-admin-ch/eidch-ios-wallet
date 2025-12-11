import Factory
import NavigatorUI

extension Container {

  public var navigatorRoot: Factory<Navigator> {
    self { Navigator(configuration: NavigationConfiguration(verbosity: .info)) }
  }
}
