import BITCore
import BITCredential
import BITCredentialShared
import BITTheming
import SwiftUI

// MARK: - DetailView

struct DetailView: View {

  // MARK: Lifecycle

  init(credential: any CredentialProtocol) {
    self.credential = credential
  }

  // MARK: Internal

  var body: some View {
    List {
      if let verifiableCredential = credential as? VerifiableCredential {
        verifiableCredentialSections(credential: verifiableCredential)
      } else if let deferredCredential = credential as? DeferredCredential {
        deferredCredentialSections(credential: deferredCredential)
      } else {
        Section("Credential") {
          Text("Unsupported credential type.")
        }
      }
    }
    .navigationTitle("Credential")
  }

  // MARK: Private

  @State private var selectedClaimLanguage: String?
  @State private var useDarkCredentialCard = false

  private let credential: any CredentialProtocol

  private var cardColorScheme: ColorScheme {
    useDarkCredentialCard ? .dark : .light
  }

  @ViewBuilder
  private func verifiableCredentialSections(credential: VerifiableCredential) -> some View {
    ClaimLanguageSection(
      locales: CredentialLocalizationSupport.availableClaimLocales(for: credential.clusters),
      selectedLanguage: $selectedClaimLanguage)

    Section("Credential UI") {
      Toggle("Dark mode", isOn: $useDarkCredentialCard)
      VStack(spacing: .x6) {
        credentialCard(credential, controlSize: .large, colorScheme: cardColorScheme)
        credentialCard(credential, controlSize: .regular, colorScheme: cardColorScheme)
        credentialCard(credential, controlSize: .small, colorScheme: cardColorScheme)
        credentialCard(credential, controlSize: .mini, colorScheme: cardColorScheme)
      }
    }

    Section("Claims") {
      compactClaimList(CredentialLocalizationSupport.localizedClusters(credential.clusters, selectedLanguage: selectedClaimLanguage))
    }
  }

  @ViewBuilder
  private func deferredCredentialSections(credential: DeferredCredential) -> some View {
    Section("Credential UI") {
      Toggle("Dark mode", isOn: $useDarkCredentialCard)
      VStack(spacing: .x6) {
        deferredCredentialCard(credential, controlSize: .large, colorScheme: cardColorScheme)
        deferredCredentialCard(credential, controlSize: .regular, colorScheme: cardColorScheme)
        deferredCredentialCard(credential, controlSize: .small, colorScheme: cardColorScheme)
        deferredCredentialCard(credential, controlSize: .mini, colorScheme: cardColorScheme)
      }
    }

    Section("Deferred credential") {
      Text("Transaction ID: \(credential.transactionId)")
      Text("Format: \(credential.format)")
      Text("Progression: \(credential.progressionState.rawValue)")
      Text("Polling interval: \(credential.pollingInterval)s")
      Text("Endpoint: \(credential.endpoint)")
      if let selectedConfigurationId = credential.selectedConfigurationId {
        Text("Selected configuration ID: \(selectedConfigurationId)")
      }
      if let polledAt = credential.polledAt {
        Text("Last polled: \(polledAt.formatted())")
      }
    }

    if let issuer = credential.issuerDisplays.findDisplayWithFallback() {
      Section("Issuer") {
        Text(issuer.name ?? "Unknown")
      }
    }
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

  @ViewBuilder
  private func deferredCredentialCard(
    _ credential: DeferredCredential,
    controlSize: ControlSize,
    colorScheme: ColorScheme)
    -> some View
  {
    let viewModel = DeferredCredentialViewModel(
      credential: credential,
      colorScheme: CredentialLocalizationSupport.colorSchemeName(for: colorScheme))
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

  private func compactClaimList(_ clusters: [CredentialClaimCluster]) -> some View {
    ClaimClusterList(clusters)
      .padding(.leading, -.x6)
  }

}

#Preview {
  DetailView(credential: VerifiableCredential.Mock.sample)
}
