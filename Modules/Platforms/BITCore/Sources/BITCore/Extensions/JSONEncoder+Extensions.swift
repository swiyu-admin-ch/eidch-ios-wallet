import Foundation

extension JSONEncoder {

  public convenience init(outputFormatting: JSONEncoder.OutputFormatting = [], dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate) {
    self.init()
    self.outputFormatting = outputFormatting
    self.dateEncodingStrategy = dateEncodingStrategy
  }
}
