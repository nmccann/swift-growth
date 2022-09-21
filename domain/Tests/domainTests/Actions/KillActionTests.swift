import XCTest
import Nimble
@testable import domain

class KillActionTests: XCTestCase {
  var sut: KillAction!
  var individual: Individual!
  var other: Individual!
  var grid: Grid!
  var parameters: Parameters!

  override func setUp() {
    parameters = .stub(stepsPerGeneration: 100)
    grid = .init(size: .init(width: 4, height: 4))

    individual = .stub(index: 0, loc: .init(x: 2, y: 2), responsiveness: 1)
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)

    other = .stub(index: 0, loc: .init(x: 3, y: 2))
    grid[other.loc] = .occupied(by: other)

    sut = .init(threshold: 0.5, probabilityCurve: { $0 > 0.5 })
  }

  func testUndriven() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 })
    var expectedResult = result
    expectedResult.killed = []

    sut.apply(to: &result, level: 0.0, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testPositiveHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 })
    var expectedResult = result
    expectedResult.killed = [other]

    sut.apply(to: &result, level: 50, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testPositiveLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 })
    var expectedResult = result
    expectedResult.killed = [other]

    sut.apply(to: &result, level: 0.5, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testNegativeHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 })
    var expectedResult = result
    expectedResult.killed = []

    sut.apply(to: &result, level: -50, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testNegativeLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 })
    var expectedResult = result
    expectedResult.killed = []

    sut.apply(to: &result, level: -0.5, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testFacingAway() {
    individual.lastDirection = .west

    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 })
    var expectedResult = result
    expectedResult.killed = []

    sut.apply(to: &result, level: 50, on: grid, with: parameters)
    expect(result) == expectedResult
  }
}
