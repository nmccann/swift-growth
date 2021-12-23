import Foundation
import XCTest
@testable import swift_growth

class PeepsTests: XCTestCase {
  var parameters: Params!
  var peeps: Peeps!
  var grid: Grid!

  override func setUp() {
    parameters = .defaults
    parameters.sizeX = 4
    parameters.sizeY = 4
    grid = .init(sizeX: parameters.sizeX, sizeY: parameters.sizeY)
    grid.nilFill()
    peeps = .init(individuals: [], on: grid)
  }
  
  func testQueueForMove() {
    let indiv = Indiv.stub(index: 0, loc: .init(x: 0, y: 0))
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)
    
    peeps.queueForMove(indiv, newLoc: .init(x: 1, y: 0))
    
    XCTAssertEqual(peeps[0].loc, .init(x: 0, y: 0))
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 0, y: 0)))
    XCTAssertFalse(grid.isOccupiedAt(loc: .init(x: 1, y: 0)))
    
    peeps.drainMoveQueue()
    
    XCTAssertEqual(peeps[0].loc, .init(x: 1, y: 0))
    XCTAssertFalse(grid.isOccupiedAt(loc: .init(x: 0, y: 0)))
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 1, y: 0)))
  }
  
  func testQueueForDeath() {
    let indiv = Indiv.stub(index: 0, loc: .init(x: 0, y: 0))
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)
    
    peeps.queueForDeath(indiv)
    
    XCTAssertEqual(peeps.deathQueueSize(), 1)
    XCTAssertTrue(peeps[0].alive)
    XCTAssertTrue(grid.isOccupiedAt(loc: .init(x: 0, y: 0)))
    
    peeps.drainDeathQueue()
    
    XCTAssertEqual(peeps.deathQueueSize(), 0)
    XCTAssertFalse(peeps[0].alive)
    XCTAssertFalse(grid.isOccupiedAt(loc: .init(x: 0, y: 0)))
  }
}
