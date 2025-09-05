import BITAnyCredentialFormat
import BITCore
import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - TrustStatementServiceProtocol

@Spyable
public protocol TrustStatementServiceProtocol {
  func fetch(for subjectDid: String) async throws -> TrustStatement?
}

// MARK: - TrustStatementServiceError

enum TrustStatementServiceError: Error {
  case cannotParseTrustRegistryDomain
}

// MARK: - TrustStatementService

struct TrustStatementService: TrustStatementServiceProtocol {

  // MARK: Internal

  func fetch(for subjectDid: String) async throws -> TrustStatement? {
    let trustStatementURL = try getTrustStatementURL(for: subjectDid)
    let trustStatements = try await fetchValidTrustStatements(from: trustStatementURL, subjectDid: subjectDid)
    guard trustStatements.count == 1 else { return nil }
    return trustStatements.first
  }

  // MARK: Private

  @Injected(\.baseRegistryDomainPattern) private var baseRegistryDomainPattern: String
  @Injected(\.openIDRepository) private var openIDRepository
  @Injected(\.trustRegistryRepository) private var trustRegistryRepository
  @Injected(\.trustStatementValidator) private var trustStatementValidator

  private func getTrustStatementURL(for subjectDid: String) throws -> URL {
    guard
      let baseRegistryDomain = getBaseRegistryDomain(from: subjectDid),
      let trustRegistryDomain = trustRegistryRepository.getTrustRegistryDomain(for: baseRegistryDomain),
      let trustStatementURL = URL(string: "https://\(trustRegistryDomain)")
    else {
      throw TrustStatementServiceError.cannotParseTrustRegistryDomain
    }
    return trustStatementURL
  }

  private func getBaseRegistryDomain(from did: String) -> String? {
    guard
      let regex = try? Regex(baseRegistryDomainPattern),
      let match = did.firstMatch(of: regex),
      match.output.count > 1,
      let range = match.output[1].range
    else {
      return nil
    }
    return String(did[range])
  }

  private func fetchValidTrustStatements(from url: URL, subjectDid: String) async throws -> [TrustStatement] {
    let trustStatements = try await openIDRepository.fetchTrustStatements(from: url, for: subjectDid)
    var validStatements: [TrustStatement] = []
    for trustStatement in trustStatements where await trustStatementValidator.validate(trustStatement, for: subjectDid) {
      validStatements.append(trustStatement)
    }
    return validStatements
  }
}
