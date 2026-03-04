import BITCredentialShared
import BITOpenID
import BITSwiyuSharedKMP
import Spyable

@Spyable
public protocol DcqlCredentialMatcherProtocol {

  func match(credentials: [VerifiableCredential], with dcqlQuery: DcqlQuery) async throws -> [CompatibleCredential]

}
