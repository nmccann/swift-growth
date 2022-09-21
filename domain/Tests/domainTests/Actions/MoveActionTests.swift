import XCTest
import Nimble
@testable import domain

class MoveActionTests: XCTestCase {
  var sut: MoveAction!
  var individual: Individual!
  var grid: Grid!
  var parameters: Parameters!

  override func setUp() {
    parameters = .stub(stepsPerGeneration: 100)
    grid = .init(size: .init(width: 4, height: 4))
    individual = .stub()
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)
  }

  func testUndriven() {
    sut = MoveAction(direction: { $0.individual.lastDirection })
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: 0, y: 0)

    sut.apply(to: &result, level: 0.0, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testPositiveHigh() {
    sut = MoveAction(direction: { $0.individual.lastDirection })
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: 50, y: 0)

    sut.apply(to: &result, level: 50, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testPositiveLow() {
    sut = MoveAction(direction: { $0.individual.lastDirection })
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: 0.5, y: 0)

    sut.apply(to: &result, level: 0.5, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testNegativeHigh() {
    sut = MoveAction(direction: { $0.individual.lastDirection })
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: -50, y: 0)

    sut.apply(to: &result, level: -50, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testNegativeLow() {
    sut = MoveAction(direction: { $0.individual.lastDirection })
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: -0.5, y: 0)

    sut.apply(to: &result, level: -0.5, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testPerpendicularDirection() {
    sut = MoveAction(direction: { $0.individual.lastDirection.rotate90DegreesClockwise() })
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: 0, y: -10)

    sut.apply(to: &result, level: 10, on: grid, with: parameters)
    expect(result) == expectedResult
  }
}
