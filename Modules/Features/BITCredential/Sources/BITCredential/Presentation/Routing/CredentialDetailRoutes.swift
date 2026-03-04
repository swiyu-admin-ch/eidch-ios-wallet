import BITCredentialShared
import BITNavigation

public protocol CredentialDetailRoutes {
  func credentialDetail(_ credential: CredentialProtocol, delegate: CredentialDetailDelegate?)
}
