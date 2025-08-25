import Foundation
import XCTest

// MARK: - Screen

protocol Screen: Equatable {
  var app: XCUIApplication { get }
}
