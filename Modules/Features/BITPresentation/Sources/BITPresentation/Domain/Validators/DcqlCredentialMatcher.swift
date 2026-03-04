import BITCore
import BITCredentialShared
import BITOpenID
import BITSwiyuSharedKMP
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

  /// Returns compatible credentials for the given DCQL query.
  ///
  func match(credentials: [VerifiableCredential], with dcqlQuery: DcqlQuery) async throws -> [CompatibleCredential] {
    // 1. Extract raw payloads
    let rawCredentials = credentials.compactMap { credential -> (VerifiableCredential, String)? in
      guard
        let rawPayload = String(data: credential.payload, encoding: .utf8) else
      {
        return nil
      }
      return (credential, rawPayload)
    }

    guard !rawCredentials.isEmpty else {
      return []
    }

    // 2. Ask shared DCQL helper for concrete matches
    let rawPayloads = rawCredentials.map(\.1)
    let matches = DcqlSupport().matchDcqlCredentials(query: dcqlQuery, credentialPayloads: rawPayloads)

    // 3. Map summaries to CompatibleCredential instances
    var compatibleCredentials = [CompatibleCredential]()
    let credentialsByPayload = Dictionary(grouping: rawCredentials, by: { $0.1 })

    for match in matches {
      guard let candidates = credentialsByPayload[match.credentialPayload] else {
        continue
      }

      let requestedFields = resolveRequestedFields(claimValues: match.claimValues)
      guard !requestedFields.isEmpty else {
        continue
      }
      for (credential, _) in candidates {
        let compatibleCredential = CompatibleCredential(
          credential: credential,
          requestedFields: requestedFields,
          dcqlQueryId: match.credentialQueryId)
        compatibleCredentials.append(compatibleCredential)
      }
    }

    return compatibleCredentials
  }

  /// Internal for testing (used by DcqlCredentialMatcherTests).
  func resolveRequestedFields(claimValues: [DcqlClaimValue]) -> [PresentationField] {
    claimValues.compactMap { claimValue in
      guard let value = DcqlCodableValueMapper.codableValue(from: claimValue.value) else {
        return nil
      }
      return PresentationField(jsonPath: claimValue.key, value: value)
    }
  }
}
