import Factory

extension Container {

  public var sdJwsDecoder: Factory<SdJWSDecoderProtocol> {
    self { SdJWSDecoder(strictPayloadDecoding: true) }
  }

}
