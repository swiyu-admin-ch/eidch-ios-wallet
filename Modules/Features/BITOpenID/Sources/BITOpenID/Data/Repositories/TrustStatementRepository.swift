import BITJWT
import BITNetworking
import BITSdJWT
import Factory
import Foundation

// MARK: - TrustStatementRepository

struct TrustStatementRepository: TrustStatementRepositoryProtocol {

  // MARK: Internal

  func fetchIdentityTrustStatements(from url: URL, for subjectDid: String) async throws -> [IdentityTrustStatementV1] {
    let statements: [String] = try await networkService.request(TrustStatementEndpoint.identity(url: url, subjectDid: subjectDid))
    return try statements.map {
      let data = $0.data(using: .utf8) ?? Data()
      return try vcSdJwsDecoder.decode(IdentityTrustStatementV1JWT.self, from: data)
    }
  }

  func fetchVcSchemaTrustStatements(from url: URL, for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async throws -> [VcSchemaTrustStatement] {
    let statements: [String] = try await networkService.request(TrustStatementEndpoint.vcSchema(url: url, type: type, vcSchemaId: vcSchemaId))
    return try statements.map {
      let data = $0.data(using: .utf8) ?? Data()
      return try vcSdJwsDecoder.decode(VcSchemaTrustStatementJWT.self, from: data)
    }
  }

  func fetchProtectedIssuanceTrustListStatement(for subjectDid: String) async throws -> ProtectedIssuanceTrustListStatement {
    let url = try urlMapper.map(did: subjectDid)
    let response = try await networkService.request(TrustStatementEndpoint.protectedIssuanceTrustList(url: url))
    return try jwsDecoder.decode(ProtectedIssuanceTrustListStatementJWT.self, from: response.data)
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.vcSdJwsDecoder) private var vcSdJwsDecoder: VcSdJWSDecoderProtocol
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\.trustRegistryUrlMapper) private var urlMapper
}
