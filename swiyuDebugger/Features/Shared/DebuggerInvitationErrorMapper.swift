import BITInvitation

struct DebuggerInvitationErrorMapper: InvitationErrorMapping {
  func callAsFunction(_ error: Error) -> Error {
    error
  }
}
