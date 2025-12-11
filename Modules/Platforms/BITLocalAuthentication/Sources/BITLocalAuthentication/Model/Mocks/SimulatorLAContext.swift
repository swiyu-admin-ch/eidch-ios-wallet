import Foundation
import LocalAuthentication

#if targetEnvironment (simulator)
public class SimulatorLAContext: LAContext {
  override public func setCredential(_ credential: Data?, type: LACredentialType) -> Bool {
    true
  }

  public override func isCredentialSet(_ type: LACredentialType) -> Bool {
    true
  }

  override public func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
    true
  }
}
#else
public typealias SimulatorLAContext = LAContext
#endif
