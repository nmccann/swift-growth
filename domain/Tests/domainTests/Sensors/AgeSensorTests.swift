import XCTest
import Nimble
@testable import domain

class AgeSensorTests: XCTestCase {
  let sut = AgeSensor()
  var individual: Individual!
  var grid: Grid!
  var parameters: Params!

  override func setUp() {
    grid = .init(size: (x: 4, y: 4))
    individual = .stub()
    grid[individual.loc] = .occupied(by: individual)
    parameters = .stub(stepsPerGeneration: 20)
  }

  func testBelowMinimum() {
    individual.age = -10
    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 0.0
  }

  func testAboveMaximum() {
    individual.age = 25
    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 1.0
  }

  func testInRange() {
    individual.age = 10
    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 0.5
  }
}
