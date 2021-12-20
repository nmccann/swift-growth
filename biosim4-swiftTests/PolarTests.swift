import XCTest
@testable import biosim4_swift

class PolarTests: XCTestCase {
  func testAsCoord() {
    var sut: Coord
    
    sut = Polar(mag: 0, dir: .center).asCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == 0)
    
    sut = Polar(mag: 10, dir: .center).asCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == 0)
    
    sut = Polar(mag: 20, dir: .N).asCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == 20)
    
    sut = Polar(mag: 12, dir: .W).asCoord()
    XCTAssertTrue(sut.x == -12 && sut.y == 0)
    
    sut = Polar(mag: 14, dir: .NE).asCoord()
    XCTAssertTrue(sut.x == 10 && sut.y == 10)
    
    sut = Polar(mag: -14, dir: .NE).asCoord()
    XCTAssertTrue(sut.x == -10 && sut.y == -10)
    
    sut = Polar(mag: 14, dir: .E).asCoord()
    XCTAssertTrue(sut.x == 14 && sut.y == 0)
    
    sut = Polar(mag: -14, dir: .E).asCoord()
    XCTAssertTrue(sut.x == -14 && sut.y == 0)
  }
}
