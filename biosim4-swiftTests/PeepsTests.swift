import Foundation
import XCTest
@testable import biosim4_swift

class PeepsTests: XCTestCase {
  override func setUp() {
    p = .defaults
    p.sizeX = 4
    p.sizeY = 4
    grid = .init(sizeX: p.sizeX, sizeY: p.sizeY)
    grid.nilFill()
    peeps = .init(individuals: [])
  }
  
  func testQueueForMove() {
    let indiv = Indiv.stub(index: 0, loc: .init(x: 0, y: 0))
    peeps = .init(individuals: [indiv])
    
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
    peeps = .init(individuals: [indiv])
    
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
