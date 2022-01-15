import XCTest
import Nimble
@testable import domain

class AgeSensorTests: XCTestCase {
  let sut = AgeSensor()
  var individual: Individual!
  var world: World!

  override func setUp() {
    world = .init(parameters: .stub(stepsPerGeneration: 20))
    individual = .stub()
  }

  func testBelowMinimum() {
    individual.age = -10
    let result = sut.get(for: individual, on: world)
    expect(result) == 0.0
  }

  func testAboveMaximum() {
    individual.age = 25
    let result = sut.get(for: individual, on: world)
    expect(result) == 1.0
  }

  func testInRange() {
    individual.age = 10
    let result = sut.get(for: individual, on: world)
    expect(result) == 0.5
  }
}
