import Foundation
import XCTest
import Nimble
@testable import domain

class ExecuteActionsTests: XCTestCase {
  var parameters: Params!
  var signals: Signals!
  var grid: Grid!

  override func setUp() {
    parameters = .stub(size: (4, 4))
    signals = .init(layers: parameters.signalLayers, size: parameters.size)
    grid = .init(size: parameters.size)
  }

  func testMoveEast() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid[indiv.loc] = .occupied(by: indiv)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                                  levels: [(MoveAction(direction: .east), .greatestFiniteMagnitude)],
                         on: grid,
                         with: parameters)
      applyResult(result, to: grid, signals: &signals)
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 3, y: 2))) == true
  }

  func testMoveNorth() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid[indiv.loc] = .occupied(by: indiv)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                                  levels: [(MoveAction(direction: .north), .greatestFiniteMagnitude)],
                         on: grid,
                         with: parameters)
      applyResult(result, to: grid, signals: &signals)
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 2, y: 3))) == true
  }

  func testMoveForward() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid[indiv.loc] = .occupied(by: indiv)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                                  levels: [(MoveAction { $0.indiv.lastDirection }, .greatestFiniteMagnitude)],
                         on: grid,
                         with: parameters)
      applyResult(result, to: grid, signals: &signals)
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 3, y: 2))) == true
  }

  func testMoveReverse() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid[indiv.loc] = .occupied(by: indiv)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                                  levels: [(MoveAction { $0.indiv.lastDirection.rotate180Degrees() }, .greatestFiniteMagnitude)],
                         on: grid,
                         with: parameters)
      applyResult(result, to: grid, signals: &signals)
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 1, y: 2))) == true
  }

  func testSetResponsiveness() {
    var indiv = Indiv.stub(index: 0)
    indiv.responsiveness = 1.0
    grid[indiv.loc] = .occupied(by: indiv)

    let result = executeActions(indiv: indiv, levels: [(ResponsivenessAction(), 10)], on: grid, with: parameters)
    expect(result.indiv.responsiveness) ≈ 0.9999
  }

  func testSetOscillatorPeriod() {
    var indiv = Indiv.stub(index: 0)
    indiv.oscPeriod = 1
    grid[indiv.loc] = .occupied(by: indiv)

    let result = executeActions(indiv: indiv, levels: [(OscillatorPeriodAction(), 5)], on: grid, with: parameters)
    expect(result.indiv.oscPeriod) == 1098
  }

  func testSetLongProbeDist() {
    var indiv = Indiv.stub(index: 0)
    indiv.probeDistance.long = 1
    grid[indiv.loc] = .occupied(by: indiv)

    let result = executeActions(indiv: indiv, levels: [(LongProbeDistanceAction(), 20)], on: grid, with: parameters)
    expect(result.indiv.probeDistance.long) == 33
  }

  func testEmitSignalOverThreshold() {
    var individual = Indiv.stub(index: 0, loc: .init(x: 2, y: 2))
    individual.responsiveness = 1
    grid[individual.loc] = .occupied(by: individual)

    let result = executeActions(indiv: individual, levels: [(EmitSignalAction(layer: 0), 2)], on: grid, with: parameters)
    expect(result.signalEmission) == (layer: 0, location: individual.loc)
  }

  func testKillForward() {
    var individual = Indiv.stub(index: 0, loc: .init(x: 2, y: 2))
    individual.lastDirection = .east
    individual.responsiveness = 1
    grid[individual.loc] = .occupied(by: individual)

    let other = Indiv.stub(index: 0, loc: .init(x: 3, y: 2))
    grid[other.loc] = .occupied(by: other)

    let result = executeActions(indiv: individual, levels: [(KillAction(), 2)], on: grid, with: parameters)
    expect(result.killed).to(haveCount(1))
    expect(result.killed.first?.index) == other.index

    applyResult(result, to: grid, signals: &signals)
    expect(self.grid[other.loc]).to(beNil())
  }
}

private func applyResult(_ result: ActionResult, to grid: Grid, signals: inout Signals) {
  if let signal = result.signalEmission {
    signals.increment(layer: signal.layer, loc: signal.location)
  }

  if let newLocation = result.newLocation {
    grid.queueForMove(from: result.indiv.loc, to: newLocation)
  }

  result.killed.forEach {
    grid.queueForDeath(at: $0.loc)
  }

  grid.drainDeathQueue()
  grid.drainMoveQueue()
}
