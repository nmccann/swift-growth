import XCTest
import Nimble
@testable import domain

class RightHalfChallengeTests: XCTestCase {
  let sut = RightHalfChallenge()
  var individual: Indiv!
  var grid: Grid!

  override func setUp() {
    grid = .init(sizeX: 4, sizeY: 4)
  }

  func testLeftSideFails() {
    individual = .init(index: 0, loc: .init(x: 1, y: 0), genome: [])
    grid.set(loc: individual.loc, val: individual.index)
    let result = sut.test(individual, on: grid)
    expect(result.didPass) == false
    expect(result.score) == 0
  }

  func testMiddleFails() {
    individual = .init(index: 0, loc: .init(x: 2, y: 0), genome: [])
    grid.set(loc: individual.loc, val: individual.index)
    let result = sut.test(individual, on: grid)
    expect(result.didPass) == false
    expect(result.score) == 0
  }

  func testRightPasses() {
    individual = .init(index: 0, loc: .init(x: 3, y: 0), genome: [])
    grid.set(loc: individual.loc, val: individual.index)
    let result = sut.test(individual, on: grid)
    expect(result.didPass) == true
    expect(result.score) == 1
  }
}
