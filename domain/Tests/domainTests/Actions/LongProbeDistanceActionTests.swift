import XCTest
import Nimble
@testable import domain

class LongProbeDistanceActionTests: XCTestCase {
  var sut: LongProbeDistanceAction!
  var individual: Individual!
  var grid: Grid!
  var parameters: Parameters!

  override func setUp() {
    parameters = .stub(stepsPerGeneration: 100)
    grid = .init(size: .init(width: 4, height: 4))
    individual = .stub()
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)
    sut = .init(max: 32)
  }

  func testUndriven() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.individual.probeDistance.long = 16

    sut.apply(to: &result, level: 0.0, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testPositiveHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.individual.probeDistance.long = 32

    sut.apply(to: &result, level: 50, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testPositiveLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.individual.probeDistance.long = 23

    sut.apply(to: &result, level: 0.5, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testNegativeHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.individual.probeDistance.long = 1

    sut.apply(to: &result, level: -50, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testNegativeLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.individual.probeDistance.long = 9

    sut.apply(to: &result, level: -0.5, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testDifferentMaxUndriven() {
    sut = .init(max: 10)
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.individual.probeDistance.long = 5

    sut.apply(to: &result, level: 0, on: grid, with: parameters)
    expect(result) == expectedResult
  }
}
