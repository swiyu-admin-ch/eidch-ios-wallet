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
        requestCase.view()
      }
    }
  }

  // MARK: Private

  private let requestCases: [RequestCaseViewState]
}
