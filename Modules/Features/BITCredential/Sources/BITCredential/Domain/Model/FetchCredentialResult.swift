import BITCredentialShared
import BITOpenID

public enum FetchCredentialResult {
  case credential(VerifiableCredential, TrustInformation)
  case deferred(DeferredCredential)
}
