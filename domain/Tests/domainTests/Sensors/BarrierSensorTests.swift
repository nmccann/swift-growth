import XCTest
import Nimble
@testable import domain

class BarrierSensorTests: XCTestCase {
  var individual: Individual!
  var world: World!

  override func setUp() {
    world = .init(parameters: .stub(probeDistance: (short: 3, long: 6), size: .init(width: 20, height: 20)))
  }

  func testNearBarrier() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 2, y: 2), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .east
    world.grid[individual.loc] = .occupied(by: individual)

    world.grid[5, 2] = .barrier

    let result = sut.get(for: individual, on: world)
    expect(result) ≈ 0.3333
  }

  func testNotNearBarrier() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 2, y: 2), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .east
    world.grid[individual.loc] = .occupied(by: individual)

    world.grid[10, 2] = .barrier

    let result = sut.get(for: individual, on: world)
    expect(result) == 0.5
  }

  func testNearBorder() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 18, y: 18), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .northEast
    world.grid[individual.loc] = .occupied(by: individual)

    let result = sut.get(for: individual, on: world)
    expect(result) == 0.5
  }

  func testIgnoresOtherIndividuals() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .south
    world.grid[individual.loc] = .occupied(by: individual)

    let other = Individual.stub(loc: .init(x: 8, y: 7), probeDistance: world.parameters.probeDistance)
    world.grid[other.loc] = .occupied(by: other)

    world.grid[8, 6] = .barrier

    let result = sut.get(for: individual, on: world)
    expect(result) ≈ 0.1667
  }

  func testIgnoresSubsequentBarriers() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .west
    world.grid[individual.loc] = .occupied(by: individual)

    world.grid[6, 8] = .barrier
    world.grid[5, 8] = .barrier

    let result = sut.get(for: individual, on: world)
    expect(result) ≈ 0.1666
  }

  func testPositiveAndNegative() {
    let sut = BarrierSensor { $0.lastDirection }
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .west
    world.grid[individual.loc] = .occupied(by: individual)

    //1 space to the barrier in positive direction, 2 spaces to the barrier in negative direction
    world.grid[6, 8] = .barrier
    world.grid[11, 8] = .barrier

    let result = sut.get(for: individual, on: world)
    expect(result) ≈ 0.3333
  }
}
