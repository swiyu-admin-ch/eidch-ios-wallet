public enum PresentationRequestResultState: Equatable, Hashable {
  case success
  case invalidCredential
  case deny
  case error
}
