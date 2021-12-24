import Foundation
import XCTest
@testable import domain

class ExecuteActionsTests: XCTestCase {
  var parameters: Params!
  var peeps: Peeps!
  var signals: Signals!
  var grid: Grid!

  override func setUp() {
    parameters = .defaults
    parameters.sizeX = 4
    parameters.sizeY = 4
    signals = .init(layers: parameters.signalLayers, sizeX: parameters.sizeX, sizeY: parameters.sizeY)
    grid = .init(sizeX: parameters.sizeX, sizeY: parameters.sizeY)
    grid.nilFill()
  }

  func testMoveEast() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_EAST: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 3, y: 2)))
  }

  func testMoveWest() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_WEST: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 1, y: 2)))
  }

  func testMoveSouth() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_SOUTH: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 2, y: 1)))
  }

  func testMoveNorth() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_NORTH: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 2, y: 3)))
  }

  func testMoveForward() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_FORWARD: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 3, y: 2)))
  }

  func testMoveReverse() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_REVERSE: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 1, y: 2)))
  }

  func testMoveRight() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_RIGHT: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 2, y: 1)))
  }

  func testMoveLeft() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_LEFT: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 2, y: 3)))
  }

  func testMoveRandom() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      let result = executeActions(indiv: indiv,
                         levels: [.MOVE_RANDOM: .greatestFiniteMagnitude],
                         on: grid,
                         with: parameters)
      applyResult(result, to: peeps, signals: &signals)
      peeps.drainMoveQueue()
    }
    XCTAssertFalse(grid.isOccupiedAt(loc: initial))
  }

  func testSetResponsiveness() {
    var indiv = Indiv.stub(index: 0)
    indiv.responsiveness = 1.0
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [.SET_RESPONSIVENESS: 10], on: grid, with: parameters)
    XCTAssertEqual(result.indiv.responsiveness, 0.9999, accuracy: 0.0001)
  }

  func testSetOscillatorPeriod() {
    var indiv = Indiv.stub(index: 0)
    indiv.oscPeriod = 1
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [.SET_OSCILLATOR_PERIOD: 5], on: grid, with: parameters)
    XCTAssertEqual(result.indiv.oscPeriod, 1098)
  }

  func testSetLongProbeDist() {
    var indiv = Indiv.stub(index: 0)
    indiv.longProbeDist = 1
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)

    let result = executeActions(indiv: indiv, levels: [.SET_LONGPROBE_DIST: 20], on: grid, with: parameters)
    XCTAssertEqual(result.indiv.longProbeDist, 33)
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
