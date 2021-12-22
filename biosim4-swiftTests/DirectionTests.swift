import XCTest
@testable import biosim4_swift

class DirectionTests: XCTestCase {
  func testRotate() {
    let sut = Direction.northEast
    XCTAssertTrue(sut.rotate(n: 1) == .east)
    XCTAssertTrue(sut.rotate(n: 2) == .southEast)
    XCTAssertTrue(sut.rotate(n: -1) == .north)
    XCTAssertTrue(sut.rotate(n: -2) == .northWest)
    XCTAssertEqual(sut, .north.rotate(n: 1))
    XCTAssertTrue(Direction.southWest.rotate(n: -2) == .southEast)
  }
  
  func testAsNormalizedCoord() {
    var sut: Coord
    
    sut = Direction.southWest.asNormalizedCoord()
    XCTAssertTrue(sut.x == -1 && sut.y == -1)
    
    sut = Direction.south.asNormalizedCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == -1)
    
    sut = Direction.southEast.asNormalizedCoord()
    XCTAssertTrue(sut.x == 1 && sut.y == -1)
    
    sut = Direction.west.asNormalizedCoord()
    XCTAssertTrue(sut.x == -1 && sut.y == 0)
    
    sut = Direction.east.asNormalizedCoord()
    XCTAssertTrue(sut.x == 1 && sut.y == 0)
    
    sut = Direction.northWest.asNormalizedCoord()
    XCTAssertTrue(sut.x == -1 && sut.y == 1)
    
    sut = Direction.north.asNormalizedCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == 1)
    
    sut = Direction.northEast.asNormalizedCoord()
    XCTAssertTrue(sut.x == 1 && sut.y == 1)
  }
  
  func testAsNormalizedPolar() {
    var sut: Polar
    
    sut = Direction.southWest.asNormalizedPolar()
    XCTAssertTrue(sut.magnitude == 1 && sut.direction == .southWest)
    
    sut = Direction.south.asNormalizedPolar()
    XCTAssertTrue(sut.magnitude == 1 && sut.direction == .south)
    
    sut = Direction.southEast.asNormalizedPolar()
    XCTAssertTrue(sut.magnitude == 1 && sut.direction == .southEast)
    
    sut = Direction.west.asNormalizedPolar()
    XCTAssertTrue(sut.magnitude == 1 && sut.direction == .west)
    
    sut = Direction.east.asNormalizedPolar()
    XCTAssertTrue(sut.magnitude == 1 && sut.direction == .east)
    
              sut = Direction.northWest.asNormalizedPolar()
    XCTAssertTrue(sut.magnitude == 1 && sut.direction == .northWest)
    
    sut = Direction.north.asNormalizedPolar()
    XCTAssertTrue(sut.magnitude == 1 && sut.direction == .north)
    
    sut = Direction.northEast.asNormalizedPolar()
    XCTAssertTrue(sut.magnitude == 1 && sut.direction == .northEast)
  }
}
