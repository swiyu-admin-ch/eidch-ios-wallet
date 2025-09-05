import BITAnyCredentialFormat

public enum FetchAnyCredentialResult {
  case credential(AnyCredential)
  case deferred(transactionId: String, accessToken: String, endpoint: String)
}
