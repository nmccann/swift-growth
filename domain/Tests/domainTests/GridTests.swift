import XCTest
import Nimble
@testable import domain

class GridTests: XCTestCase {
  var individuals: [Indiv] = []
  var sut: Grid!

  override func setUp() {
    sut = .init(size: (x: 4, y: 4))
  }

  func testQueueForMove() {
    let individual = Indiv.stub(index: 0, loc: .init(x: 0, y: 0))
    sut[individual.loc] = .occupied(by: individual)

    sut.queueForMove(from: individual.loc, to: .init(x: 1, y: 0))

    expect(self.sut[0, 0]) == .occupied(by: individual)
    expect(self.sut.isOccupiedAt(loc: .init(x: 0, y: 0))) == true
    expect(self.sut.isOccupiedAt(loc: .init(x: 1, y: 0))) == false

    sut.drainMoveQueue()

    var movedIndividual = individual
    movedIndividual.loc = .init(x: 1, y: 0)
    movedIndividual.lastDirection = .east
    expect(self.sut[1, 0]) == .occupied(by: movedIndividual)
    expect(self.sut.isOccupiedAt(loc: .init(x: 0, y: 0))) == false
    expect(self.sut.isOccupiedAt(loc: .init(x: 1, y: 0))) == true
  }

  func testQueueForDeath() {
    let individual = Indiv.stub(index: 0, loc: .init(x: 0, y: 0))
    sut[individual.loc] = .occupied(by: individual)

    sut.queueForDeath(at: individual.loc)

    expect(self.sut.deathQueue).to(haveCount(1))
    expect(self.sut[0, 0]) == .occupied(by: individual)
    expect(self.sut.isOccupiedAt(loc: .init(x: 0, y: 0))) == true

    sut.drainDeathQueue()

    expect(self.sut.deathQueue).to(haveCount(0))
    expect(self.sut[0, 0]).to(beNil())
    expect(self.sut.isOccupiedAt(loc: .init(x: 0, y: 0))) == false
  }
}
