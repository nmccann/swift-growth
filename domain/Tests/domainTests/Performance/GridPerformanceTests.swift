import XCTest
import Nimble
@testable import domain

class GridPerformanceTests: XCTestCase {
  var individuals: [Individual] = []
  var sut: Grid!

  override func setUp() {
    sut = .init(size: .init(width: 1000, height: 1000))
    let middle = (x: sut.size.width / 2, y: sut.size.height / 2)
    individuals = (1...10).map { .stub(index: $0, loc: .init(x: middle.x + $0, y: middle.y + $0)) }
    individuals.forEach { sut[$0.loc] = .occupied(by: $0) }
  }

  func testVisitNeighborhood() {
    measure {
      var locations = 0
      func countLocations(loc: Coord) {
        locations += 1
      }

      individuals.forEach {
        self.sut.visitNeighborhood(loc: $0.loc, radius: 5, f: countLocations(loc:))
      }

      expect(locations) == 81 * individuals.count
    }
  }
}
