import XCTest
import Nimble
@testable import domain

class OscillatorPeriodActionTests: XCTestCase {
  let sut = OscillatorPeriodAction()
  var individual: Individual!
  var grid: Grid!
  var parameters: Parameters!

  override func setUp() {
    parameters = .stub(stepsPerGeneration: 100)
    grid = .init(size: .init(width: 4, height: 4))
    individual = .stub()
    grid[individual.loc] = .occupied(by: individual)
  }

  func testUndriven() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: 0.0, on: grid, with: parameters)
    expect(result.individual.oscPeriod) == 35
  }

  func testPositiveHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: 50, on: grid, with: parameters)
    expect(result.individual.oscPeriod) == 400
  }

  func testPositiveLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: 0.5, on: grid, with: parameters)
    expect(result.individual.oscPeriod) == 169
  }

  func testNegativeHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: -50, on: grid, with: parameters)
    expect(result.individual.oscPeriod) == 3
  }

  func testNegativeLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: -0.5, on: grid, with: parameters)
    expect(result.individual.oscPeriod) == 9
  }
}
