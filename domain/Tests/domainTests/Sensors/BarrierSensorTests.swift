import XCTest
import Nimble
@testable import domain

class BarrierSensorTests: XCTestCase {
  var individual: Individual!
  var grid: Grid!
  var parameters: Params!

  override func setUp() {
    grid = .init(size: (x: 20, y: 20))
    parameters = .stub(probeDistance: (short: 3, long: 6))
  }

  func testNearBarrier() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 2, y: 2), probeDistance: parameters.probeDistance)
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)

    grid[5, 2] = .barrier

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) ≈ 0.3333
  }

  func testNotNearBarrier() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 2, y: 2), probeDistance: parameters.probeDistance)
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)

    grid[10, 2] = .barrier

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 0.5
  }

  func testNearBorder() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 18, y: 18), probeDistance: parameters.probeDistance)
    individual.lastDirection = .northEast
    grid[individual.loc] = .occupied(by: individual)

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 0.5
  }

  func testIgnoresOtherIndividuals() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: parameters.probeDistance)
    individual.lastDirection = .south
    grid[individual.loc] = .occupied(by: individual)

    let other = Individual.stub(loc: .init(x: 8, y: 7), probeDistance: parameters.probeDistance)
    grid[other.loc] = .occupied(by: other)

    grid[8, 6] = .barrier

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) ≈ 0.1667
  }

  func testIgnoresSubsequentBarriers() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: parameters.probeDistance)
    individual.lastDirection = .west
    grid[individual.loc] = .occupied(by: individual)

    grid[6, 8] = .barrier
    grid[5, 8] = .barrier

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) ≈ 0.1666
  }

  func testPositiveAndNegative() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: parameters.probeDistance)
    individual.lastDirection = .west
    grid[individual.loc] = .occupied(by: individual)

    //1 space to the barrier in positive direction, 2 spaces to the barrier in negative direction
    grid[6, 8] = .barrier
    grid[11, 8] = .barrier

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) ≈ 0.3333
  }
}
