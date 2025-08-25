import Foundation

extension JSONEncoder {

  public convenience init(outputFormatting: JSONEncoder.OutputFormatting) {
    self.init()
    self.outputFormatting = outputFormatting
  }
}
