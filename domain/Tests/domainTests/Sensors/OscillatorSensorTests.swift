import XCTest
import Nimble
@testable import domain

class OscillatorSensorTests: XCTestCase {
  let sut = OscillatorSensor()
  var individual: Individual!
  var world: World!

  override func setUp() {
    world = .init(parameters: .stub(stepsPerGeneration: 100))
    world.simStep = 0
    individual = .stub()
  }

  func testPositivePeriod() {
    individual.oscPeriod = 4
    let results = (0...8).map { step -> Double in
      world.simStep = step
      return sut.get(for: individual, on: world)
    }
    expect(results) ≈ [0.0, 0.5, 1.0, 0.5, 0.0, 0.5, 1.0, 0.5, 0.0]
  }

  func testNegativePeriod() {
    individual.oscPeriod = -4
    let results = (0...8).map { step -> Double in
      world.simStep = step
      return sut.get(for: individual, on: world)
    }
    expect(results) ≈ [0.0, 0.5, 1.0, 0.5, 0.0, 0.5, 1.0, 0.5, 0.0]
  }

  func testNegativeStep() {
    individual.oscPeriod = 4
    let results = (-8...0).map { step -> Double in
      world.simStep = step
      return sut.get(for: individual, on: world)
    }
    expect(results) ≈ [0.0, 0.5, 1.0, 0.5, 0.0, 0.5, 1.0, 0.5, 0.0]
  }
}
