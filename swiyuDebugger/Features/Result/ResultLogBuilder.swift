import BITCredential
import BITCredentialShared
import BITNetworking
import BITNonCompliance
import BITPresentation
import Foundation

struct ResultLogBuilder {

  // MARK: Internal

  static func buildLogURL(mode: ScanResult, invitationURL: URL?) -> URL? {
    let logText = buildLogText(mode: mode, invitationURL: invitationURL)
    let timestamp = logDateFormatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")
    let fileName = "scan-result-\(timestamp).log"
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    do {
      try logText.write(to: url, atomically: true, encoding: .utf8)
      return url
    } catch {
      return nil
    }
  }

  static func buildLogText(mode: ScanResult, invitationURL: URL?) -> String {
    var lines = [String]()
    lines.append("---- Scan Result Log ----")
    lines.append("Timestamp: \(logDateFormatter.string(from: Date()))")
    lines.append("Mode: \(mode.label)")
    lines.append("")

    switch mode {
    case .credential(let credential, let trustInformation):
      lines.append(contentsOf: credentialLogLines(credential: credential, trustInformation: trustInformation))
    case .presentation(let context):
      lines.append(contentsOf: presentationLogLines(context: context))
    case .error(let error):
      let description = error.localizedDescription
      let recovery = (error as NSError).localizedRecoverySuggestion
      lines.append("Error: \(String(reflecting: error))")
      if !description.isEmpty {
        lines.append("Description: \(description)")
      }
      if let recovery, !recovery.isEmpty {
        lines.append("Suggested recovery: \(recovery)")
      }
      if let networkError = error as? NetworkError {
        lines.append("Network error status: \(networkError.status)")
        if let response = networkError.response {
          lines.append("HTTP status code: \(response.statusCode)")
          if let httpResponse = response.response {
            let headerText = httpResponse.allHeaderFields
              .map { "\($0.key): \($0.value)" }
              .sorted()
              .joined(separator: "\n")
            if !headerText.isEmpty {
              lines.append("Headers:")
              lines.append(headerText)
            }
          }
          if !response.data.isEmpty {
            if let body = String(data: response.data, encoding: .utf8) {
              lines.append("Body:")
              lines.append(body)
            }
          }
        }
      }
    }

    if let invitationURL {
      lines.append("")
      lines.append("Invitation URL:")
      lines.append(invitationURL.absoluteString)
    }

    return lines.joined(separator: "\n")
  }

  // MARK: Private

  private static let logDateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  private static func credentialLogLines(credential: any CredentialProtocol, trustInformation: TrustInformation?) -> [String] {
    var lines = [String]()
    lines.append("Credential ID: \(credential.id)")
    lines.append("Format: \(credential.format)")
    if let selectedConfigurationId = credential.selectedConfigurationId {
      lines.append("Selected configuration ID: \(selectedConfigurationId)")
    }
    if let verifiableCredential = credential as? VerifiableCredential {
      lines.append("Issuer: \(verifiableCredential.issuer)")
    }
    lines.append("")
    lines.append("Trust information:")
    lines.append(contentsOf: trustInformationLogLines(trustInformation))
    if let verifiableCredential = credential as? VerifiableCredential {
      lines.append("")
      lines.append("Raw credentials:")
      for bundleItem in verifiableCredential.bundleItems {
        if let rawCredential = String(data: bundleItem.payload, encoding: .utf8) {
          lines.append(rawCredential)
        }
      }
      if verifiableCredential.bundleItems.isEmpty {
        lines.append("Unavailable")
      }
      lines.append("")
      lines.append("Claims:")
      lines.append(contentsOf: claimClusterLogLines(verifiableCredential.clusters, indent: ""))
    } else if let deferredCredential = credential as? DeferredCredential {
      lines.append("")
      lines.append("Deferred credential:")
      lines.append("Transaction ID: \(deferredCredential.transactionId)")
      lines.append("Progression: \(deferredCredential.progressionState.rawValue)")
      lines.append("Polling interval: \(deferredCredential.pollingInterval)s")
      if let polledAt = deferredCredential.polledAt {
        lines.append("Last polled: \(polledAt)")
      }
    }
    return lines
  }

  private static func presentationLogLines(context: PresentationRequestContext) -> [String] {
    var lines = [String]()
    lines.append("Compatible credentials:")
    for credential in context.compatibleCredentials {
      lines.append("- \(credential.credentialName) (\(credential.id))")
    }
    lines.append("")
    lines.append("Trust information:")
    lines.append(contentsOf: trustInformationLogLines(context.trustInformation))
    lines.append("")
    lines.append("Requested claims:")
    for credential in context.compatibleCredentials {
      lines.append("Credential: \(credential.credentialName) (\(credential.id))")
      if credential.requestedClaimClusters.isEmpty {
        lines.append("  None")
      } else {
        lines.append(contentsOf: claimClusterLogLines(credential.requestedClaimClusters, indent: "  "))
      }
    }
    return lines
  }

  private static func trustInformationLogLines(_ trustInformation: TrustInformation?) -> [String] {
    guard let trustInformation else { return ["Unavailable"] }
    var lines = [String]()
    switch trustInformation.identity {
    case .trusted(let trustStatement):
      let name = trustStatement.getLocalizedEntityName(considering: Locale.preferredLanguages)
      lines.append("Identity: trusted")
      if !name.isEmpty {
        lines.append("Identity name: \(name)")
      }
    case .untrusted:
      lines.append("Identity: untrusted")
    case .unknown:
      lines.append("Identity: unknown")
    }
    lines.append("VC Schema: \(trustInformation.vcSchema.rawValue)")
    switch trustInformation.actorCompliance {
    case .compliant?:
      lines.append("Actor compliance: compliant")
    case .notCompliant?:
      lines.append("Actor compliance: notCompliant")
    case nil:
      lines.append("Actor compliance: unknown")
    }
    if
      case .notCompliant(let reason) = trustInformation.actorCompliance,
      let localizedReason = reason.localized()
    {
      lines.append("Non-compliance reason: \(localizedReason)")
    }
    return lines
  }

  private static func claimClusterLogLines(_ clusters: [CredentialClaimCluster], indent: String) -> [String] {
    var lines = [String]()
    for cluster in clusters {
      let title = cluster.preferredDisplay?.name ?? "Cluster"
      lines.append("\(indent)[Cluster] \(title)")
      for claim in cluster.claims {
        let value = claim.isSensitive ? "<redacted>" : (claim.value ?? "")
        lines.append("\(indent)- \(claim.path): \(value)")
      }
      if !cluster.childClusters.isEmpty {
        lines.append(contentsOf: claimClusterLogLines(cluster.childClusters, indent: indent + "  "))
      }
    }
    return lines
  }

}
