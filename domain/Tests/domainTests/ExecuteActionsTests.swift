import Foundation
import XCTest
import Nimble
@testable import domain

class ExecuteActionsTests: XCTestCase {
  var parameters: Params!
  var peeps: Peeps!
  var signals: Signals!
  var grid: Grid!

  override func setUp() {
    parameters = .stub(size: (4, 4))
    signals = .init(layers: parameters.signalLayers, size: parameters.size)
    grid = .init(size: parameters.size)
    grid.nilFill()
  }

  func testMoveEast() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                                  levels: [(MoveAction(direction: .east), .greatestFiniteMagnitude)],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 3, y: 2))) == true
  }

  func testMoveNorth() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                                  levels: [(MoveAction(direction: .north), .greatestFiniteMagnitude)],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 2, y: 3))) == true
  }

  func testMoveForward() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                                  levels: [(MoveAction { $0.indiv.lastDirection }, .greatestFiniteMagnitude)],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 3, y: 2))) == true
  }

  func testMoveReverse() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                                  levels: [(MoveAction { $0.indiv.lastDirection.rotate180Degrees() }, .greatestFiniteMagnitude)],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 1, y: 2))) == true
  }

  func testSetResponsiveness() {
    var indiv = Indiv.stub(index: 0)
    indiv.responsiveness = 1.0
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [(ResponsivenessAction(), 10)], on: grid, with: parameters)
    expect(result.indiv.responsiveness) ≈ 0.9999
  }

  func testSetOscillatorPeriod() {
    var indiv = Indiv.stub(index: 0)
    indiv.oscPeriod = 1
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [(OscillatorPeriodAction(), 5)], on: grid, with: parameters)
    expect(result.indiv.oscPeriod) == 1098
  }

  func testSetLongProbeDist() {
    var indiv = Indiv.stub(index: 0)
    indiv.probeDistance.long = 1
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [(LongProbeDistanceAction(), 20)], on: grid, with: parameters)
    expect(result.indiv.probeDistance.long) == 33
  }

  func testEmitSignalOverThreshold() {
    var indiv = Indiv.stub(index: 0, loc: .init(x: 2, y: 2))
    indiv.responsiveness = 1
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [(EmitSignalAction(layer: 0), 2)], on: grid, with: parameters)
    expect(result.signalEmission) == (layer: 0, location: indiv.loc)
  }

  func testKillForward() {
    //TODO: Fix this test - failing because `KillAction` makes use of global state
    var indiv = Indiv.stub(index: 0, loc: .init(x: 2, y: 2))
    indiv.lastDirection = .east
    indiv.responsiveness = 1
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)

    let otherIndiv = Indiv.stub(index: 0, loc: .init(x: 3, y: 2))
    grid.set(loc: otherIndiv.loc, val: otherIndiv.alive ? otherIndiv.index : nil)

    peeps = .init(individuals: [indiv, otherIndiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [(KillAction(), 2)], on: grid, with: parameters)
    expect(result.killed).to(haveCount(1))
    expect(result.killed.first?.index) == otherIndiv.index
  }
}

private func applyResult(_ result: ActionResult, to peeps: Peeps, signals: inout Signals) {
  peeps.individuals.append(result.indiv)

  if let signal = result.signalEmission {
    signals.increment(layer: signal.layer, loc: signal.location)
  }

  if let newLocation = result.newLocation {
    peeps.queueForMove(result.indiv, newLoc: newLocation)
  }

  result.killed.forEach {
    peeps.queueForDeath($0)
  }
}
