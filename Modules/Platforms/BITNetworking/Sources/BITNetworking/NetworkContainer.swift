import Alamofire
import Factory
import Foundation
import Moya
import Network
import OSLog

// MARK: - NetworkContainer

public final class NetworkContainer: SharedContainer {
  public static var shared = NetworkContainer()

  public var manager = ContainerManager()
}

public typealias StubHandler = (TargetType) -> Moya.StubBehavior
public typealias EndpointClosureHandler = (TargetType) -> Endpoint

extension NetworkContainer {

  // MARK: Public

  public var service: Factory<NetworkService> {
    self { NetworkService() }.cached
  }

  public var decoder: Factory<JSONDecoder> {
    self {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = self.dateDecodingStrategy()
      decoder.dataDecodingStrategy = self.dataDecodingStrategy()
      decoder.keyDecodingStrategy = self.keyDecodingStrategy()
      return decoder
    }
  }

  public var dateDecodingStrategy: Factory<JSONDecoder.DateDecodingStrategy> {
    self { .iso8601 }
  }

  public var dataDecodingStrategy: Factory<JSONDecoder.DataDecodingStrategy> {
    self { .base64 }
  }

  public var keyDecodingStrategy: Factory<JSONDecoder.KeyDecodingStrategy> {
    self { .useDefaultKeys }
  }

  public var plugins: Factory<[PluginType]> {
    self { [] }
  }

  public var stubClosure: Factory<StubHandler> {
    self { { _ in .never } }
  }

  public var endpointClosure: Factory<EndpointSampleResponse?> {
    self { nil }
  }

  public var connectionTypes: Factory<[NWInterface.InterfaceType]> {
    self { [.wifi, .cellular] }
  }

  public var timetoutInterval: Factory<TimeInterval> {
    self { 15 }
  }

  public var session: Factory<Session> {
    self {
      Session(configuration: self.sessionConfiguration(), serverTrustManager: self.serverTrustManager())
    }
  }

  public var logger: Factory<Logger> {
    self { Logger(subsystem: "BITNetworking", category: "Network") }.cached
  }

  /// ServerTrustManager is used for certificate pinning
  /// Targets apps must register their own ServerTrustManager (eg. in their AppDelegate)
  public var serverTrustManager: Factory<ServerTrustManager?> {
    self { nil }
  }

  public var urlSession: Factory<URLSessionProtocol> {
    self { URLSession.shared }
  }

  // MARK: Private

  private var sessionConfiguration: Factory<URLSessionConfiguration> {
    self {
      let configuration = URLSessionConfiguration.default
      let timetoutInterval = self.timetoutInterval()
      configuration.timeoutIntervalForRequest = timetoutInterval
      configuration.headers = .default
      configuration.requestCachePolicy = .useProtocolCachePolicy
      configuration.urlCache = self.sessionConfigurationCache()
      return configuration
    }
  }

  private var sessionConfigurationCache: Factory<URLCache> {
    self { URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil) }
  }

}
