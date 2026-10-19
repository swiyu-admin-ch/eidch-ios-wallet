import Foundation
import Testing

extension Result {
  func expectSuccess(_ expectedValue: Success, sourceLocation: SourceLocation = #_sourceLocation) where Success: Equatable {
    #expect((try? get()) == expectedValue, sourceLocation: sourceLocation)
  }

  func expectFailure<E: Error>(_ expectedType: E.Type, sourceLocation: SourceLocation = #_sourceLocation) {
    switch self {
    case .failure(let error):
      #expect(error is E, sourceLocation: sourceLocation)
    case .success:
      Issue.record("Expected failure of type \(E.self)", sourceLocation: sourceLocation) }
  }
}
