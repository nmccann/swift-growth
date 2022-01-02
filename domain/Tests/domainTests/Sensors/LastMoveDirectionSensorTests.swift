import XCTest
import Nimble
@testable import domain

class LastMoveDirectionSensorTests: XCTestCase {
  var individual: Individual!
  var grid: Grid!
  var parameters: Params!

  override func setUp() {
    grid = .init(size: (x: 4, y: 4))
    individual = .stub()
    grid[individual.loc] = .occupied(by: individual)
    parameters = .stub(stepsPerGeneration: 20)
  }

  func testXAxis() {
    let sut = LastMoveDirectionSensor(axis: .x)

    individual.lastDirection = .east
    var result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 1.0

    individual.lastDirection = .west
    result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 0

    individual.lastDirection = .north
    result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 0.5
  }

  func testYAxis() {
    let sut = LastMoveDirectionSensor(axis: .y)

    individual.lastDirection = .north
    var result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 1.0

    individual.lastDirection = .south
    result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 0

    individual.lastDirection = .east
    result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 0.5
  }
}
