import BITAnyCredentialFormat

public enum FetchAnyCredentialResult {
  case credential(AnyCredential)
  case deferred(DeferredCredentialRequest)
}
