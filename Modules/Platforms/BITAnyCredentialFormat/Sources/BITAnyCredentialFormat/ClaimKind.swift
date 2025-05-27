// MARK: - ClaimKind

public enum ClaimKind {
  case all
  case nonTechnical // claims that are credential format independent (e.g. without reserved claims for Sd-JWTs)
}
