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
    parameters = .defaults
    parameters.size.x = 4
    parameters.size.y = 4
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
                         levels: [.MOVE_EAST: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 3, y: 2))) == true
  }

  func testMoveWest() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_WEST: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 1, y: 2))) == true
  }

  func testMoveSouth() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_SOUTH: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 2, y: 1))) == true
  }

  func testMoveNorth() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_NORTH: .greatestFiniteMagnitude],
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
                         levels: [.MOVE_FORWARD: .greatestFiniteMagnitude],
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
                         levels: [.MOVE_REVERSE: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 1, y: 2))) == true
  }

  func testMoveRight() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_RIGHT: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 2, y: 1))) == true
  }

  func testMoveLeft() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_LEFT: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: .init(x: 2, y: 3))) == true
  }

  func testMoveRandom() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    expect(self.grid.isOccupiedAt(loc: initial)) == true
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_RANDOM: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    expect(self.grid.isOccupiedAt(loc: initial)) == false
  }

  func testSetResponsiveness() {
    var indiv = Indiv.stub(index: 0)
    indiv.responsiveness = 1.0
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [.SET_RESPONSIVENESS: 10], on: grid, with: parameters)
    expect(result.indiv.responsiveness) ≈ 0.9999
  }

  func testSetOscillatorPeriod() {
    var indiv = Indiv.stub(index: 0)
    indiv.oscPeriod = 1
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [.SET_OSCILLATOR_PERIOD: 5], on: grid, with: parameters)
    expect(result.indiv.oscPeriod) == 1098
  }

  func testSetLongProbeDist() {
    var indiv = Indiv.stub(index: 0)
    indiv.probeDistance.long = 1
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [.SET_LONGPROBE_DIST: 20], on: grid, with: parameters)
    expect(result.indiv.probeDistance.long) == 33
  }

  func testEmitSignal() {
    //TODO
  }

  func testKillForward() {
    //TODO
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
