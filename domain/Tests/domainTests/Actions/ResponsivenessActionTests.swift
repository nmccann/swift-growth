import XCTest
import Nimble
@testable import domain

class ResponsivenessActionTests: XCTestCase {
  let sut = ResponsivenessAction()
  var individual: Individual!
  var grid: Grid!
  var parameters: Params = .defaults

  override func setUp() {
    grid = .init(size: (x: 4, y: 4))
    individual = .stub()
    grid[individual.loc] = .occupied(by: individual)
  }

  func testUndriven() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: 0.0, on: grid, with: parameters)
    expect(result.individual.responsiveness) == 0.5
    expect(result.adjustedResponsiveness) == 1
  }

  func testPositiveHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: 50, on: grid, with: parameters)
    expect(result.individual.responsiveness) == 1
    expect(result.adjustedResponsiveness) == 2
  }

  func testPositiveLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: 1, on: grid, with: parameters)
    expect(result.individual.responsiveness) ≈ 0.8808
    expect(result.adjustedResponsiveness) ≈ 1.7616
  }

  func testNegativeHigh() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: -50, on: grid, with: parameters)
    expect(result.individual.responsiveness) == 0
    expect(result.adjustedResponsiveness) == 0
  }

  func testNegativeLow() {
    var result = ActionResult(individual: individual, killed: [], responseCurve: { $0 * 2 })
    sut.apply(to: &result, level: -3, on: grid, with: parameters)
    expect(result.individual.responsiveness) ≈ 0.0024
    expect(result.adjustedResponsiveness) ≈ 0.0049
  }
}
