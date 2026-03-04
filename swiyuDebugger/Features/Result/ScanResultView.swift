import BITCredential
import BITCredentialShared
import BITInvitation
import BITNetworking
import BITNonCompliance
import BITPresentation
import BITTheming
import Foundation
import SwiftUI
import UIKit

struct ScanResultView: View {

  // MARK: Internal

  let mode: ScanResult
  let invitationURL: URL?
  let onClose: () -> Void

  var body: some View {
    List {
      header(title: mode.title)

      switch mode {
      case .credential(let credential, let trustInformation):
        credentialSections(credential: credential, trustInformation: trustInformation)
      case .presentation(let context):
        presentationSections(context: context)
      case .error(let error):
        errorSections(error: error)
      }
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
          onClose()
        } label: {
          Image(systemName: "xmark")
        }
      }
    }
    .task {
      logURL = ResultLogBuilder.buildLogURL(mode: mode, invitationURL: invitationURL)
    }
    .navigationBarBackButtonHidden()
  }

  // MARK: Private

  @Environment(\.colorScheme) private var colorScheme

  @State private var logURL: URL?
  @State private var selectedClaimLanguage: String?
  @State private var isClaimsExpanded = false
  @State private var useDarkCredentialCard = false

  private var cardColorScheme: ColorScheme {
    useDarkCredentialCard ? .dark : .light
  }

  @ViewBuilder
  private func credentialSections(credential: any CredentialProtocol, trustInformation: TrustInformation?) -> some View {
    if let verifiableCredential = credential as? VerifiableCredential {
      ClaimLanguageSection(
        locales: CredentialLocalizationSupport.availableClaimLocales(for: verifiableCredential.clusters),
        selectedLanguage: $selectedClaimLanguage)

      Section("Credential UI") {
        Toggle("Dark mode", isOn: $useDarkCredentialCard)
        VStack(spacing: .x6) {
          credentialCard(verifiableCredential, controlSize: .large, colorScheme: cardColorScheme)
          credentialCard(verifiableCredential, controlSize: .regular, colorScheme: cardColorScheme)
          credentialCard(verifiableCredential, controlSize: .small, colorScheme: cardColorScheme)
          credentialCard(verifiableCredential, controlSize: .mini, colorScheme: cardColorScheme)
        }
      }

      Section("Claims") {
        DisclosureGroup(isExpanded: $isClaimsExpanded) {
          compactClaimList(CredentialLocalizationSupport.localizedClusters(verifiableCredential.clusters, selectedLanguage: selectedClaimLanguage))
        } label: {
          Text("Show claims")
        }
      }

      trustInformationSection(trustInformation)

      invitationUrlSection(invitationURL)

      Section("Raw credential") {
        if let rawCredential = String(data: verifiableCredential.payload, encoding: .utf8) {
          Text(truncated(rawCredential))
            .copyShareMenu(text: rawCredential, shareItem: rawCredential)
        }
      }
    } else if let deferredCredential = credential as? DeferredCredential {
      Section("Deferred credential") {
        Text("Transaction ID: \(deferredCredential.transactionId)")
        Text("Format: \(deferredCredential.format)")
        Text("Progression: \(deferredCredential.progressionState.rawValue)")
        Text("Polling interval: \(deferredCredential.pollingInterval)s")
      }

      trustInformationSection(trustInformation)

      invitationUrlSection(invitationURL)
    } else {
      Section("Credential") {
        Text("Unavailable")
      }

      trustInformationSection(trustInformation)

      invitationUrlSection(invitationURL)
    }
  }

  @ViewBuilder
  private func presentationSections(context: PresentationRequestContext) -> some View {
    ClaimLanguageSection(
      locales: CredentialLocalizationSupport.availableClaimLocales(for: context.compatibleCredentials.flatMap(\.requestedClaimClusters)),
      selectedLanguage: $selectedClaimLanguage)

    Section("Credential UI") {
      if let credential = context.compatibleCredentials.first {
        credentialCard(credential.credential, controlSize: .regular, colorScheme: colorScheme)
      } else {
        Text("Unavailable")
      }
    }

    Section("Claims") {
      DisclosureGroup(isExpanded: $isClaimsExpanded) {
        ForEach(context.compatibleCredentials) { credential in
          VStack(alignment: .leading, spacing: .x2) {
            Text(credential.credentialName)
              .font(.custom.bodyEmphasized)
            if credential.requestedClaimClusters.isEmpty {
              Text("None")
                .font(.custom.footnote)
            } else {
              compactClaimList(CredentialLocalizationSupport.localizedClusters(credential.requestedClaimClusters, selectedLanguage: selectedClaimLanguage))
            }
          }
          .padding(.vertical, .x1)
        }
      } label: {
        Text("Show claims")
      }
    }

    trustInformationSection(context.trustInformation)

    invitationUrlSection(invitationURL)

    Section("Raw credential") {
      Text("Unavailable")
    }
  }

  @ViewBuilder
  private func errorSections(error: Error) -> some View {
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

      if let networkErr = error as? NetworkError {
        networkError(networkErr)
      }
    }
  }

  @ViewBuilder
  private func networkError(_ error: NetworkError) -> some View {
    Text("Network error status: \(networkError.status)")
    if let response = networkError.response {
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

  private func trustInformationSection(_ trustInformation: TrustInformation?) -> some View {
    Section("Trust information") {
      if let trustInformation {
        switch trustInformation.identity {
        case .trusted(let trustStatement):
          let name = trustStatement.getLocalizedEntityName(considering: Locale.preferredLanguages)
          if name.isEmpty {
            Text("Identity: trusted")
          } else {
            Text("Identity: trusted (\(name))")
          }
        case .untrusted:
          Text("Identity: untrusted")
        case .unknown:
          Text("Identity: unknown")
        }
        Text("VC Schema: \(trustInformation.vcSchema.rawValue)")
        switch trustInformation.actorCompliance {
        case .compliant?:
          Text("Actor compliance: compliant")
        case .notCompliant?:
          Text("Actor compliance: notCompliant")
        case nil:
          Text("Actor compliance: unknown")
        }
        if
          case .notCompliant(let reason) = trustInformation.actorCompliance,
          let localizedReason = reason.localized()
        {
          Text("Reason: \(localizedReason)")
        }
      } else {
        Text("Unavailable")
      }
    }
  }

  private func header(title: String) -> some View {
    Section {
      HStack {
        Spacer()
        VStack(alignment: .center) {
          Image(systemName: mode.headerSymbolName)
            .resizable()
            .foregroundStyle(mode.headerColor)
            .frame(width: 64, height: 64)

          Text(title)
        }
        Spacer()
      }
    }
  }

  private func invitationUrlSection(_ invitationURL: URL?) -> some View {
    Section("Invitation URL") {
      if let invitationURL {
        Text(invitationURL.absoluteString)
          .copyShareMenu(text: invitationURL.absoluteString, shareItem: invitationURL)
      } else {
        Text("Unavailable")
      }
    }
  }

  private func compactClaimList(_ clusters: [CredentialClaimCluster]) -> some View {
    ClaimClusterList(clusters)
      .padding(.leading, -.x6)
  }

  @ViewBuilder
  private func credentialCard(
    _ credential: VerifiableCredential,
    controlSize: ControlSize,
    colorScheme: ColorScheme)
    -> some View
  {
    let viewModel = CredentialLocalizationSupport.credentialCardViewModel(
      for: credential,
      selectedLanguage: selectedClaimLanguage,
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

  private func truncated(_ text: String, limit: Int = 100) -> String {
    guard text.count > limit else { return text }
    return String(text.prefix(limit)) + "..."
  }

}
