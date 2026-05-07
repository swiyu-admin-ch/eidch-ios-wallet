import BITAnyCredentialFormat
import Foundation

struct VcSdJwtDescriptorMapGenerator: AnyDescriptorMapGeneratorProtocol {
  func generate(using inputDescriptor: InputDescriptor, vcFormat: String) throws -> [AuthorizationResponse.DescriptorMap] {
    [
      AuthorizationResponse.DescriptorMap(id: inputDescriptor.id, format: vcFormat, path: "$"),
    ]
  }
}
