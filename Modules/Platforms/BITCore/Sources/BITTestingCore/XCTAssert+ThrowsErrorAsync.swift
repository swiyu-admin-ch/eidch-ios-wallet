import XCTest

public func XCTAssertThrowsErrorAsync(
  _ expression: @autoclosure () async throws -> some Any,
  file: StaticString = #filePath,
  line: UInt = #line,
  _ errorHandler: (Error) -> Void = { _ in }) async
{
  do {
    _ = try await expression()
    // expected error to be thrown, but it was not
    XCTFail("Asynchronous call did not throw an error.", file: file, line: line)
  } catch {
    errorHandler(error)
  }
}
