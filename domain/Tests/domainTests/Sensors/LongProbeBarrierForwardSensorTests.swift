import XCTest
import Nimble
@testable import domain

class LongProbeBarrierForwardSensorTests: XCTestCase {
  let sut = LongProbeBarrierForwardSensor()
  var individual: Individual!
  var grid: Grid!
  var parameters: Params!

  override func setUp() {
    grid = .init(size: (x: 20, y: 20))
    parameters = .stub(probeDistance: (short: 3, long: 6))
  }

  func testNearBarrier() {
    individual = .stub(loc: .init(x: 2, y: 2), probeDistance: parameters.probeDistance)
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)

    grid[5, 2] = .barrier

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) ≈ 0.3333
  }

  func testNotNearBarrier() {
    individual = .stub(loc: .init(x: 2, y: 2), probeDistance: parameters.probeDistance)
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)

    grid[10, 2] = .barrier

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 1
  }

  func testNearBorder() {
    individual = .stub(loc: .init(x: 18, y: 18), probeDistance: parameters.probeDistance)
    individual.lastDirection = .northEast
    grid[individual.loc] = .occupied(by: individual)

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) == 1
  }

  func testIgnoresOtherIndividuals() {
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: parameters.probeDistance)
    individual.lastDirection = .south
    grid[individual.loc] = .occupied(by: individual)

    let other = Individual.stub(loc: .init(x: 8, y: 4), probeDistance: parameters.probeDistance)
    grid[other.loc] = .occupied(by: other)

    grid[8, 3] = .barrier

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) ≈ 0.6666
  }

  func testIgnoresSubsequentBarriers() {
    individual = .stub(loc: .init(x: 8, y: 8), probeDistance: parameters.probeDistance)
    individual.lastDirection = .west
    grid[individual.loc] = .occupied(by: individual)

    grid[6, 8] = .barrier
    grid[4, 8] = .barrier

    let result = sut.get(for: individual, simStep: 0, on: grid, with: parameters)
    expect(result) ≈ 0.1666
  }
}
