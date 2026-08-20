import BITCore
import BITCredential
import BITCredentialShared
import BITTheming
import Factory
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
      DetailContent(
        credential: credential,
        isFetchingDeferredCredential: isFetchingDeferredCredential,
        fetchDeferredCredential: triggerDeferredCredentialFetch)
    }
    .navigationTitle("Credential")
    .alert("Fetch failed", isPresented: showsFetchError) {
      Button("OK", role: .cancel) { }
    } message: {
      Text(fetchErrorMessage ?? "Unknown error.")
    }
  }

  // MARK: Private

  @State private var isFetchingDeferredCredential = false
  @State private var fetchErrorMessage: String?

  @Environment(\.dismiss) private var dismiss

  private let credential: any CredentialProtocol

  @Injected(\.refreshCredentialsUseCase) private var refreshCredentialsUseCase: RefreshCredentialsUseCaseProtocol
  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProtocol

  private var showsFetchError: Binding<Bool> {
    Binding(
      get: { fetchErrorMessage != nil },
      set: { isPresented in
        if !isPresented {
          fetchErrorMessage = nil
        }
      })
  }

  private func triggerDeferredCredentialFetch(_ credential: DeferredCredential) {
    Task {
      await MainActor.run {
        isFetchingDeferredCredential = true
        fetchErrorMessage = nil
      }

      do {
        var forcedDeferredCredential = credential
        forcedDeferredCredential.polledAt = nil
        _ = try await credentialRepository.update(deferredCredential: forcedDeferredCredential)

        _ = try await refreshCredentialsUseCase()

        await MainActor.run {
          isFetchingDeferredCredential = false
          dismiss()
        }
      } catch {
        await MainActor.run {
          isFetchingDeferredCredential = false
          fetchErrorMessage = error.localizedDescription
        }
      }
    }
  }

}

// MARK: - DetailContent

private struct DetailContent: View {

  let credential: any CredentialProtocol
  let isFetchingDeferredCredential: Bool
  let fetchDeferredCredential: (DeferredCredential) -> Void

  var body: some View {
    if let verifiableCredential = credential as? VerifiableCredential {
      VerifiableCredentialDetailSections(credential: verifiableCredential)
    } else if let deferredCredential = credential as? DeferredCredential {
      DeferredCredentialDetailSections(
        credential: deferredCredential,
        isFetchingDeferredCredential: isFetchingDeferredCredential,
        fetchDeferredCredential: fetchDeferredCredential)
    } else {
      Section("Credential") {
        Text("Unsupported credential type.")
      }
    }
  }
}

// MARK: - VerifiableCredentialDetailSections

private struct VerifiableCredentialDetailSections: View {

  // MARK: Internal

  let credential: VerifiableCredential

  var body: some View {
    ClaimLanguageSection(
      locales: CredentialLocalizationSupport.availableClaimLocales(for: credential.resolvedClusters),
      selectedLanguage: $selectedClaimLanguage)

    VerifiableCredentialUISection(
      credential: credential,
      selectedLanguage: selectedClaimLanguage,
      useDarkCredentialCard: $useDarkCredentialCard)

    Section("Claims") {
      ClaimClusterList(CredentialLocalizationSupport.localizedClusters(credential.resolvedClusters, selectedLanguage: selectedClaimLanguage))
        .padding(.leading, -.x6)
    }
  }

  // MARK: Private

  @State private var selectedClaimLanguage: String?
  @State private var useDarkCredentialCard = false

}

// MARK: - DeferredCredentialDetailSections

private struct DeferredCredentialDetailSections: View {

  // MARK: Internal

  let credential: DeferredCredential
  let isFetchingDeferredCredential: Bool
  let fetchDeferredCredential: (DeferredCredential) -> Void

  var body: some View {
    Section("Actions") {
      Button(action: { fetchDeferredCredential(credential) }) {
        HStack {
          Text("Fetch credential")
          Spacer()
          if isFetchingDeferredCredential {
            ProgressView()
          }
        }
      }
      .disabled(isFetchingDeferredCredential)
    }

    DeferredCredentialUISection(
      credential: credential,
      useDarkCredentialCard: $useDarkCredentialCard)

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

  // MARK: Private

  @State private var useDarkCredentialCard = false

}

// MARK: - VerifiableCredentialUISection

private struct VerifiableCredentialUISection: View {

  // MARK: Internal

  let credential: VerifiableCredential
  let selectedLanguage: String?

  @Binding var useDarkCredentialCard: Bool

  var body: some View {
    Section("Credential UI") {
      Toggle("Dark mode", isOn: $useDarkCredentialCard)
      VStack(spacing: .x6) {
        VerifiableCredentialCardPreview(credential: credential, selectedLanguage: selectedLanguage, controlSize: .large, colorScheme: cardColorScheme)
        VerifiableCredentialCardPreview(credential: credential, selectedLanguage: selectedLanguage, controlSize: .regular, colorScheme: cardColorScheme)
        VerifiableCredentialCardPreview(credential: credential, selectedLanguage: selectedLanguage, controlSize: .small, colorScheme: cardColorScheme)
        VerifiableCredentialCardPreview(credential: credential, selectedLanguage: selectedLanguage, controlSize: .mini, colorScheme: cardColorScheme)
      }
    }
  }

  // MARK: Private

  private var cardColorScheme: ColorScheme {
    useDarkCredentialCard ? .dark : .light
  }
}

// MARK: - DeferredCredentialUISection

private struct DeferredCredentialUISection: View {

  // MARK: Internal

  let credential: DeferredCredential

  @Binding var useDarkCredentialCard: Bool

  var body: some View {
    Section("Credential UI") {
      Toggle("Dark mode", isOn: $useDarkCredentialCard)
      VStack(spacing: .x6) {
        DeferredCredentialCardPreview(credential: credential, controlSize: .large, colorScheme: cardColorScheme)
        DeferredCredentialCardPreview(credential: credential, controlSize: .regular, colorScheme: cardColorScheme)
        DeferredCredentialCardPreview(credential: credential, controlSize: .small, colorScheme: cardColorScheme)
        DeferredCredentialCardPreview(credential: credential, controlSize: .mini, colorScheme: cardColorScheme)
      }
    }
  }

  // MARK: Private

  private var cardColorScheme: ColorScheme {
    useDarkCredentialCard ? .dark : .light
  }
}

// MARK: - VerifiableCredentialCardPreview

private struct VerifiableCredentialCardPreview: View {

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

// MARK: - DeferredCredentialCardPreview

private struct DeferredCredentialCardPreview: View {

  let credential: DeferredCredential
  let controlSize: ControlSize
  let colorScheme: ColorScheme

  var body: some View {
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
}

#if DEBUG
#Preview {
  DetailView(credential: VerifiableCredential.Mock.sample)
}
#endif
