import BITCredentialShared
import SwiftUI

struct CredentialRow: View {

  // MARK: Lifecycle

  init(_ credential: any CredentialProtocol) {
    self.credential = credential
  }

  // MARK: Internal

  var body: some View {
    HStack {
      Text(credential.displays.first?.name ?? "Unknown")
      if credential is DeferredCredential {
        Text("Deferred")
          .font(.custom.caption2)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(.secondary.opacity(0.15))
          .clipShape(Capsule())
      }
      Spacer()
      Text(credential.createdAt, style: .time)
        .font(.custom.footnote)
    }
  }

  // MARK: Private

  private let credential: any CredentialProtocol

}
