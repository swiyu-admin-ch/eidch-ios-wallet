import Factory

extension Container {

  public var jsonCanonicalizer: Factory<JsonCanonicalizerProtocol> {
    self { JsonCanonicalizer() }
  }

}
