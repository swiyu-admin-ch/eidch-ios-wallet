#if DEBUG
import Foundation
@testable import BITCore

extension ActivityActorDisplay: Mockable {
  public struct Mock {
    public static let `default` = ActivityActorDisplay(name: "name", locale: "locale", image: "image".data(using: .utf8))
  }
}
#endif
