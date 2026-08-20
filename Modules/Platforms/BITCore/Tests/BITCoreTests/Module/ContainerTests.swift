import Factory
import FactoryTesting
import Testing
@testable import BITCore

@Suite(.container)
struct ContainerTests {

  @Test
  func regexEvaluationTimeout() {
    #expect(Container.shared.regexEvaluationTimeout() == 0.3)
  }

  @Test
  func maxHttpUrlLength() {
    #expect(Container.shared.maxHttpUrlLength() == 2048)
  }

}
