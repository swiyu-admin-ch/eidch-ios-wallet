import BITCredential
import SwiftUI

// MARK: - HomeCredentialsList

struct HomeCredentialsList: View {

  // MARK: Lifecycle

  init(_ credentials: [any CredentialViewModelProtocol], onSelect: @escaping (any CredentialViewModelProtocol) -> Void) {
    self.credentials = credentials
    self.onSelect = onSelect
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case credential
  }

  var body: some View {
    ForEach(credentials, id: \.id) { credential in
      Button(action: { onSelect(credential) }, label: {
        AnyView(credential.view())
      })
      .accessibilityIdentifier(AccessibilityIdentifier.credential.rawValue)
    }
  }

  // MARK: Private

  private let credentials: [any CredentialViewModelProtocol]
  private let onSelect: (any CredentialViewModelProtocol) -> Void
}
