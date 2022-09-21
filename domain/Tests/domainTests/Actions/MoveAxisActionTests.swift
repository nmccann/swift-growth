import XCTest
import Nimble
@testable import domain

class MoveAxisActionTests: XCTestCase {
  var sut: MoveAxisAction!
  var individual: Individual!
  var grid: Grid!
  var parameters: Parameters!

  override func setUp() {
    parameters = .stub(stepsPerGeneration: 100)
    grid = .init(size: .init(width: 4, height: 4))
    individual = .stub()
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)

    sut = .init(\.x)
  }

  func testUndriven() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: 0, y: 0)

    sut.apply(to: &result, level: 0.0, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testPositiveHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: 50, y: 0)

    sut.apply(to: &result, level: 50, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testPositiveLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: 0.5, y: 0)

    sut.apply(to: &result, level: 0.5, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testNegativeHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: -50, y: 0)

    sut.apply(to: &result, level: -50, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testNegativeLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: -0.5, y: 0)

    sut.apply(to: &result, level: -0.5, on: grid, with: parameters)
    expect(result) == expectedResult
  }

  func testOtherAxis() {
    sut = .init(\.y)
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    var expectedResult = result
    expectedResult.movePotential = CGPoint(x: 0, y: -0.5)

    sut.apply(to: &result, level: -0.5, on: grid, with: parameters)
    expect(result) == expectedResult
  }
}
