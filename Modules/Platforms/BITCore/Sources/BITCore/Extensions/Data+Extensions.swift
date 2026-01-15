import Compression
import Foundation

// MARK: - DecompressionError

enum DecompressionError: Error {
  case limitReached
}

extension Data {

  // MARK: Public

  public func compressed(using algorithm: NSData.CompressionAlgorithm = .zlib) throws -> Data {
    let nsData = self as NSData
    let compressedData = try nsData.compressed(using: algorithm)
    return Data(referencing: compressedData)
  }

  public func decompressed(using algorithm: NSData.CompressionAlgorithm = .zlib, ignoreHeaderBytes: Bool = true) throws -> Data {
    var data = self
    if ignoreHeaderBytes {
      data = data.dropFirst(2)
    }
    let nsData = data as NSData
    return try nsData.decompressed(using: algorithm) as Data
  }

  public func decompressedWithLimit(_ limit: Int = 100 * 1024 * 1024, using algorithm: Algorithm = .zlib, ignoreHeaderBytes: Bool = true, pageSize: Int = 4096) throws -> Data {
    var data = self
    if ignoreHeaderBytes {
      data = data.dropFirst(2)
    }
    return try decompressInPages(data, using: algorithm, limit: limit, pageSize: pageSize)
  }

  // MARK: Private

  private func decompressInPages(_ data: Data, using algorithm: Algorithm, limit: Int, pageSize: Int) throws -> Data {
    var index = data.startIndex
    let inputFilter = try InputFilter(.decompress, using: algorithm, bufferCapacity: pageSize, readingFrom: { (length: Int) -> Data? in
      let rangeLength = Swift.min(length, data.count - index + data.startIndex)
      let subdata = data.subdata(in: index..<index + rangeLength)
      index += rangeLength
      return subdata
    })
    var decompressedData = Data()
    while let page = try inputFilter.readData(ofLength: pageSize) {
      decompressedData.append(page)
      guard decompressedData.count <= limit else { throw DecompressionError.limitReached }
    }
    return decompressedData
  }
}
