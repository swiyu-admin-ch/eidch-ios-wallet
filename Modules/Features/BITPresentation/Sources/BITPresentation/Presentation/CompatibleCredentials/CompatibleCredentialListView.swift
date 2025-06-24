import BITCredential
import BITCredentialShared
import BITTheming
import Foundation
import SwiftUI

// MARK: - CompatibleCredentialListView

public struct CompatibleCredentialListView: View {

  // MARK: Lifecycle

  public init(viewModels: [CredentialViewModel] = [], _ didSelect: @escaping (CredentialViewModel) -> Void) {
    self.viewModels = viewModels
    self.didSelect = didSelect
  }

  // MARK: Public

  public var body: some View {
    ForEach(Array(zip(viewModels.indices, viewModels)), id: \.0) { _, viewModel in
      Button(action: { didSelect(viewModel) }, label: {
        CredentialCell(viewModel, disclosureIndicator: .navigation)
      })
    }
  }

  // MARK: Private

  private var viewModels: [CredentialViewModel] = []
  private var didSelect: (CredentialViewModel) -> Void
}
