import BITAVWrapper

extension AVBeamFile {

  public init(_ requestCaseFile: EIDRequestCaseFile) {
    self.init(type: requestCaseFile.mime, description: requestCaseFile.fileName, data: requestCaseFile.data)
  }
}
