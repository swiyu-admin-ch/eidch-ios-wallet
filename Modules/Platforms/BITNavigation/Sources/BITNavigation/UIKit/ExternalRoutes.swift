import Foundation
import UIKit

// MARK: - ExternalRoutes

public protocol ExternalRoutes {
  func externalSettings()
  func openExternalLink(url: URL)
  func openExternalLink(url: URL, onComplete: (() -> Void)?)
}

extension ExternalRoutes {
  public func externalSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }

  public func openExternalLink(url: URL, onComplete: (() -> Void)?) {
    UIApplication.shared.open(url) { _ in
      onComplete?()
    }
  }

  public func openExternalLink(url: URL) {
    UIApplication.shared.open(url)
  }
}
