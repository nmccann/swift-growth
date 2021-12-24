import XCTest
@testable import domain

class CornerChallengePerformanceTests: XCTestCase {
  var individuals: [Indiv] = []
  var grid: Grid!

  override func setUp() {
    grid = .init(sizeX: 100, sizeY: 100)
    individuals = (1...10).map { i in
      Indiv(index: i, loc: .init(x: (grid.size.x - 1) / i, y: (grid.size.y - 1) / i), genome: [])
    }

    individuals.forEach { grid.set(loc: $0.loc, val: $0.index) }
  }

  func testWeightedPerformance() {
    let sut = CornerChallenge(scoring: .weighted)

    measure {
      let results = individuals.map { sut.test($0, on: grid) }
      let expectedResults: [ChallengeResult] = [.pass(1), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .pass(0.04)]
      XCTAssertEqual(results, expectedResults)
    }
  }

  func testUnweightedPerformance() {
    let sut = CornerChallenge(scoring: .unweighted)

    measure {
      let results = individuals.map { sut.test($0, on: grid) }
      let expectedResults: [ChallengeResult] = [.pass(1), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .fail(0), .pass(1)]
      XCTAssertEqual(results, expectedResults)
    }
  }
