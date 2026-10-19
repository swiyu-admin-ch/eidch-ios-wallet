import LocalAuthentication

public final class NoInteractionLAContext: LAContext, @unchecked Sendable {
  override public init() {
    super.init()
    interactionNotAllowed = true
  }
}
