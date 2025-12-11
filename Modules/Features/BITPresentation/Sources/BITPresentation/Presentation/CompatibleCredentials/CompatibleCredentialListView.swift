import BITCredential
import BITCredentialShared
import BITTheming
import Foundation
import SwiftUI

// MARK: - CompatibleCredentialListView

public struct CompatibleCredentialListView: View {

  // MARK: Lifecycle

  public init(viewModels: [VerifiableCredentialViewModel] = [], _ didSelect: @escaping (VerifiableCredentialViewModel) -> Void) {
    self.viewModels = viewModels
    self.didSelect = didSelect
  }

  // MARK: Public

  public var body: some View {
    ForEach(Array(zip(viewModels.indices, viewModels)), id: \.0) { _, viewModel in
      Button(action: { didSelect(viewModel) }, label: {
        VerifiableCredentialCell(viewModel, disclosureIndicator: .navigation)
      })
    }
  }

  // MARK: Private

  private var viewModels = [VerifiableCredentialViewModel]()
  private var didSelect: (VerifiableCredentialViewModel) -> Void
}
