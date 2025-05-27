import BITAnyCredentialFormat
import BITOca
import Spyable

@Spyable
public protocol FetchVcMetadataForAnyCredentialUseCaseProtocol {
  func execute(for anyCredential: AnyCredential) async throws -> (VcSchema?, RawOcaBundle?)
}
