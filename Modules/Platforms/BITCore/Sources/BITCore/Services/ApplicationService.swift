import Foundation
import Spyable
import UIKit

// MARK: - ApplicationServiceProtocol

@Spyable
@MainActor
public protocol ApplicationServiceProtocol {
  @discardableResult
  func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: any Sendable]) async -> Bool
  func registerForRemoteNotifications()
}

extension ApplicationServiceProtocol {
  @discardableResult
  public func open(_ url: URL) async -> Bool {
    await open(url, options: [:])
  }
}

// MARK: - UIApplication + ApplicationServiceProtocol

extension UIApplication: ApplicationServiceProtocol {
  @discardableResult
  public func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: any Sendable]) async -> Bool {
    await open(url, options: options as [UIApplication.OpenExternalURLOptionsKey: Any])
  }
}
