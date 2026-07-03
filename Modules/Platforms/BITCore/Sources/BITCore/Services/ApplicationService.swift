import Foundation
import Spyable
import UIKit

// MARK: - ApplicationServiceProtocol

@Spyable @MainActor
public protocol ApplicationServiceProtocol {
  @discardableResult
  func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
  func registerForRemoteNotifications()
}

extension ApplicationServiceProtocol {
  @MainActor
  public func open(_ url: URL) async -> Bool {
    await open(url, options: [:])
  }
}

// MARK: - UIApplication + ApplicationServiceProtocol

extension UIApplication: ApplicationServiceProtocol {}
