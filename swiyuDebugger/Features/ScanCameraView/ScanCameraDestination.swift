import BITInvitation
import NavigatorUI
import SwiftUI

// MARK: - ScanCameraDestination

enum ScanCameraDestination: NavigationDestination, Hashable {
  case result(ScanResult, URL?)
  case error(Error, URL?)

  var method: NavigationMethod {
    .push
  }

  @ViewBuilder var body: some View {
    switch self {
    case .result(let mode, let invitationURL):
      ScanResultView(mode: mode, invitationURL: invitationURL)
    case .error(let error, let invitationURL):
      ScanResultView(mode: .error(error), invitationURL: invitationURL)
    }
  }
}

extension ScanCameraDestination {

  // MARK: Lifecycle

  init?(invitationDestination: InvitationDestinations, invitationURL: URL?) {
    switch invitationDestination {
    case .offer(let credential):
      self = .result(.credential(credential), invitationURL)
    case .external(.presentation(let context)):
      self = .result(.presentation(context), invitationURL)
    default:
      return nil
    }
  }

  // MARK: Internal

  static func == (lhs: ScanCameraDestination, rhs: ScanCameraDestination) -> Bool {
    switch (lhs, rhs) {
    case (.result(let leftResult, let leftURL), .result(let rightResult, let rightURL)):
      leftResult == rightResult && leftURL == rightURL
    case (.error(let leftError, let leftURL), .error(let rightError, let rightURL)):
      String(describing: type(of: leftError)) == String(describing: type(of: rightError)) &&
        leftError.localizedDescription == rightError.localizedDescription &&
        leftURL == rightURL
    default:
      false
    }
  }

  func hash(into hasher: inout Hasher) {
    switch self {
    case .result(let result, let invitationURL):
      hasher.combine("result")
      hasher.combine(result)
      hasher.combine(invitationURL)
    case .error(let error, let invitationURL):
      hasher.combine("error")
      hasher.combine(String(describing: type(of: error)))
      hasher.combine(error.localizedDescription)
      hasher.combine(invitationURL)
    }
  }
}
