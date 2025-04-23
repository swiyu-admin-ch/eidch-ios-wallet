import BITCore
import BITCrypto
import Factory
import Foundation
import Spyable

// MARK: - OCABundleServiceError

enum OCABundleServiceError: Error {
  case invalidOCAUrl
  case invalidOCABundle
}

// MARK: - OCABundleServiceProtocol

@Spyable
public protocol OCABundleServiceProtocol {
  func fetchVcSdJwtOcaBundle(from ocaRendering: VcSdJwtOcaRendering) async throws -> RawOcaBundle?
}

// MARK: - OCABundleService

struct OCABundleService: OCABundleServiceProtocol {

  // MARK: Internal

  func fetchVcSdJwtOcaBundle(from ocaRendering: VcSdJwtOcaRendering) async throws -> RawOcaBundle? {
    guard
      let url = URL(string: ocaRendering.uri),
      let urlScheme = url.scheme,
      let scheme = URLScheme(rawValue: urlScheme)
    else {
      throw OCABundleServiceError.invalidOCAUrl
    }

    return switch scheme {
    case .https:
      try await fetchRawOcaBundle(from: url, with: ocaRendering)
    case .data:
      try await fetchDataRawOcaBundle(from: url, with: ocaRendering)
    }
  }

  // MARK: Private

  @Injected(\.sriValidator) private var sriValidator: SRIValidatorProtocol
  @Injected(\.ocaRepository) private var ocaRepository: OCARepositoryProtocol

  private func fetchRawOcaBundle(from url: URL, with ocaRendering: VcSdJwtOcaRendering) async throws -> RawOcaBundle {
    guard let uriIntegrity = ocaRendering.uriIntegrity else {
      throw OCABundleServiceError.invalidOCABundle
    }

    let rawOcaBundle = try await ocaRepository.fetchOCABundle(from: url)

    guard try sriValidator.validate(rawOcaBundle, with: uriIntegrity) else {
      throw OCABundleServiceError.invalidOCABundle
    }

    return rawOcaBundle
  }

  private func fetchDataRawOcaBundle(from url: URL, with ocaRendering: VcSdJwtOcaRendering) async throws -> RawOcaBundle {
    guard
      url.isValidOCADataFormat,
      let urlData = url.absoluteString.data(using: .utf8),
      let base64String = url.absoluteString.split(separator: ",").last,
      let rawOcaBundle = Data(base64Encoded: String(base64String))
    else {
      throw OCABundleServiceError.invalidOCABundle
    }

    guard let uriIntegrity = ocaRendering.uriIntegrity else {
      return rawOcaBundle
    }

    guard try sriValidator.validate(urlData, with: uriIntegrity) else {
      throw OCABundleServiceError.invalidOCABundle
    }

    return rawOcaBundle
  }
}

extension URL {
  fileprivate var isValidOCADataFormat: Bool {
    absoluteString.starts(with: "data:application/json;base64")
  }
}
