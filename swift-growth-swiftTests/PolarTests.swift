import XCTest
@testable import swift_growth

class PolarTests: XCTestCase {
  func testAsCoord() {
    var sut: Coord
    
    sut = Polar(magnitude: 0, direction: nil).asCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == 0)
    
    sut = Polar(magnitude: 10, direction: nil).asCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == 0)
    
    sut = Polar(magnitude: 20, direction: .north).asCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == 20)
    
    sut = Polar(magnitude: 12, direction: .west).asCoord()
    XCTAssertTrue(sut.x == -12 && sut.y == 0)
    
    sut = Polar(magnitude: 14, direction: .northEast).asCoord()
    XCTAssertTrue(sut.x == 10 && sut.y == 10)
    
    sut = Polar(magnitude: -14, direction: .northEast).asCoord()
    XCTAssertTrue(sut.x == -10 && sut.y == -10)
    
    sut = Polar(magnitude: 14, direction: .east).asCoord()
    XCTAssertTrue(sut.x == 14 && sut.y == 0)
    
    sut = Polar(magnitude: -14, direction: .east).asCoord()
    XCTAssertTrue(sut.x == -14 && sut.y == 0)
  }
}
