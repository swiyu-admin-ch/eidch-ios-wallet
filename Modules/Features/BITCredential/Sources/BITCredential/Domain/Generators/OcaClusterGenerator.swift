import BITClaimsPathPointer
import BITCore
import BITCredentialShared
import BITOca
import Factory
import Spyable

// MARK: - OcaClusterGeneratorProtocol

@Spyable
protocol OcaClusterGeneratorProtocol {
  func generate(
    from payload: JSON,
    credentialFormat: String,
    ocaBundle: OcaBundle) throws
    -> [CredentialClaimCluster]
}

// MARK: - OcaClusterGenerator

struct OcaClusterGenerator: OcaClusterGeneratorProtocol {

  // MARK: Internal

  func generate(
    from payload: JSON,
    credentialFormat: String,
    ocaBundle: OcaBundle) throws
    -> [CredentialClaimCluster]
  {
    var credentialClaims = createCredentialClaims(from: payload)
    let rootCluster = try createCluster(
      credentialClaims: &credentialClaims,
      credentialFormat: credentialFormat,
      ocaBundle: ocaBundle,
      captureBaseDigest: ocaBundle.rootCaptureBaseDigest,
      path: [])

    var index = 0
    var clusters = expandChildCluster(for: rootCluster, index: &index)

    if let clusterWithoutOca = try createClusterWithoutOca(from: credentialClaims) {
      clusters.append(clusterWithoutOca)
    }

    return clusters
  }

  // MARK: Private

  @Injected(\.ocaClaimGenerator) private var ocaClaimGenerator: OcaClaimGeneratorProtocol

  private func expandChildCluster(for cluster: CredentialClaimCluster, index: inout Int) -> [CredentialClaimCluster] {
    var clusters = [CredentialClaimCluster]()
    if cluster.claims.isEmpty && !cluster.childClusters.isEmpty {
      clusters = cluster.childClusters
        .sorted { $0.order < $1.order }
        .flatMap { expandChildCluster(for: $0, index: &index) }
    } else {
      var cluster = cluster
      cluster.order = index
      index += 1
      clusters = [cluster]
    }
    return clusters
  }

  private func createCluster(
    credentialClaims: inout [ClaimsPathPointer: Any],
    credentialFormat: String,
    ocaBundle: OcaBundle,
    captureBaseDigest: String,
    ocaAttribute: OverlayBundleAttribute? = nil,
    path: ClaimsPathPointer) throws
    -> CredentialClaimCluster
  {
    var claims = [CredentialClaim]()
    var childClusters = [CredentialClaimCluster]()

    for ocaAttribute in ocaBundle.getAttributes(digest: captureBaseDigest) {
      if let dataSource = ocaAttribute.dataSources[credentialFormat] {
        let elementPath = dataSource.resolveNullElement(with: path.allIndices)
        let element = try createElement(
          attributeType: ocaAttribute.attributeType,
          ocaAttribute: ocaAttribute,
          credentialClaims: &credentialClaims,
          credentialFormat: credentialFormat,
          ocaBundle: ocaBundle,
          path: elementPath)
        switch element {
        case .claim(let claim)?:
          claims.append(claim)
        case .cluster(let cluster)?:
          childClusters.append(cluster)
        case nil:
          break
        }
        continue
      }

      if ocaAttribute.dataSources[credentialFormat] == nil, case .reference(let digest) = ocaAttribute.attributeType {
        let cluster = try createCluster(
          credentialClaims: &credentialClaims,
          credentialFormat: credentialFormat,
          ocaBundle: ocaBundle,
          captureBaseDigest: digest,
          ocaAttribute: ocaAttribute,
          path: [])
        childClusters.append(cluster)
      }
    }

    return CredentialClaimCluster(
      path: path,
      order: path.lastIndex ?? ocaAttribute?.order ?? -1,
      isSensitive: ocaAttribute?.isSensitive ?? false,
      claims: claims,
      childClusters: childClusters,
      displays: createClusterDisplays(from: ocaAttribute?.labels ?? [:]))
  }

  private func createElement(
    attributeType: AttributeType,
    ocaAttribute: OverlayBundleAttribute?,
    credentialClaims: inout [ClaimsPathPointer: Any],
    credentialFormat: String,
    ocaBundle: OcaBundle,
    path: ClaimsPathPointer) throws
    -> GeneratedElement?
  {
    let elementPath = getElementPath(
      for: path,
      attributeType: attributeType,
      credentialClaims: credentialClaims)
    var element: Any?
    if let elementPath {
      element = credentialClaims.removeValue(forKey: elementPath)
    }

    switch attributeType {
    case .array(let nestedAttributeType):
      if let arrayPath = elementPath, let array = element as? [Any] {
        let cluster = try createArrayCluster(
          nestedAttributeType: nestedAttributeType,
          from: array,
          credentialClaims: &credentialClaims,
          credentialFormat: credentialFormat,
          ocaBundle: ocaBundle,
          ocaAttribute: ocaAttribute,
          path: arrayPath)
        return .cluster(cluster)
      }

      guard let primitive = JsonPrimitive(element) else {
        return nil
      }

      return try .claim(createClaim(
        from: primitive,
        path: path,
        ocaAttribute: nil))

    case .reference(let digest):
      let cluster = try createCluster(
        credentialClaims: &credentialClaims,
        credentialFormat: credentialFormat,
        ocaBundle: ocaBundle,
        captureBaseDigest: digest,
        ocaAttribute: ocaAttribute,
        path: path)
      return .cluster(cluster)

    default:
      guard let primitive = JsonPrimitive(element) else {
        return nil
      }

      return try .claim(createClaim(
        from: primitive,
        path: path,
        ocaAttribute: ocaAttribute))
    }
  }

  private func createArrayCluster(
    nestedAttributeType: AttributeType,
    from array: [Any],
    credentialClaims: inout [ClaimsPathPointer: Any],
    credentialFormat: String,
    ocaBundle: OcaBundle,
    ocaAttribute: OverlayBundleAttribute?,
    path: ClaimsPathPointer) throws
    -> CredentialClaimCluster
  {
    let arrayParentPath = path.last == .null ? Array(path.dropLast()) : path
    var claims = [CredentialClaim]()
    var childClusters = [CredentialClaimCluster]()

    for index in array.indices {
      var currentPath = arrayParentPath + [.index(index)]
      if case .array = nestedAttributeType {
        currentPath += [.null]
      }

      let element = try createElement(
        attributeType: nestedAttributeType,
        ocaAttribute: nestedAttributeType.referenceDigest == nil ? nil : ocaAttribute,
        credentialClaims: &credentialClaims,
        credentialFormat: credentialFormat,
        ocaBundle: ocaBundle,
        path: currentPath)

      switch element {
      case .claim(let claim)?:
        claims.append(claim)
      case .cluster(let cluster)?:
        childClusters.append(cluster)
      case nil:
        continue
      }
    }

    var displays = [ClusterDisplay]()
    if let labels = ocaAttribute?.labels, nestedAttributeType.referenceDigest == nil {
      // only add displays for arrays that have no nested cluster
      displays = createClusterDisplays(from: labels)
    }
    return CredentialClaimCluster(
      path: path,
      order: arrayParentPath.lastIndex ?? ocaAttribute?.order ?? -1,
      isSensitive: ocaAttribute?.isSensitive ?? false,
      claims: claims,
      childClusters: childClusters,
      displays: displays)
  }

  private func createClaim(
    from value: JsonPrimitive,
    path: ClaimsPathPointer,
    ocaAttribute: OverlayBundleAttribute?) throws
    -> CredentialClaim
  {
    try ocaClaimGenerator.generate(
      path: path,
      value: value.stringValue,
      ocaAttribute: ocaAttribute,
      order: path.lastIndex)
  }

  private func createClusterDisplays(from labels: [String: String]) -> [ClusterDisplay] {
    labels.map { locale, label in
      ClusterDisplay(locale: locale, name: label)
    }
  }

  private func createClusterWithoutOca(from credentialClaims: [ClaimsPathPointer: Any]) throws -> CredentialClaimCluster? {
    let claims: [CredentialClaim] = try credentialClaims.compactMap { path, value in
      guard let primitive = JsonPrimitive(value) else {
        return nil
      }
      return try createClaim(
        from: primitive,
        path: path,
        ocaAttribute: nil)
    }

    guard !claims.isEmpty else {
      return nil
    }

    return CredentialClaimCluster(
      path: [],
      order: -1,
      claims: claims)
  }

  private func createCredentialClaims(from payload: JSON) -> [ClaimsPathPointer: Any] {
    buildPaths(of: payload, currentPath: [])
  }

  private func buildPaths(of element: Any, currentPath: ClaimsPathPointer) -> [ClaimsPathPointer: Any] {
    if let object = element as? JSON {
      return buildObjectPaths(of: object, currentPath: currentPath)
    }

    if let array = element as? [Any] {
      return buildArrayPaths(of: array, currentPath: currentPath)
    }

    return [currentPath: element]
  }

  private func buildObjectPaths(of object: JSON, currentPath: ClaimsPathPointer) -> [ClaimsPathPointer: Any] {
    var paths = [ClaimsPathPointer: Any]()
    if !currentPath.isEmpty {
      paths[currentPath] = object
    }

    for (key, value) in object {
      let childPaths = buildPaths(of: value, currentPath: currentPath + [.string(key)])
      for (childPath, childValue) in childPaths {
        paths[childPath] = childValue
      }
    }

    return paths
  }

  private func buildArrayPaths(of array: [Any], currentPath: ClaimsPathPointer) -> [ClaimsPathPointer: Any] {
    var paths = [ClaimsPathPointer: Any]()
    paths[currentPath + [.null]] = array

    for (index, value) in array.enumerated() {
      let elementPath = currentPath + [.index(index)]
      paths[elementPath] = value
      let childPaths = buildPaths(of: value, currentPath: elementPath)
      for (childPath, childValue) in childPaths {
        paths[childPath] = childValue
      }
    }

    return paths
  }

  private func getElementPath(
    for path: ClaimsPathPointer,
    attributeType: AttributeType,
    credentialClaims: [ClaimsPathPointer: Any])
    -> ClaimsPathPointer?
  {
    if credentialClaims[path] != nil {
      return path
    }

    if case .array = attributeType, path.last != .null {
      let nullPath = path + [.null]
      if credentialClaims[nullPath] is [Any] {
        return nullPath
      }
    }

    return nil
  }
}
