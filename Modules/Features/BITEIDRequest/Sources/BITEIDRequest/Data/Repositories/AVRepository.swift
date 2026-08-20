import BITAppAttestation
import BITEIDRequestShared
import BITNetworking
import BITOpenID
import Factory
import Foundation
import Moya
import Spyable

// MARK: - AVRepositoryProtocol

@Spyable
protocol AVRepositoryProtocol {
  func submitFile(_ file: EIDRequestCaseFile, caseId: String, authJwt: String, _ progress: ProgressBlock?) async throws
  func submitRequest(caseId: String, authJwt: String, files: [EIDRequestCaseFile]) async throws
}

// MARK: - AVRepository

struct AVRepository: AVRepositoryProtocol {

  // MARK: Internal

  func submitFile(_ file: EIDRequestCaseFile, caseId: String, authJwt: String, _ progress: ProgressBlock?) async throws {
    try await executeRequest(.submitFile(caseId: caseId, file: file), authJwt: authJwt, requestBody: file.data, progress: progress)
  }

  func submitRequest(caseId: String, authJwt: String, files: [EIDRequestCaseFile]) async throws {
    let bodyFiles = files.compactMap { file in
      EIDRequestSubmitFile(fileName: file.fileName, hash: sha256Hasher.hash(file.data).base64EncodedString())
    }
    let requestBody = try JSONEncoder().encode(bodyFiles)

    try await executeRequest(.submit(caseId: caseId, body: requestBody), authJwt: authJwt, requestBody: requestBody)
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher
  @Injected(\NetworkContainer.service) private var networkService
  @Injected(\.dpopGenerator) private var dpopGenerator: DPoPGeneratorProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol

  private func executeRequest(_ target: AVRepositoryEndpoint, authJwt: String, requestBody: Data, progress: ProgressBlock? = nil) async throws {
    let dPopPlugin = try createDPoP(for: target, authJwt: authJwt, requestBody: requestBody)
    try await networkService.request(target, plugins: [dPopPlugin], progress)
  }

  private func createDPoP(for target: AVRepositoryEndpoint, authJwt: String, requestBody: Data) throws -> DPoPPlugin {
    let dPopKey = try appAttestationKeyRepository.get(for: .client)
    let dPop = try dpopGenerator.generate(method: target.method.rawValue, url: URL(target: target), keyPair: dPopKey, accessToken: authJwt, requestBody: requestBody)

    return DPoPPlugin(dPop: dPop, accessToken: authJwt)
  }
}
