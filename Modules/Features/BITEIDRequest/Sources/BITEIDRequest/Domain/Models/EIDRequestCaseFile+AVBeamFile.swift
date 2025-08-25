import BITAVWrapper
import Foundation

extension EIDRequestCaseFile {
  init(_ file: AVBeamFile, category: Category) {
    self.init(fileName: file.description, mime: file.type, data: file.data, category: category)
  }
}
