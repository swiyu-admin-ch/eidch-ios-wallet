import BITCredential
import BITCredentialShared
import BITDeeplink
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - HomeView

struct HomeView: View {

  // MARK: Internal

  var body: some View {
    NavigationStack {
      List {
        ForEach(credentials, id: \.id) { credential in
          NavigationLink {
            DetailView(credential: credential)
          } label: {
            credentialRow(credential)
          }
        }
        .onDelete(perform: deleteCredentials)
      }
      .overlay {
        if credentials.isEmpty {
          ContentUnavailableView("No credentials", systemImage: "person.text.rectangle.fill")
        }
      }
    }
    .safeAreaInset(edge: .bottom) {
      Button(action: { scannerRequest = ScannerRequest(url: nil) }, label: {
        Label(title: { Text(L10n.tkGlobalScanPrimarybutton) }, icon: { Image(systemName: "qrcode") })
          .frame(maxWidth: .infinity)
          .padding()
      })
      .buttonStyle(.primary)
      .padding(.horizontal, .defaultHorizontal)
    }
    .refreshable {
      await fetchCredentials()
    }
    .onAppear {
      Task {
        await fetchCredentials()
      }
    }
    .onOpenURL { url in
      guard (try? deeplinkManager.dispatchFirst(url)) != nil else { return }
      scannerRequest = ScannerRequest(url: url)
    }
    .sheet(item: $scannerRequest, onDismiss: {
      Task {
        await fetchCredentials()
      }
    }) {
      ScanCameraView(url: $0.url)
    }
  }

  // MARK: Private

  @State private var scannerRequest: ScannerRequest?
  @State private var credentials = [any CredentialProtocol]()

  private let deeplinkManager = DeeplinkManager(allowedRoutes: RootDeeplinkRoute.allCases)

  @Injected(\.credentialRepository) private var credentialRepository: CredentialRepositoryProcotol

  private func credentialRow(_ credential: any CredentialProtocol) -> some View {
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

  @MainActor
  private func fetchCredentials() async {
    do {
      let result = try await credentialRepository.getAll()
      withAnimation(.easeInOut) {
        credentials = result
      }
    } catch {
      // Ignore fetch errors in debugger UI.
    }
  }

  private func deleteCredentials(at offsets: IndexSet) {
    Task {
      let ids = offsets.map { credentials[$0].id }
      for id in ids {
        try? await credentialRepository.delete(id)
      }
      await fetchCredentials()
    }
  }

}

// MARK: - ScannerRequest

private struct ScannerRequest: Identifiable {
  let id = UUID()
  let url: URL?
}

#Preview {
  HomeView()
}
