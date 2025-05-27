// MARK: - TypeDecodedCaptureBase

struct TypeDecodedCaptureBase: Decodable {

  // MARK: Lifecycle

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DecodingKeys.self)
    type = try? container.decode(CaptureBaseSpecType.self, forKey: .type)
    captureBase = try Self.decodeCaptureBase(type: type, decoder: decoder)
  }

  // MARK: Internal

  let type: CaptureBaseSpecType?
  let captureBase: (any CaptureBase)?

  // MARK: Private

  private enum DecodingKeys: String, CodingKey {
    case type
  }

  private static func decodeCaptureBase(type: CaptureBaseSpecType?, decoder: Decoder) throws -> (any CaptureBase)? {
    switch type {
    case .base1_0: try CaptureBase1x0(from: decoder)
    default: nil
    }
  }
}
