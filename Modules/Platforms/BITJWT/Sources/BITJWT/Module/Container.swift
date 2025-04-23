import Factory
import Foundation

extension Container {

  // MARK: Public

  public var jwsSignatureValidator: Factory<JWSSignatureValidatorProtocol> {
    self { JWSSignatureValidator() }
  }

  public var jwsDecoder: Factory<JWSDecoderProtocol> {
    self { JWSDecoder() }
  }

  public var jwsEncoder: Factory<JWSEncoderProtocol> {
    self { JWSEncoder() }
  }

  // MARK: Internal

  var didResolverHelper: Factory<DidResolverHelperProtocol> {
    self { DidResolverHelper() }
  }

  var didResolverRepository: Factory<DidResolverRepositoryProtocol> {
    self { DidResolverRepository() }
  }

}
