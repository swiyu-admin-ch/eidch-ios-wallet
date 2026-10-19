import Testing
@testable import BITAppInfo

@Suite
struct SwissProfileStatusTests {

  @Test
  func comparable_ordersStatusesCorrectly() {
    #expect(SwissProfile.Status.endOfLife < .sunset)
    #expect(SwissProfile.Status.sunset < .deprecated)
    #expect(SwissProfile.Status.deprecated < .current)
  }

  @Test
  func comparable_reverseComparisonsAreCorrect() {
    #expect(SwissProfile.Status.current > .deprecated)
    #expect(SwissProfile.Status.deprecated > .sunset)
    #expect(SwissProfile.Status.sunset > .endOfLife)
  }

  @Test(arguments: SwissProfile.Status.allCases)
  func comparable_equalValuesAreNeitherLessNorGreater(status: SwissProfile.Status) {
    #expect(!(status < status))
    #expect(!(status > status))
  }

  @Test
  func allCases_sorted_matchesExpectedOrder() {
    let result = SwissProfile.Status.allCases.sorted()
    #expect(result == [.endOfLife, .sunset, .deprecated, .current])
  }
}
