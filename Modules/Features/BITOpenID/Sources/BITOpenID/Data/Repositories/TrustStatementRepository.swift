import BITNetworking
import BITSdJWT
import Factory
import Foundation

// MARK: - TrustStatementRepository

struct TrustStatementRepository: TrustStatementRepositoryProtocol {

  // MARK: Internal

  func fetchIdentityTrustStatements(from url: URL, for subjectDid: String) async throws -> [IdentityTrustStatement] {
    let statements: [String] = try await networkService.request(TrustStatementEndpoint.identity(url: url, subjectDid: subjectDid))
    return try statements.map {
      let data = $0.data(using: .utf8) ?? Data()
      return try sdJwsDecoder.decode(IdentityTrustStatementJWT.self, from: data)
    }
  }

  func fetchVcSchemaTrustStatements(from url: URL, for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async throws -> [VcSchemaTrustStatement] {
    let statements: [String] = try await networkService.request(TrustStatementEndpoint.vcSchema(url: url, type: type, vcSchemaId: vcSchemaId))
    return try statements.map {
      let data = $0.data(using: .utf8) ?? Data()
      return try sdJwsDecoder.decode(VcSchemaTrustStatementJWT.self, from: data)
    }
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.sdJwsDecoder) private var sdJwsDecoder: SdJWSDecoderProtocol
}
