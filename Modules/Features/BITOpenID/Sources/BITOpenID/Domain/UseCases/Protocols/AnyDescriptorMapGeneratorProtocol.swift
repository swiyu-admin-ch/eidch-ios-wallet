import Foundation
import Spyable

// MARK: - AnyDescriptorMapGeneratorProtocol

@Spyable
public protocol AnyDescriptorMapGeneratorProtocol {
  func generate(using inputDescriptor: InputDescriptor, vcFormat: String) throws -> [AuthorizationResponse.DescriptorMap]
}
