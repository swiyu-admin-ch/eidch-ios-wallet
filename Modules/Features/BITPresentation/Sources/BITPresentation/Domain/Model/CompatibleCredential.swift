import BITCore
import BITCredentialShared
import BITOpenID
import Foundation

// MARK: - CompatibleCredential

public struct CompatibleCredential: Identifiable, Equatable {

  // MARK: Lifecycle

  public init(credential: VerifiableCredential, requestedFields: [PresentationField], dcqlQueryId: String? = nil) {
    self.credential = credential
    id = credential.id

    self.requestedFields = requestedFields
    self.dcqlQueryId = dcqlQueryId
  }

  // MARK: Public

  public let id: UUID
  public let credential: VerifiableCredential
  public let dcqlQueryId: String?

  public var credentialName: String {
    credential.displays.first?.name ?? "Unknown Credential"
  }

  public var requestedClaimClusters: [CredentialClaimCluster] {
    let filteredClusters = credential.clusters.compactMap {
      filterClusterClaims($0, requestedFields: requestedFields)
    }
    if !filteredClusters.isEmpty {
      return filteredClusters
    }
    return buildSyntheticRequestedClusters(from: requestedFields)
  }

  // MARK: Internal

  let requestedFields: [PresentationField]

  // MARK: Private

  private func filterClusterClaims(_ cluster: CredentialClaimCluster, requestedFields: [PresentationField]) -> CredentialClaimCluster? {
    let requestedClaims = cluster.claims.filter { claim in
      requestedFields.contains { $0.key == claim.key }
    }
    let requestedChildClusters = cluster.childClusters.compactMap { childCluster in
      filterClusterClaims(childCluster, requestedFields: requestedFields)
    }
    guard !requestedClaims.isEmpty || !requestedChildClusters.isEmpty else { return nil }
    return CredentialClaimCluster(id: cluster.id, order: cluster.order, claims: requestedClaims, childClusters: requestedChildClusters, displays: cluster.displays)
  }

  private func buildSyntheticRequestedClusters(from fields: [PresentationField]) -> [CredentialClaimCluster] {
    guard !fields.isEmpty else { return [] }
    let claims = fields.enumerated().compactMap { index, field in
      makeSyntheticClaim(from: field, order: index)
    }
    guard !claims.isEmpty else { return [] }
    return [CredentialClaimCluster(order: 0, claims: claims)]
  }

  private func makeSyntheticClaim(from field: PresentationField, order: Int) -> CredentialClaim? {
    guard let value = field.value.syntheticDisplayValue else { return nil }
    let displayName = field.displayLabel
    let display = CredentialClaimDisplay(locale: nil, name: displayName)
    return CredentialClaim(
      key: field.key,
      value: value,
      valueType: field.value.syntheticValueType,
      order: order,
      displays: [display])
  }
}

extension PresentationField {
  fileprivate var displayLabel: String {
    let trimmed = key.replacingOccurrences(of: "_", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return key }
    return trimmed.prefix(1).capitalized + trimmed.dropFirst()
  }
}

extension CodableValue {
  fileprivate var syntheticValueType: String {
    switch self {
    case .string: "string"
    case .int: "number"
    case .double: "number"
    case .bool: "boolean"
    case .array: "array"
    case .dictionary: "object"
    }
  }

  fileprivate var syntheticDisplayValue: String? {
    switch self {
    case .string(let value): return value
    case .int(let value): return String(value)
    case .double(let value): return String(value)
    case .bool(let value): return value ? "true" : "false"
    case .array(let values):
      let components = values.compactMap { value -> String? in
        guard let value else { return nil }
        return value.syntheticDisplayValue
      }
      return components.isEmpty ? nil : components.joined(separator: ", ")
    case .dictionary(let dictionary):
      let components = dictionary.compactMap { key, value -> String? in
        guard let value else { return nil }
        guard let stringValue = value.syntheticDisplayValue else { return nil }
        return "\(key): \(stringValue)"
      }
      return components.isEmpty ? nil : components.joined(separator: ", ")
    }
  }
}
