import BITCredentialShared
import BITOpenID
import BITSwiyuSharedKMP
import Spyable

@Spyable
public protocol DcqlCredentialMatcherProtocol {

  func match(credentials: [VerifiableCredential], with dcqlQuery: Heidi_dcqlDcqlQuery) async throws -> [CompatibleCredential]

}
