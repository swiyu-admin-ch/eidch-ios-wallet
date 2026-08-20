import Foundation
import Spyable
import UIKit

// MARK: - ApplicationServiceProtocol

@Spyable
public protocol ApplicationServiceProtocol {
  @discardableResult
  func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
  func registerForRemoteNotifications()
}

extension ApplicationServiceProtocol {
  @MainActor @discardableResult
  public func open(_ url: URL) async -> Bool {
    await open(url, options: [:])
  }
}

// MARK: - UIApplication + ApplicationServiceProtocol

extension UIApplication: ApplicationServiceProtocol {}
