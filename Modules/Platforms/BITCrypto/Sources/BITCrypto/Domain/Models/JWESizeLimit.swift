// MARK: - JWESizeLimit

public struct JWESizeLimit: Equatable, Sendable {

  public init(maxDecompressedSize: Int, maxCompressedCipherTextLength: Int) {
    self.maxDecompressedSize = maxDecompressedSize
    self.maxCompressedCipherTextLength = maxCompressedCipherTextLength
  }

  let maxDecompressedSize: Int
  let maxCompressedCipherTextLength: Int
}

#if DEBUG
extension JWESizeLimit {

  struct Mock {
    static let sample = JWESizeLimit(maxDecompressedSize: 1024, maxCompressedCipherTextLength: 8 * 1024)
    static let bigSample = JWESizeLimit(maxDecompressedSize: 20 * 1024 * 1024, maxCompressedCipherTextLength: 6_000_000)
  }

}
#endif
