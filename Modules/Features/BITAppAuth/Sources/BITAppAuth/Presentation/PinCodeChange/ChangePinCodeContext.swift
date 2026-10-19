import Foundation

// MARK: - ChangePinCodeContext

public class ChangePinCodeContext {
  var uniquePassphrase: Data?
  var newPinCode: String?

  weak var changePinCodeDelegate: ChangePinCodeDelegate?
  weak var newPinCodeDelegate: NewPinCodeDelegate?
}

// MARK: - ChangePinCodeDelegate

@MainActor
public protocol ChangePinCodeDelegate: AnyObject {
  func didChangePinCode()
}

// MARK: - NewPinCodeDelegate

@MainActor
public protocol NewPinCodeDelegate: AnyObject {
  func didFail()
}
