import XCTest
import Nimble
@testable import domain

class CornerChallengePerformanceTests: XCTestCase {
  var individuals: [Indiv] = []
  var grid: Grid!

  override func setUp() {
    grid = .init(size: (x: 100, y: 100))
    individuals = (1...10).map { .stub(index: $0, loc: .init(x: (grid.size.x - 1) / $0, y: (grid.size.y - 1) / $0)) }
    individuals.forEach { grid[$0.loc] = .occupied(by: $0) }
  }

  func testWeightedPerformance() {
    let sut = CornerChallenge(scoring: .weighted)

    measure {
      let results = individuals.map { sut.test($0, on: grid) }
      let expectedResults: [ChallengeResult] = [.pass(1), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .pass(0.04)]
      expect(results) == expectedResults
    }
  }

  func testUnweightedPerformance() {
    let sut = CornerChallenge(scoring: .unweighted)

    measure {
      let results = individuals.map { sut.test($0, on: grid) }
      let expectedResults: [ChallengeResult] = [.pass(1), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .pass(1)]
      expect(results) == expectedResults
    }
  }
}
