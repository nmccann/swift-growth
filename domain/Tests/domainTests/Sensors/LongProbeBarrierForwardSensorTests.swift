import XCTest
import Nimble
@testable import domain

class LongProbeBarrierForwardSensorTests: XCTestCase {
  let sut = LongProbeBarrierForwardSensor()
  var individual: Individual!
  var world: World!

  override func setUp() {
    world = .init(parameters: .stub(probeDistance: (short: 3, long: 6), size: (x: 20, y: 20)))
  }

  func testNearBarrier() {
    individual = .stub(loc: .init(x: 2, y: 2), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .east
    world.grid[individual.loc] = .occupied(by: individual)

    world.grid[5, 2] = .barrier

    let result = sut.get(for: individual, on: world)
    expect(result) ≈ 0.3333
  }

  func testNotNearBarrier() {
    individual = .stub(loc: .init(x: 2, y: 2), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .east
    world.grid[individual.loc] = .occupied(by: individual)

    world.grid[10, 2] = .barrier

    let result = sut.get(for: individual, on: world)
    expect(result) == 1
  }

  func testNearBorder() {
    individual = .stub(loc: .init(x: 18, y: 18), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .northEast
    world.grid[individual.loc] = .occupied(by: individual)

    let result = sut.get(for: individual, on: world)
    expect(result) == 1
  }

  func testIgnoresOtherIndividuals() {
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .south
    world.grid[individual.loc] = .occupied(by: individual)

    let other = Individual.stub(loc: .init(x: 8, y: 4), probeDistance: world.parameters.probeDistance)
    world.grid[other.loc] = .occupied(by: other)

    world.grid[8, 3] = .barrier

    let result = sut.get(for: individual, on: world)
    expect(result) ≈ 0.6666
  }

  func testIgnoresSubsequentBarriers() {
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: world.parameters.probeDistance)
    individual.lastDirection = .west
    world.grid[individual.loc] = .occupied(by: individual)

    world.grid[6, 8] = .barrier
    world.grid[4, 8] = .barrier

    let result = sut.get(for: individual, on: world)
    expect(result) ≈ 0.1666
  }
}
