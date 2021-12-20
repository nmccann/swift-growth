import XCTest
@testable import biosim4_swift

class DirTests: XCTestCase {
  func testCompassEquality() {
    XCTAssertTrue(Dir(dir: .center) == Compass.center)
    XCTAssertTrue(Dir(dir: .SE) == Compass.SE)
    XCTAssertTrue(Dir(dir: .W) == Compass.W)
  }
  
  func testCompassInequality() {
    XCTAssertFalse(Dir(dir: .W) == Compass.NW)
  }
  
  func testDirEquality() {
    XCTAssertEqual(Dir(dir: .N), Dir(dir: .N))
  }
  
  func testDirInequality() {
    XCTAssertNotEqual(Dir(dir: .NE), Dir(dir: .N))
  }
  
  func testRotate() {
    let sut = Dir(dir: .NE)
    XCTAssertTrue(sut.rotate(n: 1) == .E)
    XCTAssertTrue(sut.rotate(n: 2) == .SE)
    XCTAssertTrue(sut.rotate(n: -1) == .N)
    XCTAssertTrue(sut.rotate(n: -2) == .NW)
    XCTAssertEqual(sut, Dir(dir: .N).rotate(n: 1))
    XCTAssertTrue(Dir(dir: .SW).rotate(n: -2) == Compass.SE)
  }
  
  func testAsNormalizedCoord() {
    var sut: Coord
    
    sut = Dir(dir: .center).asNormalizedCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == 0)
    
    sut = Dir(dir: .SW).asNormalizedCoord()
    XCTAssertTrue(sut.x == -1 && sut.y == -1)
    
    sut = Dir(dir: .S).asNormalizedCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == -1)
    
    sut = Dir(dir: .SE).asNormalizedCoord()
    XCTAssertTrue(sut.x == 1 && sut.y == -1)
    
    sut = Dir(dir: .W).asNormalizedCoord()
    XCTAssertTrue(sut.x == -1 && sut.y == 0)
    
    sut = Dir(dir: .E).asNormalizedCoord()
    XCTAssertTrue(sut.x == 1 && sut.y == 0)
    
    sut = Dir(dir: .NW).asNormalizedCoord()
    XCTAssertTrue(sut.x == -1 && sut.y == 1)
    
    sut = Dir(dir: .N).asNormalizedCoord()
    XCTAssertTrue(sut.x == 0 && sut.y == 1)
    
    sut = Dir(dir: .NE).asNormalizedCoord()
    XCTAssertTrue(sut.x == 1 && sut.y == 1)
  }
  
  func testAsNormalizedPolar() {
    var sut: Polar
    
    sut = Dir(dir: .SW).asNormalizedPolar()
    XCTAssertTrue(sut.mag == 1 && sut.dir == .SW)
    
    sut = Dir(dir: .S).asNormalizedPolar()
    XCTAssertTrue(sut.mag == 1 && sut.dir == .S)
    
    sut = Dir(dir: .SE).asNormalizedPolar()
    XCTAssertTrue(sut.mag == 1 && sut.dir == .SE)
    
    sut = Dir(dir: .W).asNormalizedPolar()
    XCTAssertTrue(sut.mag == 1 && sut.dir == .W)
    
    sut = Dir(dir: .E).asNormalizedPolar()
    XCTAssertTrue(sut.mag == 1 && sut.dir == .E)
    
    sut = Dir(dir: .NW).asNormalizedPolar()
    XCTAssertTrue(sut.mag == 1 && sut.dir == .NW)
    
    sut = Dir(dir: .N).asNormalizedPolar()
    XCTAssertTrue(sut.mag == 1 && sut.dir == .N)
    
    sut = Dir(dir: .NE).asNormalizedPolar()
    XCTAssertTrue(sut.mag == 1 && sut.dir == .NE)
  }
}
