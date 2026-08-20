import BITCore
import BITCredential
import BITCredentialShared
import BITInvitation
import BITNetworking
import BITNonCompliance
import BITPresentation
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - ScanResultView

struct ScanResultView: View {

  // MARK: Internal

  let mode: ScanResult
  let invitationURL: URL?

  var body: some View {
    List {
      ScanResultHeader(
        title: mode.title,
        symbolName: mode.headerSymbolName,
        color: mode.headerColor)

      ScanResultContent(
        mode: mode,
        invitationURL: invitationURL,
        trustInformation: trustInformation,
        actorCompliance: actorCompliance)
    }
    .toolbar {
      if let logURL {
        ToolbarItem(placement: .navigationBarTrailing) {
          ShareLink(item: logURL) {
            Image(systemName: "square.and.arrow.up")
          }
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          navigator.dismiss()
        } label: {
          Image(systemName: "xmark")
        }
      }
    }
    .task(id: mode) {
      await updateTrustInformationAndLogURL()
    }
    .navigationBarBackButtonHidden()
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @State private var logURL: URL?
  @State private var trustInformation: TrustInformation? = nil
  @State private var actorCompliance: ActorCompliance? = nil

  @Injected(\.fetchIssuanceTrustInformationUseCase) private var fetchIssuanceTrustInformationUseCase

  private func updateTrustInformationAndLogURL() async {
    var fetchedTrustInformation: TrustInformation?
    var fetchedActorCompliance: ActorCompliance?

    if
      case .credential(let credential) = mode,
      let verifiableCredential = credential as? VerifiableCredential
    {
      let result = try? await fetchIssuanceTrustInformationUseCase(for: verifiableCredential)
      fetchedTrustInformation = result?.0
      fetchedActorCompliance = result?.1
    }

    guard !Task.isCancelled else { return }

    trustInformation = fetchedTrustInformation
    actorCompliance = fetchedActorCompliance
    logURL = ResultLogBuilder.buildLogURL(
      mode: mode,
      invitationURL: invitationURL,
      trustInformation: trustInformation,
      actorCompliance: actorCompliance)
  }

}

// MARK: - ScanResultContent

private struct ScanResultContent: View {

  let mode: ScanResult
  let invitationURL: URL?
  let trustInformation: TrustInformation?
  let actorCompliance: ActorCompliance?

  var body: some View {
    switch mode {
    case .credential(let credential):
      CredentialResultSections(
        credential: credential,
        invitationURL: invitationURL,
        trustInformation: trustInformation,
        actorCompliance: actorCompliance)
    case .presentation(let context):
      PresentationResultSections(context: context, invitationURL: invitationURL)
    case .error(let error):
      ScanErrorSection(error: error)
    }
  }
}

// MARK: - CredentialResultSections

private struct CredentialResultSections: View {

  let credential: any CredentialProtocol
  let invitationURL: URL?
  let trustInformation: TrustInformation?
  let actorCompliance: ActorCompliance?

  var body: some View {
    if let verifiableCredential = credential as? VerifiableCredential {
      VerifiableCredentialResultSections(
        credential: verifiableCredential,
        invitationURL: invitationURL,
        trustInformation: trustInformation,
        actorCompliance: actorCompliance)
    } else if let deferredCredential = credential as? DeferredCredential {
      DeferredCredentialResultSections(
        credential: deferredCredential,
        invitationURL: invitationURL,
        trustInformation: trustInformation,
        actorCompliance: actorCompliance)
    } else {
      UnavailableCredentialResultSections(
        invitationURL: invitationURL,
        trustInformation: trustInformation,
        actorCompliance: actorCompliance)
    }
  }
}

// MARK: - VerifiableCredentialResultSections

private struct VerifiableCredentialResultSections: View {

  // MARK: Internal

  let credential: VerifiableCredential
  let invitationURL: URL?
  let trustInformation: TrustInformation?
  let actorCompliance: ActorCompliance?

  var body: some View {
    ClaimLanguageSection(
      locales: CredentialLocalizationSupport.availableClaimLocales(for: credential.resolvedClusters),
      selectedLanguage: $selectedClaimLanguage)

    CredentialUISection(
      credential: credential,
      selectedLanguage: selectedClaimLanguage,
      useDarkCredentialCard: $useDarkCredentialCard)

    CredentialClaimsSection(
      clusters: credential.resolvedClusters,
      selectedLanguage: selectedClaimLanguage,
      isExpanded: $isClaimsExpanded)

    TrustInformationSection(trustInformation: trustInformation, actorCompliance: actorCompliance)

    InvitationURLSection(invitationURL: invitationURL)

    RawCredentialSection(bundleItems: credential.bundleItems)
  }

  // MARK: Private

  @State private var selectedClaimLanguage: String?
  @State private var isClaimsExpanded = false
  @State private var useDarkCredentialCard = false

}

// MARK: - DeferredCredentialResultSections

private struct DeferredCredentialResultSections: View {

  let credential: DeferredCredential
  let invitationURL: URL?
  let trustInformation: TrustInformation?
  let actorCompliance: ActorCompliance?

  var body: some View {
    Section("Deferred credential") {
      Text("Transaction ID: \(credential.transactionId)")
      Text("Format: \(credential.format)")
      Text("Progression: \(credential.progressionState.rawValue)")
      Text("Polling interval: \(credential.pollingInterval)s")
    }

    TrustInformationSection(trustInformation: trustInformation, actorCompliance: actorCompliance)

    InvitationURLSection(invitationURL: invitationURL)
  }
}

// MARK: - UnavailableCredentialResultSections

private struct UnavailableCredentialResultSections: View {

  // MARK: Internal

  let invitationURL: URL?
  let trustInformation: TrustInformation?
  let actorCompliance: ActorCompliance?

  var body: some View {
    Section("Credential") {
      Text("Unavailable")
    }

    TrustInformationSection(trustInformation: trustInformation, actorCompliance: actorCompliance)

    InvitationURLSection(invitationURL: invitationURL)
  }
}

// MARK: - PresentationResultSections

private struct PresentationResultSections: View {

  // MARK: Internal

  let context: PresentationRequestContext
  let invitationURL: URL?

  var body: some View {
    ClaimLanguageSection(
      locales: CredentialLocalizationSupport.availableClaimLocales(for: context.compatibleCredentials.flatMap(\.requestedClaimClusters)),
      selectedLanguage: $selectedClaimLanguage)

    PresentationCredentialUISection(
      credential: context.compatibleCredentials.first?.credential,
      selectedLanguage: selectedClaimLanguage)

    PresentationClaimsSection(
      compatibleCredentials: context.compatibleCredentials,
      selectedLanguage: selectedClaimLanguage,
      isExpanded: $isClaimsExpanded)

    TrustInformationSection(trustInformation: context.trustInformation, actorCompliance: context.actorCompliance)

    InvitationURLSection(invitationURL: invitationURL)

    Section("Raw credential") {
      Text("Unavailable")
    }
  }

  // MARK: Private

  @State private var selectedClaimLanguage: String?
  @State private var isClaimsExpanded = false

}

// MARK: - ScanErrorSection

private struct ScanErrorSection: View {

  // MARK: Internal

  let error: Error

  var body: some View {
    let description = error.localizedDescription
    let recovery = (error as NSError).localizedRecoverySuggestion
    let message = String(reflecting: error)
    Section("Error") {
      Text(message)
      if !description.isEmpty {
        Text("Description: \(description)")
      }
      if let recovery, !recovery.isEmpty {
        Text("Suggested recovery: \(recovery)")
      }

      if let networkErr = unwrapped as? NetworkError {
        NetworkErrorDetails(error: networkErr)
      }
    }
  }

  // MARK: Private

  private var unwrapped: Error {
    if case .invalidQRCode(let underlying) = error as? InvitationError, let underlying {
      return underlying
    }
    return error
  }
}

// MARK: - NetworkErrorDetails

private struct NetworkErrorDetails: View {

  let error: NetworkError

  var body: some View {
    Text("Network error status: \(error.status)")
    if let response = error.response {
      Text("HTTP status code: \(response.statusCode)")
      if let httpResponse = response.response {
        let headerText = httpResponse.allHeaderFields
          .map { "\($0.key): \($0.value)" }
          .sorted()
          .joined(separator: "\n")
        if !headerText.isEmpty {
          Text("Headers:\n\(headerText)")
        }
      }
      if !response.data.isEmpty, let body = String(data: response.data, encoding: .utf8) {
        Text("Body:\n\(body)")
      }
    }
  }
}

// MARK: - ScanResultHeader

private struct ScanResultHeader: View {

  let title: String
  let symbolName: String
  let color: Color

  var body: some View {
    Section {
      HStack {
        Spacer()
        VStack(alignment: .center) {
          Image(systemName: symbolName)
            .resizable()
            .foregroundStyle(color)
            .frame(width: 64, height: 64)

          Text(title)
        }
        Spacer()
      }
    }
  }
}

// MARK: - InvitationURLSection

private struct InvitationURLSection: View {

  // MARK: Internal

  let invitationURL: URL?

  var body: some View {
    Section("Invitation URL") {
      if let invitationURL {
        Text(invitationURL.absoluteString)
          .copyShareMenu(text: invitationURL.absoluteString, shareItem: invitationURL)
      } else {
        Text("Unavailable")
      }
    }
  }
}

// MARK: - CredentialUISection

private struct CredentialUISection: View {

  // MARK: Internal

  let credential: VerifiableCredential
  let selectedLanguage: String?

  @Binding var useDarkCredentialCard: Bool

  var body: some View {
    Section("Credential UI") {
      Toggle("Dark mode", isOn: $useDarkCredentialCard)
      VStack(spacing: .x6) {
        CredentialCardPreview(credential: credential, selectedLanguage: selectedLanguage, controlSize: .large, colorScheme: cardColorScheme)
        CredentialCardPreview(credential: credential, selectedLanguage: selectedLanguage, controlSize: .regular, colorScheme: cardColorScheme)
        CredentialCardPreview(credential: credential, selectedLanguage: selectedLanguage, controlSize: .small, colorScheme: cardColorScheme)
        CredentialCardPreview(credential: credential, selectedLanguage: selectedLanguage, controlSize: .mini, colorScheme: cardColorScheme)
      }
    }
  }

  // MARK: Private

  private var cardColorScheme: ColorScheme {
    useDarkCredentialCard ? .dark : .light
  }
}

// MARK: - PresentationCredentialUISection

private struct PresentationCredentialUISection: View {

  // MARK: Internal

  let credential: VerifiableCredential?
  let selectedLanguage: String?

  var body: some View {
    Section("Credential UI") {
      if let credential {
        CredentialCardPreview(
          credential: credential,
          selectedLanguage: selectedLanguage,
          controlSize: .regular,
          colorScheme: colorScheme)
      } else {
        Text("Unavailable")
      }
    }
  }

  // MARK: Private

  @Environment(\.colorScheme) private var colorScheme
}

// MARK: - CredentialCardPreview

private struct CredentialCardPreview: View {

  let credential: VerifiableCredential
  let selectedLanguage: String?
  let controlSize: ControlSize
  let colorScheme: ColorScheme

  var body: some View {
    let viewModel = CredentialLocalizationSupport.credentialCardViewModel(
      for: credential,
      selectedLanguage: selectedLanguage,
      colorSchemeName: CredentialLocalizationSupport.colorSchemeName(for: colorScheme))

    CredentialCard(
      name: viewModel.credentialDisplay?.name,
      summary: viewModel.credentialDisplay?.summary,
      background: viewModel.credentialDisplay?.backgroundColor,
      logoBase64: viewModel.credentialDisplay?.logoBase64,
      environment: viewModel.environment,
      statusBadgeLabel: viewModel.statusText,
      statusBadgeImage: viewModel.statusImage,
      statusBadgeStyle: viewModel.statusBadgeStyle,
      colorSchemeOverride: colorScheme)
      .padding(.vertical, .x4)
      .controlSize(controlSize)
  }
}

// MARK: - CredentialClaimsSection

private struct CredentialClaimsSection: View {

  // MARK: Internal

  let clusters: [CredentialClaimCluster]
  let selectedLanguage: String?
  @Binding var isExpanded: Bool

  var body: some View {
    Section("Claims") {
      DisclosureGroup(isExpanded: $isExpanded) {
        ClaimClusterList(CredentialLocalizationSupport.localizedClusters(clusters, selectedLanguage: selectedLanguage))
          .padding(.leading, -.x6)
      } label: {
        Text("Show claims")
      }
    }
  }
}

// MARK: - PresentationClaimsSection

private struct PresentationClaimsSection: View {

  // MARK: Internal

  let compatibleCredentials: [CompatibleCredential]
  let selectedLanguage: String?
  @Binding var isExpanded: Bool

  var body: some View {
    Section("Claims") {
      DisclosureGroup(isExpanded: $isExpanded) {
        ForEach(compatibleCredentials) { credential in
          PresentationCredentialClaimsRow(credential: credential, selectedLanguage: selectedLanguage)
        }
      } label: {
        Text("Show claims")
      }
    }
  }
}

// MARK: - PresentationCredentialClaimsRow

private struct PresentationCredentialClaimsRow: View {

  let credential: CompatibleCredential
  let selectedLanguage: String?

  var body: some View {
    VStack(alignment: .leading, spacing: .x2) {
      Text(credential.credentialName)
        .font(.custom.bodyEmphasized)
      if credential.requestedClaimClusters.isEmpty {
        Text("None")
          .font(.custom.footnote)
      } else {
        ClaimClusterList(CredentialLocalizationSupport.localizedClusters(credential.requestedClaimClusters, selectedLanguage: selectedLanguage))
          .padding(.leading, -.x6)
      }
    }
    .padding(.vertical, .x1)
  }
}

// MARK: - RawCredentialSection

private struct RawCredentialSection: View {

  // MARK: Internal

  let bundleItems: [BundleItem]

  var body: some View {
    Section("Raw credential") {
      ForEach(bundleItems) { bundleItem in
        RawCredentialRow(bundleItem: bundleItem)
      }
    }
  }
}

// MARK: - RawCredentialRow

private struct RawCredentialRow: View {

  // MARK: Internal

  let bundleItem: BundleItem

  var body: some View {
    if let rawCredential = String(data: bundleItem.payload, encoding: .utf8) {
      Text(truncated(rawCredential))
        .copyShareMenu(text: rawCredential, shareItem: rawCredential)
    }
  }

  private func truncated(_ text: String, limit: Int = 100) -> String {
    guard text.count > limit else { return text }
    return String(text.prefix(limit)) + "..."
  }
}
