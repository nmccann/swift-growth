import Foundation
import XCTest
@testable import biosim4_swift

class ExecuteActionsTests: XCTestCase {
  override func setUp() {
    p = .defaults
    p.sizeX = 4
    p.sizeY = 4
    grid = .init(sizeX: p.sizeX, sizeY: p.sizeY)
    grid.nilFill()
  }

  func testMoveEast() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    peeps = .init(individuals: [indiv])

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      _ = executeActions(indiv: indiv,
                     levels: [.MOVE_EAST: .greatestFiniteMagnitude])
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 3, y: 2)))
  }

  func testMoveWest() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    peeps = .init(individuals: [indiv])

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      _ = executeActions(indiv: indiv,
                     levels: [.MOVE_WEST: .greatestFiniteMagnitude])
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 1, y: 2)))
  }

  func testMoveSouth() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    peeps = .init(individuals: [indiv])

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      _ = executeActions(indiv: indiv,
                     levels: [.MOVE_SOUTH: .greatestFiniteMagnitude])
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 2, y: 1)))
  }

  func testMoveNorth() {
    let initial = Coord(x: 2, y: 2)
    let indiv = Indiv.stub(index: 0, loc: initial)
    peeps = .init(individuals: [indiv])

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      _ = executeActions(indiv: indiv,
                     levels: [.MOVE_NORTH: .greatestFiniteMagnitude])
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 2, y: 3)))
  }

  func testMoveForward() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    peeps = .init(individuals: [indiv])

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      _ = executeActions(indiv: indiv,
                     levels: [.MOVE_FORWARD: .greatestFiniteMagnitude])
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 3, y: 2)))
  }

  func testMoveReverse() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    peeps = .init(individuals: [indiv])

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      _ = executeActions(indiv: indiv,
                     levels: [.MOVE_REVERSE: .greatestFiniteMagnitude])
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 1, y: 2)))
  }

  func testMoveRight() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    peeps = .init(individuals: [indiv])

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      _ = executeActions(indiv: indiv,
                     levels: [.MOVE_RIGHT: .greatestFiniteMagnitude])
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 2, y: 1)))
  }

  func testMoveLeft() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    peeps = .init(individuals: [indiv])

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      _ = executeActions(indiv: indiv,
                     levels: [.MOVE_LEFT: .greatestFiniteMagnitude])
      peeps.drainMoveQueue()
    }
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 2, y: 3)))
  }

  func testMoveRandom() {
    let initial = Coord(x: 2, y: 2)
    var indiv = Indiv.stub(index: 0, loc: initial)
    indiv.lastDirection = .east
    peeps = .init(individuals: [indiv])

    XCTAssertTrue(grid.isOccupiedAt(loc: initial))
    while grid.isOccupiedAt(loc: initial) {
      _ = executeActions(indiv: indiv,
                     levels: [.MOVE_RANDOM: .greatestFiniteMagnitude])
      peeps.drainMoveQueue()
    }
    XCTAssertFalse(grid.isOccupiedAt(loc: initial))
  }

  func testSetResponsiveness() {
    var indiv = Indiv.stub(index: 0)
    indiv.responsiveness = 1.0
    peeps = .init(individuals: [indiv])

    indiv = executeActions(indiv: indiv, levels: [.SET_RESPONSIVENESS: 10])
    XCTAssertEqual(indiv.responsiveness, 0.9999, accuracy: 0.0001)
  }

  func testSetOscillatorPeriod() {
    var indiv = Indiv.stub(index: 0)
    indiv.oscPeriod = 1
    peeps = .init(individuals: [indiv])

    indiv = executeActions(indiv: indiv, levels: [.SET_OSCILLATOR_PERIOD: 5])
    XCTAssertEqual(indiv.oscPeriod, 1098)
  }

  func testSetLongProbeDist() {
    var indiv = Indiv.stub(index: 0)
    indiv.longProbeDist = 1
    peeps = .init(individuals: [indiv])

    indiv = executeActions(indiv: indiv, levels: [.SET_LONGPROBE_DIST: 20])
    XCTAssertEqual(indiv.longProbeDist, 33)
  }

  func testEmitSignal() {
    //TODO
  }

  func testKillForward() {
    //TODO
  }
}
