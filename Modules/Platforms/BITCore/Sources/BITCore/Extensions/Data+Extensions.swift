import Foundation

extension Data {

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
}
