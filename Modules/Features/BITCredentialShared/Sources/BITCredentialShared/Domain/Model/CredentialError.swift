import Foundation

public enum CredentialError: Error {
  case invalidDisplay
  case invalidPayload
  case invalidEntity
  case noBundleItem
}
