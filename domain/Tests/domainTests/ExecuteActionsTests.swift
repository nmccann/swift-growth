import Foundation
import XCTest
import Nimble
@testable import domain

class ExecuteActionsTests: XCTestCase {
  var parameters: Params!
  var signals: Signals!
  var grid: Grid!

  override func setUp() {
    parameters = .stub(size: .init(width: 4, height: 4))
    signals = .init(layers: parameters.signalLayers, size: parameters.size)
    grid = .init(size: parameters.size)
  }

  func testMoveEast() {
    let initial = Coord(x: 2, y: 2)
    let individual = Individual.stub(index: 0, loc: initial, responsiveness: 1)
    grid[individual.loc] = .occupied(by: individual)

    expect(self.grid.isOccupiedAt(loc: initial)) == true

    let result = executeActions(for: individual,
                                   levels: [(MoveAction(direction: .east), .greatestFiniteMagnitude)],
                                   on: grid,
                                   with: parameters,
                                   probabilityCurve: { $0 > 0.5 })
    grid = applyResult(result, to: grid, signals: &signals)

    expect(self.grid.isOccupiedAt(loc: .init(x: 3, y: 2))) == true
  }

  func testMoveNorth() {
    let initial = Coord(x: 2, y: 2)
    let individual = Individual.stub(index: 0, loc: initial, responsiveness: 1)
    grid[individual.loc] = .occupied(by: individual)

    expect(self.grid.isOccupiedAt(loc: initial)) == true

    let result = executeActions(for: individual,
                                   levels: [(MoveAction(direction: .north), .greatestFiniteMagnitude)],
                                   on: grid,
                                   with: parameters,
                                   probabilityCurve: { $0 > 0.5 })
    grid = applyResult(result, to: grid, signals: &signals)

    expect(self.grid.isOccupiedAt(loc: .init(x: 2, y: 3))) == true
  }

  func testMoveForward() {
    let initial = Coord(x: 2, y: 2)
    var individual = Individual.stub(index: 0, loc: initial, responsiveness: 1)
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)

    expect(self.grid.isOccupiedAt(loc: initial)) == true

    let result = executeActions(for: individual,
                                   levels: [(MoveAction { $0.individual.lastDirection }, .greatestFiniteMagnitude)],
                                   on: grid,
                                   with: parameters,
                                   probabilityCurve: { $0 > 0.5 })
    grid = applyResult(result, to: grid, signals: &signals)

    expect(self.grid.isOccupiedAt(loc: .init(x: 3, y: 2))) == true
  }

  func testMoveReverse() {
    let initial = Coord(x: 2, y: 2)
    var individual = Individual.stub(index: 0, loc: initial, responsiveness: 1)
    individual.lastDirection = .east
    grid[individual.loc] = .occupied(by: individual)

    expect(self.grid.isOccupiedAt(loc: initial)) == true

    let result = executeActions(for: individual,
                                   levels: [(MoveAction { $0.individual.lastDirection.rotate180Degrees() }, .greatestFiniteMagnitude)],
                                   on: grid,
                                   with: parameters,
                                   probabilityCurve: { $0 > 0.5 })
    grid = applyResult(result, to: grid, signals: &signals)

    expect(self.grid.isOccupiedAt(loc: .init(x: 1, y: 2))) == true
  }

  func testSetResponsiveness() {
    let individual = Individual.stub(index: 0, responsiveness: 1)
    grid[individual.loc] = .occupied(by: individual)

    let result = executeActions(for: individual, levels: [(ResponsivenessAction(), 10)], on: grid, with: parameters, probabilityCurve: { _ in true })
    expect(result.individual.responsiveness) ≈ 0.9999
  }

  func testSetOscillatorPeriod() {
    var individual = Individual.stub(index: 0)
    individual.oscPeriod = 1
    grid[individual.loc] = .occupied(by: individual)

    let result = executeActions(for: individual, levels: [(OscillatorPeriodAction(), 5)], on: grid, with: parameters, probabilityCurve: { _ in true })
    expect(result.individual.oscPeriod) == 400
  }

  func testSetLongProbeDist() {
    var individual = Individual.stub(index: 0)
    individual.probeDistance.long = 1
    grid[individual.loc] = .occupied(by: individual)

    let result = executeActions(for: individual, levels: [(LongProbeDistanceAction(), 20)], on: grid, with: parameters, probabilityCurve: { _ in true })
    expect(result.individual.probeDistance.long) == 33
  }

  func testEmitSignalOverThreshold() {
    let action = EmitSignalAction(layer: 0,
                                  threshold: 0.5,
                                  probabilityCurve: { $0 > 0.5 })
    var individual = Individual.stub(index: 0, loc: .init(x: 2, y: 2))
    individual.responsiveness = 1
    grid[individual.loc] = .occupied(by: individual)

    let result = executeActions(for: individual, levels: [(action, 2)], on: grid, with: parameters, probabilityCurve: { _ in true })
    expect(result.signalToLayer) == 0
  }

  func testKillForward() {
    let action = KillAction(threshold: 0.5, probabilityCurve: { $0 > 0.5 })

    var individual = Individual.stub(index: 0, loc: .init(x: 2, y: 2))
    individual.lastDirection = .east
    individual.responsiveness = 1
    grid[individual.loc] = .occupied(by: individual)

    let other = Individual.stub(index: 0, loc: .init(x: 3, y: 2))
    grid[other.loc] = .occupied(by: other)

    let result = executeActions(for: individual, levels: [(action, 2)], on: grid, with: parameters, probabilityCurve: { _ in true })
    expect(result.killed).to(haveCount(1))
    expect(result.killed.first?.index) == other.index

    grid = applyResult(result, to: grid, signals: &signals)
    expect(self.grid[other.loc]).to(beNil())
  }
}

private func applyResult(_ result: ActionResult, to grid: Grid, signals: inout Signals) -> Grid {
  var grid = grid
  if let layer = result.signalToLayer {
    signals.increment(layer: layer, loc: result.individual.loc)
  }

  if let newLocation = result.newLocation {
    grid.queueForMove(from: result.individual.loc, to: newLocation)
  }

  result.killed.forEach {
    grid.queueForDeath(at: $0.loc)
  }

  grid.drainDeathQueue()
  grid.drainMoveQueue()
  return grid
}
