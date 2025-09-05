import BITCredentialShared
import BITOpenID

public enum FetchCredentialResult {
  case credential(Credential, TrustStatement?)
  case deferred(DeferredCredential)
}
