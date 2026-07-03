import BITCore
import BITCredential
import BITCredentialShared
import SwiftUI

// MARK: - ClaimLanguagePicker

struct ClaimLanguagePicker: View {
  let locales: [String]
  @Binding var selectedLanguage: String?

  var body: some View {
    if !locales.isEmpty {
      Picker("Language", selection: $selectedLanguage) {
        Text("Auto").tag(nil as String?)
        ForEach(locales, id: \.self) { locale in
          Text(locale).tag(Optional(locale))
        }
      }
      .pickerStyle(.menu)
    }
  }
}

// MARK: - ClaimLanguageSection

struct ClaimLanguageSection: View {
  let locales: [String]
  @Binding var selectedLanguage: String?

  var body: some View {
    if !locales.isEmpty {
      Section {
        ClaimLanguagePicker(locales: locales, selectedLanguage: $selectedLanguage)
      }
    }
  }
}

// MARK: - CredentialLocalizationSupport

enum CredentialLocalizationSupport {

  // MARK: Internal

  static func availableClaimLocales(for clusters: [CredentialClaimCluster]) -> [String] {
    var locales = Set<String>()
    clusters.forEach { collectLocales(from: $0, into: &locales) }
    return locales.sorted()
  }

  static func localizedClusters(_ clusters: [CredentialClaimCluster], selectedLanguage: String?) -> [CredentialClaimCluster] {
    guard let selectedLanguage else { return clusters }
    return clusters.map { localizedCluster($0, preferredLanguageCode: selectedLanguage) }
  }

  static func credentialCardViewModel(
    for credential: VerifiableCredential,
    selectedLanguage: String?,
    colorSchemeName: String)
    -> VerifiableCredentialViewModel
  {
    var viewModel = VerifiableCredentialViewModel(credential: credential, colorScheme: colorSchemeName)
    if let display = credentialDisplay(for: credential, selectedLanguage: selectedLanguage, colorScheme: colorSchemeName) {
      viewModel.credentialDisplay = display
    }
    return viewModel
  }

  static func colorSchemeName(for scheme: ColorScheme) -> String {
    scheme == .dark ? "dark" : "light"
  }

  // MARK: Private

  private static func collectLocales(from cluster: CredentialClaimCluster, into locales: inout Set<String>) {
    cluster.displays.compactMap(\.locale).filter { !$0.isEmpty }.forEach { locales.insert($0) }
    for claim in cluster.claims {
      claim.displays.compactMap(\.locale).filter { !$0.isEmpty }.forEach { locales.insert($0) }
    }
    cluster.childClusters.forEach { collectLocales(from: $0, into: &locales) }
  }

  private static func localizedCluster(_ cluster: CredentialClaimCluster, preferredLanguageCode: String) -> CredentialClaimCluster {
    var cluster = cluster
    cluster.preferredDisplay = cluster.displays.findDisplayWithFallback(preferredLanguageCodes: [preferredLanguageCode])
    cluster.claims = cluster.claims.map { localizedClaim($0, preferredLanguageCode: preferredLanguageCode) }
    cluster.childClusters = cluster.childClusters.map { localizedCluster($0, preferredLanguageCode: preferredLanguageCode) }
    return cluster
  }

  private static func localizedClaim(_ claim: CredentialClaim, preferredLanguageCode: String) -> CredentialClaim {
    var claim = claim
    claim.preferredDisplay = claim.displays.findDisplayWithFallback(preferredLanguageCodes: [preferredLanguageCode])
      ?? CredentialClaimDisplay(name: claim.path.stringValue)
    return claim
  }

  private static func credentialDisplay(
    for credential: VerifiableCredential,
    selectedLanguage: String?,
    colorScheme: String)
    -> CredentialDisplay?
  {
    let displays = credential.displays
    let preferredDisplays = selectedLanguage
      .map { displays.findDisplaysWithFallback(preferredLanguageCodes: [$0]) }
      ?? displays.findDisplaysWithFallback()
    let display = preferredDisplays.first(where: { $0.theme == colorScheme }) ?? preferredDisplays.first
    return display?.resolvePathTemplate(with: credential.resolvedClusters)
  }
}
