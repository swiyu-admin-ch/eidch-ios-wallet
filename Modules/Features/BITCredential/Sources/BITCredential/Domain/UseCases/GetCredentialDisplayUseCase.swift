import BITCore
import BITCredentialShared
import Factory
import Spyable

// MARK: - GetCredentialDisplayUseCaseProtocol

@Spyable
public protocol GetCredentialDisplayUseCaseProtocol {
  func execute(for displays: [CredentialDisplay], colorScheme: String) -> CredentialDisplay?
}

// MARK: - GetCredentialDisplayUseCase

struct GetCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol {

  // MARK: Internal

  /// Get the preferred `CredentialDisplay` derived from given languages and color scheme
  ///
  /// If no display available that matches both language and color scheme, a fallback is calculated. The priority is:
  ///   1. matching language and theme
  ///   2. matching language, ignoring theme
  ///   3. fallback language and matching theme
  ///   4. fallback language, ignoring theme
  func execute(for displays: [CredentialDisplay], colorScheme: String) -> CredentialDisplay? {
    displays.findDisplaysWithFallback().first(where: { $0.theme == colorScheme }) ??
      displays.findDisplaysWithFallback().first
  }
}
