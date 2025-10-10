import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - DocumentSelectionView

struct DocumentSelectionView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.documentSelectionViewModel(router))
  }

  // MARK: Internal

  var body: some View {
    List {
      Section {
        DocumentSelectionCell(image: Assets.swissIDCard.swiftUIImage, name: L10n.tkEidRequestDocumentSelectionIdCard) {
          viewModel.didSelect(.identityCard)
        }
        DocumentSelectionCell(image: Assets.passport.swiftUIImage, name: L10n.tkEidRequestDocumentSelectionPassport) {
          viewModel.didSelect(.passport)
        }
        DocumentSelectionCell(image: Assets.bPermit.swiftUIImage, name: L10n.tkEidRequestDocumentSelectionResidentPermit) {
          viewModel.didSelect(.foreignerPermit)
        }

        Spacer()
          .frame(height: 0)
      } header: {
        VStack(alignment: .leading, spacing: .x6) {
          Text(L10n.tkEidRequestDocumentSelectionPrimary)
            .font(.custom.title)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
            .multilineTextAlignment(.leading)
          Text(L10n.tkEidRequestDocumentSelectionSecondary)
            .font(.custom.body)
            .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
            .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
            .multilineTextAlignment(.leading)
        }
        .textCase(.none)
        .padding(.bottom, .x6)
      }

      Section {
        DocumentSelectionCell(image: Image(systemName: "person.text.rectangle"), name: "Mock MRZ data") {
          viewModel.mrzMockData()
        }
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.grouped)
    .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  @StateObject private var viewModel: DocumentSelectionViewModel
}

#Preview {
  NavigationView {
    DocumentSelectionView(router: EIDRequestRouter())
  }
}
