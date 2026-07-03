import BITAnyCredentialFormat
import BITClaimsPathPointer
import BITCore
import BITCredential
import BITCredentialShared
import BITOpenID
import BITSwiyuSharedKMP
import Factory
import Foundation

// MARK: - DcqlCredentialMatcher

/// Matches credentials against a DCQL query and produces compatible
/// credentials plus the requested fields.
///
/// The flow is:
/// 1) extract raw JSON payloads,
/// 2) ask the shared KMP DCQL matcher for matches,
/// 3) map the match summaries back to `VerifiableCredential` and build
///    `PresentationField` values for the resolved claim values.
struct DcqlCredentialMatcher: DcqlCredentialMatcherProtocol {

  // MARK: Internal

  /// Returns compatible credentials for the given DCQL query.
  ///
  func match(credentials: [VerifiableCredential], with dcqlQuery: DcqlQuery) async throws -> [CompatibleCredential] {
    // 1. Extract raw payloads
    let rawCredentials: [String: VerifiableCredential] = try credentials.compactGroupBy { credential in
      let selectedBundleItem = try selectCredentialBundleItemUseCase(credential)
      guard
        let rawPayload = String(data: selectedBundleItem.payload, encoding: .utf8) else
      {
        return nil
      }
      return rawPayload
    }

    guard !rawCredentials.isEmpty else {
      return []
    }

    // 2. Ask shared DCQL helper for concrete matches
    let rawPayloads = rawCredentials.map(\.key)
    let matches = DcqlSupport().matchDcqlCredentials(query: dcqlQuery, credentialPayloads: rawPayloads)

    // 3. Map summaries to CompatibleCredential instances
    var compatibleCredentials = [CompatibleCredential]()
    for match in matches {
      guard let credential = rawCredentials[match.credentialPayload] else {
        continue
      }

      let requestedPaths = resolveRequestedPaths(claimValues: match.claimValues)
      guard !requestedPaths.isEmpty else {
        continue
      }
      let presentingPaths = try getPresentingPaths(for: requestedPaths, payload: match.credentialPayload, format: credential.format)
      let compatibleCredential = CompatibleCredential(
        credential: credential,
        presentingPaths: presentingPaths,
        dcqlQueryId: match.credentialQueryId)
      compatibleCredentials.append(compatibleCredential)
    }

    return compatibleCredentials
  }

  // MARK: Private

  @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase
  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase

  private func resolveRequestedPaths(claimValues: [DcqlClaimValue]) -> [ClaimsPathPointer] {
    claimValues.compactMap { claimValue in
      claimValue.paths.map(\.toClaimsPathPointerElement)
    }
  }

  private func getPresentingPaths(for requestedPaths: [ClaimsPathPointer], payload: String, format: String) throws -> [ClaimsPathPointer] {
    let anyCredential = try createAnyCredentialUseCase.execute(from: Data(payload.utf8), format: format)
    return anyCredential.getPresentingPaths(for: requestedPaths)
  }

}

extension BITSwiyuSharedKMP.Heidi_credentialsPointerPart {
  fileprivate var toClaimsPathPointerElement: ClaimsPathPointerElement {
    switch onEnum(of: self) {
    case .string(let value):
      .string(value.v1)
    case .index(let value):
      .index(Int(value.v1))
    case .null:
      .null
    }
  }
}
