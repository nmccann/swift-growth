import XCTest
import Nimble
@testable import domain

class LastMoveDirectionSensorTests: XCTestCase {
  var individual: Individual!
  var world: World!

  override func setUp() {
    world = .init(parameters: .stub())
    individual = .stub()
  }

  func testXAxis() {
    let sut = LastMoveDirectionSensor(axis: .x)

    individual.lastDirection = .east
    var result = sut.get(for: individual, on: world)
    expect(result) == 1.0

    individual.lastDirection = .west
    result = sut.get(for: individual, on: world)
    expect(result) == 0

    individual.lastDirection = .north
    result = sut.get(for: individual, on: world)
    expect(result) == 0.5
  }

  func testYAxis() {
    let sut = LastMoveDirectionSensor(axis: .y)

    individual.lastDirection = .north
    var result = sut.get(for: individual, on: world)
    expect(result) == 1.0

    individual.lastDirection = .south
    result = sut.get(for: individual, on: world)
    expect(result) == 0

    individual.lastDirection = .east
    result = sut.get(for: individual, on: world)
    expect(result) == 0.5
  }
}
