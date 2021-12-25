import Foundation
import XCTest
import Nimble
@testable import domain

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
    
    expect(self.peeps[0].loc) == Coord(x: 0, y: 0)
    expect(self.grid.isOccupiedAt(loc: .init(x: 0, y: 0))) == true
    expect(self.grid.isOccupiedAt(loc: .init(x: 1, y: 0))) == false
    
    peeps.drainMoveQueue()
    
    expect(self.peeps[0].loc) == Coord(x: 1, y: 0)
    expect(self.grid.isOccupiedAt(loc: .init(x: 0, y: 0))) == false
    expect(self.grid.isOccupiedAt(loc: .init(x: 1, y: 0))) == true
  }
  
  func testQueueForDeath() {
    let indiv = Indiv.stub(index: 0, loc: .init(x: 0, y: 0))
    grid.set(loc: indiv.loc, val: indiv.alive ? indiv.index : nil)
    peeps = .init(individuals: [indiv], on: grid)
    
    peeps.queueForDeath(indiv)
    
    expect(self.peeps.deathQueueSize()) == 1
    expect(self.peeps[0].alive) == true
    expect(self.grid.isOccupiedAt(loc: .init(x: 0, y: 0))) == true
    
    peeps.drainDeathQueue()
    
    expect(self.peeps.deathQueueSize()) == 0
    expect(self.peeps[0].alive) == false
    expect(self.grid.isOccupiedAt(loc: .init(x: 0, y: 0))) == false
  }
}
