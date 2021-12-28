import XCTest
import Nimble
@testable import domain

class OscillatorSensorTests: XCTestCase {
  let sut = OscillatorSensor()
  var individual: Indiv!
  var grid: Grid!
  var parameters: Params!

  override func setUp() {
    parameters = .stub(stepsPerGeneration: 100)
    grid = .init(size: (x: 4, y: 4))
    individual = .stub()
    grid[individual.loc] = .occupied(by: individual)
  }

  func testPositivePeriod() {
    individual.oscPeriod = 4
    let results = (0...8).map { sut.get(for: individual, simStep: $0, on: grid, with: parameters) }
    expect(results) ≈ [0.0, 0.5, 1.0, 0.5, 0.0, 0.5, 1.0, 0.5, 0.0]
  }

  func testNegativePeriod() {
    individual.oscPeriod = -4
    let results = (0...8).map { sut.get(for: individual, simStep: $0, on: grid, with: parameters) }
    expect(results) ≈ [0.0, 0.5, 1.0, 0.5, 0.0, 0.5, 1.0, 0.5, 0.0]
  }

  func testNegativeStep() {
    individual.oscPeriod = 4
    let results = (-8...0).map { sut.get(for: individual, simStep: $0, on: grid, with: parameters) }
    expect(results) ≈ [0.0, 0.5, 1.0, 0.5, 0.0, 0.5, 1.0, 0.5, 0.0]
  }
}
