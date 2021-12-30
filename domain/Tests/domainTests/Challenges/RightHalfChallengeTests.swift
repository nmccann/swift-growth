import XCTest
import Nimble
@testable import domain

class RightHalfChallengeTests: XCTestCase {
  let sut = RightHalfChallenge()
  var individual: Individual!
  var grid: Grid!

  override func setUp() {
    grid = .init(size: (x: 4, y: 4))
  }

  func testLeftSideFails() {
    individual = .stub(loc: .init(x: 1, y: 0))
    grid[individual.loc] = .occupied(by: individual)
    let result = sut.test(individual, on: grid)
    expect(result.didPass) == false
    expect(result.score) == 0
  }

  func testMiddleFails() {
    individual = .stub(loc: .init(x: 2, y: 0))
    grid[individual.loc] = .occupied(by: individual)
    let result = sut.test(individual, on: grid)
    expect(result.didPass) == false
    expect(result.score) == 0
  }

  func testRightPasses() {
    individual = .stub(loc: .init(x: 3, y: 0))
    grid[individual.loc] = .occupied(by: individual)
    let result = sut.test(individual, on: grid)
    expect(result.didPass) == true
    expect(result.score) == 1
  }
}
