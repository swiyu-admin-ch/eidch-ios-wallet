import BITAVWrapper
import DeviceKit
import Spyable
import UIKit
import XMLCoder

// MARK: - UpdateInputFileUseCaseProtocol

@Spyable
protocol UpdateInputFileUseCaseProtocol {
  func callAsFunction() throws -> AVBeamFile
}

// MARK: - UpdateInputFileUseCase

struct UpdateInputFileUseCase: UpdateInputFileUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() throws -> AVBeamFile {
    guard let inputXmlFile = Bundle.main.url(forResource: "input", withExtension: "xml") else {
      throw UpdateInputFileUseCaseError.cannotFindInputFile
    }
    let updatedFile = try updateFile(inputXmlFile)

    return AVBeamFile(type: .xml, description: Self.inputFileKey, data: updatedFile)
  }

  // MARK: Private

  private static let inputFileKey = "input.xml"
  private static let inputFileRootKey = "inputDocScan"

  private func updateFile(_ file: URL) throws -> Data {
    let fileData = try Data(contentsOf: file)
    let device = Device.current.description
    let osVersion = "iOS \(UIDevice.current.systemVersion)"

    var inputFile = try XMLDecoder().decode(InputFile.self, from: fileData)
    inputFile.metadata = InputFile.Metadata(deviceModelType: device, osVersion: osVersion)

    return try XMLEncoder().encode(inputFile, withRootKey: Self.inputFileRootKey, header: XMLHeader(version: 1.0, encoding: "UTF-8"))
  }
}

// MARK: - UpdateInputFileUseCaseError

enum UpdateInputFileUseCaseError: Error {
  case cannotFindInputFile
}
