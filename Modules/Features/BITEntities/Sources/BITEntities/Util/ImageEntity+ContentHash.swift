import Foundation

extension ImageEntity {

  // MARK: Lifecycle

  public convenience init(_ image: Data) {
    self.init()
    self.image = image
    updateContentHash()
  }

  // MARK: Public

  public static func contentHash(of image: Data) -> String {
    ImageEntity(image).contentHash
  }

  public static func contentHash(of image: Data?) -> String? {
    image.map(contentHash(of:))
  }
}
