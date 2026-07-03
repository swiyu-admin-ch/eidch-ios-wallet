import BITClaimsPathPointer

extension ClaimsPathPointer {
  var lastIndex: Int? {
    guard case .index(let index) = last else {
      return nil
    }
    return index
  }

  var lastString: [ClaimsPathPointerElement]? {
    if case .string(let string) = last {
      return [.string(string)]
    }

    if last == .null, dropLast().last?.isString == true {
      return Array(suffix(2))
    }

    return nil
  }

  var removedTrailingNull: ClaimsPathPointer {
    if last == .null {
      Array(dropLast())
    } else {
      self
    }
  }
}

extension ClaimsPathPointerElement {
  var isString: Bool {
    if case .string = self {
      return true
    }
    return false
  }
}
