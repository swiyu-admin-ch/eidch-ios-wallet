import BITTheming
import SwiftUI

// MARK: - RequestCasesListView

public struct RequestCasesListView: View {

  // MARK: Lifecycle

  public init(_ requestCases: [RequestCaseViewState]) {
    self.requestCases = requestCases
  }

  // MARK: Public

  public var body: some View {
    Section {
      ForEach(requestCases) { requestCase in
        VStack {
          requestCase.view()
        }
        .padding(.x6)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .cornerRadius(.x5)
      }
    }
  }

  // MARK: Private

  private let requestCases: [RequestCaseViewState]
}
