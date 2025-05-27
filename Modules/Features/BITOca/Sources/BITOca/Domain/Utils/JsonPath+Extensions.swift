import RegexBuilder

extension JsonPath {

  // MARK: Internal

  func validate(_ otherJsonPath: String) -> Bool {
    let otherPathSplit = otherJsonPath.split(separator: ".").map { String($0) }
    let pathSplit = split(separator: ".").map { String($0) }
    guard otherPathSplit.count == pathSplit.count else { return false }
    for (index, otherPathPart) in otherPathSplit.enumerated() {
      let pathPart = pathSplit[index]
      guard otherPathPart == pathPart || matchesWildcardArray(otherPathPart, wildcardArray: pathPart) else { return false }
    }
    return true
  }

  // MARK: Private

  private func matchesWildcardArray(_ indexArray: String, wildcardArray: String) -> Bool {
    guard
      let matchIndexArray = try? indexArrayRegex.wholeMatch(in: indexArray),
      let matchWildcardArray = try? wildcardArrayRegex.wholeMatch(in: wildcardArray)
    else {
      return false
    }
    return matchIndexArray.output.1 == matchWildcardArray.output.1
  }
}

private let indexArrayRegex = #/(\w+)\[\d+\]/#
private let wildcardArrayRegex = #/(\w+)\[\*\]/#
