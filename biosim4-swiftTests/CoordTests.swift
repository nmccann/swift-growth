import XCTest
@testable import biosim4_swift

class CoordTests: XCTestCase {
  func testIsNormalized() {
    var sut: Coord = .init(x: 9, y: 101)
    XCTAssertFalse(sut.isNormalized)
    
    sut = .init(x: 0, y: 0)
    XCTAssertTrue(sut.isNormalized)
    
    sut = .init(x: 0, y: 1)
    XCTAssertTrue(sut.isNormalized)
    
    sut = .init(x: 1, y: 1)
    XCTAssertTrue(sut.isNormalized)
    
    sut = .init(x: -1, y: 0)
    XCTAssertTrue(sut.isNormalized)
    
    sut = .init(x: -1, y: -1)
    XCTAssertTrue(sut.isNormalized)
    
    sut = .init(x: 0, y: 2)
    XCTAssertFalse(sut.isNormalized)
    
    sut = .init(x: 1, y: 2)
    XCTAssertFalse(sut.isNormalized)
    
    sut = .init(x: -1, y: 2)
    XCTAssertFalse(sut.isNormalized)
    
    sut = .init(x: -2, y: 0)
    XCTAssertFalse(sut.isNormalized)
  }
  
  func testNormalizedDirection() {
    var sut: Coord
    
    sut = .init(x: 0, y: 0).normalize()
    XCTAssertTrue(sut.x == 0 && sut.y == 0)
    XCTAssertEqual(sut.asDir(), .init(dir: .center))
    
    sut = .init(x: 0, y: 1).normalize()
    XCTAssertTrue(sut.x == 0 && sut.y == 1)
    XCTAssertEqual(sut.asDir(), .init(dir: .N))
    
    sut = .init(x: -1, y: 1).normalize()
    XCTAssertTrue(sut.x == -1 && sut.y == 1)
    XCTAssertEqual(sut.asDir(), .init(dir: .NW))
    
    sut = .init(x: 100, y: 5).normalize()
    XCTAssertTrue(sut.x == 1 && sut.y == 0)
    XCTAssertEqual(sut.asDir(), .init(dir: .E))
    
    sut = .init(x: 100, y: 105).normalize()
    XCTAssertTrue(sut.x == 1 && sut.y == 1)
    XCTAssertEqual(sut.asDir(), .init(dir: .NE))
    
    sut = .init(x: -5, y: 101).normalize()
    XCTAssertTrue(sut.x == 0 && sut.y == 1)
    XCTAssertEqual(sut.asDir(), .init(dir: .N))
    
    sut = .init(x: -500, y: 10).normalize()
    XCTAssertTrue(sut.x == -1 && sut.y == 0)
    XCTAssertEqual(sut.asDir(), .init(dir: .W))
    
    sut = .init(x: -500, y: -490).normalize()
    XCTAssertTrue(sut.x == -1 && sut.y == -1)
    XCTAssertEqual(sut.asDir(), .init(dir: .SW))
    
    sut = .init(x: -1, y: -490).normalize()
    XCTAssertTrue(sut.x == 0 && sut.y == -1)
    XCTAssertEqual(sut.asDir(), .init(dir: .S))
    
    sut = .init(x: 1101, y: -1090).normalize()
    XCTAssertTrue(sut.x == 1 && sut.y == -1)
    XCTAssertEqual(sut.asDir(), .init(dir: .SE))
    
    sut = .init(x: 1101, y: -3).normalize()
    XCTAssertTrue(sut.x == 1 && sut.y == 0)
    XCTAssertEqual(sut.asDir(), .init(dir: .E))
  }
  
  func testLength() {
    var sut: Coord
    
    sut = .init(x: 0, y: 0)
    XCTAssertEqual(sut.length, 0)
    
    sut = .init(x: 0, y: 1)
    XCTAssertEqual(sut.length, 1)
    
    sut = .init(x: -1, y: 0)
    XCTAssertEqual(sut.length, 1)
    
    sut = .init(x: -1, y: -1)
    XCTAssertEqual(sut.length, 1) // round down
    
    sut = .init(x: 22, y: 0)
    XCTAssertEqual(sut.length, 22)
    
    sut = .init(x: 22, y: 22)
    XCTAssertEqual(sut.length, 31) // round down
    
    sut = .init(x: 10, y: -10)
    XCTAssertEqual(sut.length, 14) // round down
    
    sut = .init(x: -310, y: 0)
    XCTAssertEqual(sut.length, 310)
  }
  
  func testAsPolar() {
    var sut: Polar
    
    sut = Coord(x: 0, y: 0).asPolar()
    XCTAssertTrue(sut.mag == 0 && sut.dir == .center)
    
    sut = Coord(x: 0, y: 1).asPolar()
    XCTAssertTrue(sut.mag == 1 && sut.dir == .N)
    
    sut = Coord(x: -10, y: -10).asPolar()
    XCTAssertTrue(sut.mag == 14 && sut.dir == .SW) // round down mag
    
    sut = Coord(x: 100, y: 1).asPolar()
    XCTAssertTrue(sut.mag == 100 && sut.dir == .E) // round down mag
  }
  
  func testAddition() {
    var result: Coord
    
    result = .init(x: 0, y: 0) + .init(x: 6, y: 8)
    XCTAssertTrue(result.x == 6 && result.y == 8)
    
    result = .init(x: -70, y: 20) + .init(x: 10, y: -10)
    XCTAssertTrue(result.x == -60 && result.y == 10)
  }
  
  func testSubtraction() {
    var result: Coord
    
    result = .init(x: -70, y: 20) - .init(x: 10, y: -10)
    XCTAssertTrue(result.x == -80 && result.y == 30)
  }
  
  func testMultiplication() {
    var result: Coord
    
    result = .init(x: 0, y: 0) * 1
    XCTAssertTrue(result.x == 0 && result.y == 0)
    
    result = .init(x: 1, y: 1) * -5
    XCTAssertTrue(result.x == -5 && result.y == -5)
    
    result = .init(x: 11, y: 5) * -5
    XCTAssertTrue(result.x == -55 && result.y == -25)
  }
  
  func testDirAddition() {
    var result: Coord
    
    result = .init(x: 0, y: 0) + Dir(dir: .center)
    XCTAssertTrue(result.x == 0 && result.y == 0)
    
    result = .init(x: 0, y: 0) + Dir(dir: .E)
    XCTAssertTrue(result.x == 1 && result.y == 0)
    
    result = .init(x: 0, y: 0) + Dir(dir: .W)
    XCTAssertTrue(result.x == -1 && result.y == 0)
    
    result = .init(x: 0, y: 0) + Dir(dir: .SW)
    XCTAssertTrue(result.x == -1 && result.y == -1)
  }
  
  func testDirSubtraction() {
    var result: Coord
    
    result = .init(x: 0, y: 0) - Dir(dir: .center)
    XCTAssertTrue(result.x == 0 && result.y == 0)
    
    result = .init(x: 0, y: 0) - Dir(dir: .E)
    XCTAssertTrue(result.x == -1 && result.y == 0)
    
    result = .init(x: 0, y: 0) - Dir(dir: .W)
    XCTAssertTrue(result.x == 1 && result.y == 0)
    
    result = .init(x: 0, y: 0) - Dir(dir: .SW)
    XCTAssertTrue(result.x == 1 && result.y == 1)
  }
  
  func testRaySameness() {
    var first: Coord
    var second: Coord
    
    first = .init(x: 0, y: 0)
    second = .init(x: 10, y: 11)
    XCTAssertEqual(first.raySameness(other: second), 1.0) // special case - zero vector
    XCTAssertEqual(second.raySameness(other: first), 1.0) // special case - zero vector
    XCTAssertEqual(second.raySameness(other: .init(dir: .center)), 1.0) // special case - zero vector
    
    first = second
    XCTAssertEqual(first.raySameness(other: second), 1.0, accuracy: 0.0001)
    
    XCTAssertEqual(Coord(x: -10, y: -10).raySameness(other: .init(x: 10, y: 10)), -1, accuracy: 0.0001)
    
    first = .init(x: 0, y: 11)
    second = .init(x: 20, y: 0)
    XCTAssertEqual(first.raySameness(other: second), 0.0, accuracy: 0.0001)
    XCTAssertEqual(second.raySameness(other: first), 0.0, accuracy: 0.0001)
    
    first = .init(x: 0, y: 444)
    second = .init(x: 113, y: 113)
    XCTAssertEqual(first.raySameness(other: second), 0.707106781, accuracy: 0.0001)
    
    second = .init(x: 113, y: -113)
    XCTAssertEqual(first.raySameness(other: second), -0.707106781, accuracy: 0.0001)
  }
}
