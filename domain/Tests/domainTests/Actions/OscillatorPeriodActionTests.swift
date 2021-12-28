import XCTest
import Nimble
@testable import domain

class OscillatorPeriodActionTests: XCTestCase {
  let sut = OscillatorPeriodAction()
  var individual: Indiv!
  var grid: Grid!
  var parameters: Params!

  override func setUp() {
    parameters = .stub(stepsPerGeneration: 100)
    grid = .init(size: (x: 4, y: 4))
    individual = .stub()
    grid[individual.loc] = .occupied(by: individual)
  }

  func testUndriven() {
    var result = ActionResult(indiv: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: 0.0, on: grid, with: parameters)
    expect(result.indiv.oscPeriod) == 35
  }

  func testPositiveHigh() {
    var result = ActionResult(indiv: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: 50, on: grid, with: parameters)
    expect(result.indiv.oscPeriod) == 400
  }

  func testPositiveLow() {
    var result = ActionResult(indiv: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: 0.5, on: grid, with: parameters)
    expect(result.indiv.oscPeriod) == 169
  }

  func testNegativeHigh() {
    var result = ActionResult(indiv: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: -50, on: grid, with: parameters)
    expect(result.indiv.oscPeriod) == 3
  }

  func testNegativeLow() {
    var result = ActionResult(indiv: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: -0.5, on: grid, with: parameters)
    expect(result.indiv.oscPeriod) == 9
  }
}
