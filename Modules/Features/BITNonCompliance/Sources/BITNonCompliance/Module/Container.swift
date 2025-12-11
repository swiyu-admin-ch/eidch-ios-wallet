import Factory
import Foundation

extension Container {

  public var isNonComplianceEnabled: Factory<Bool> {
    self { false }
  }
}
