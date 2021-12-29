import XCTest
import Nimble
@testable import domain

class CoordTests: XCTestCase {
  func testIsNormalized() {
    var sut: Coord = .init(x: 9, y: 101)
    expect(sut.isNormalized) == false
    
    sut = .init(x: 0, y: 0)
    expect(sut.isNormalized) == true
    
    sut = .init(x: 0, y: 1)
    expect(sut.isNormalized) == true
    
    sut = .init(x: 1, y: 1)
    expect(sut.isNormalized) == true
    
    sut = .init(x: -1, y: 0)
    expect(sut.isNormalized) == true
    
    sut = .init(x: -1, y: -1)
    expect(sut.isNormalized) == true
    
    sut = .init(x: 0, y: 2)
    expect(sut.isNormalized) == false
    
    sut = .init(x: 1, y: 2)
    expect(sut.isNormalized) == false
    
    sut = .init(x: -1, y: 2)
    expect(sut.isNormalized) == false
    
    sut = .init(x: -2, y: 0)
    expect(sut.isNormalized) == false
  }
  
  func testNormalizedDirection() {
    var sut: Coord
    
    sut = .init(x: 0, y: 0).normalize()
    expect(sut) == .zero
    expect(sut.asDir()).to(beNil())
    
    sut = .init(x: 0, y: 1).normalize()
    expect(sut) == Coord(x: 0, y: 1)
    expect(sut.asDir()) == .north
    
    sut = .init(x: -1, y: 1).normalize()
    expect(sut) == Coord(x: -1, y: 1)
    expect(sut.asDir()) == .northWest
    
    sut = .init(x: 100, y: 5).normalize()
    expect(sut) == Coord(x: 1, y: 0)
    expect(sut.asDir()) == .east
    
    sut = .init(x: 100, y: 105).normalize()
    expect(sut) == Coord(x: 1, y: 1)
    expect(sut.asDir()) == .northEast
    
    sut = .init(x: -5, y: 101).normalize()
    expect(sut) == Coord(x: 0, y: 1)
    expect(sut.asDir()) == .north
    
    sut = .init(x: -500, y: 10).normalize()
    expect(sut) == Coord(x: -1, y: 0)
    expect(sut.asDir()) == .west
    
    sut = .init(x: -500, y: -490).normalize()
    expect(sut) == Coord(x: -1, y: -1)
    expect(sut.asDir()) == .southWest
    
    sut = .init(x: -1, y: -490).normalize()
    expect(sut) == Coord(x: 0, y: -1)
    expect(sut.asDir()) == .south
    
    sut = .init(x: 1101, y: -1090).normalize()
    expect(sut) == Coord(x: 1, y: -1)
    expect(sut.asDir()) == .southEast
    
    sut = .init(x: 1101, y: -3).normalize()
    expect(sut) == Coord(x: 1, y: 0)
    expect(sut.asDir()) == .east
  }
  
  func testLength() {
    var sut: Coord
    
    sut = .init(x: 0, y: 0)
    expect(sut.length) == 0
    
    sut = .init(x: 0, y: 1)
    expect(sut.length) == 1
    
    sut = .init(x: -1, y: 0)
    expect(sut.length) == 1
    
    sut = .init(x: -1, y: -1)
    expect(sut.length) == 1 // round down
    
    sut = .init(x: 22, y: 0)
    expect(sut.length) == 22
    
    sut = .init(x: 22, y: 22)
    expect(sut.length) == 31 // round down
    
    sut = .init(x: 10, y: -10)
    expect(sut.length) == 14 // round down
    
    sut = .init(x: -310, y: 0)
    expect(sut.length) == 310
  }
  
  func testAsPolar() {
    var sut: Polar
    
    sut = Coord(x: 0, y: 0).asPolar()
    expect(sut) == Polar(magnitude: 0, direction: nil)
    
    sut = Coord(x: 0, y: 1).asPolar()
    expect(sut) == Polar(magnitude: 1, direction: .north)
    
    sut = Coord(x: -10, y: -10).asPolar()
    expect(sut) == Polar(magnitude: 14, direction: .southWest) // round down magnitude
    
    sut = Coord(x: 100, y: 1).asPolar()
    expect(sut) == Polar(magnitude: 100, direction: .east) // round down magnitude
  }
  
  func testAddition() {
    var result: Coord
    
    result = .init(x: 0, y: 0) + .init(x: 6, y: 8)
    expect(result) == Coord(x: 6, y: 8)
    
    result = .init(x: -70, y: 20) + .init(x: 10, y: -10)
    expect(result) == Coord(x: -60, y: 10)
  }
  
  func testSubtraction() {
    var result: Coord
    
    result = .init(x: -70, y: 20) - .init(x: 10, y: -10)
    expect(result) == Coord(x: -80, y: 30)
  }
  
  func testMultiplication() {
    var result: Coord
    
    result = .init(x: 0, y: 0) * 1
    expect(result) == .zero
    
    result = .init(x: 1, y: 1) * -5
    expect(result) == Coord(x: -5, y: -5)
    
    result = .init(x: 11, y: 5) * -5
    expect(result) == Coord(x: -55, y: -25)
  }
  
  func testDirAddition() {
    var result: Coord
    
    result = .init(x: 0, y: 0) + .east
    expect(result) == Coord(x: 1, y: 0)
    
    result = .init(x: 0, y: 0) + .west
    expect(result) == Coord(x: -1, y: 0)
    
    result = .init(x: 0, y: 0) + .southWest
    expect(result) == Coord(x: -1, y: -1)
  }
  
  func testDirSubtraction() {
    var result: Coord
    
    result = .init(x: 0, y: 0) - .east
    expect(result) == Coord(x: -1, y: 0)
    
    result = .init(x: 0, y: 0) - .west
    expect(result) == Coord(x: 1, y: 0)
    
    result = .init(x: 0, y: 0) - .southWest
    expect(result) == Coord(x: 1, y: 1)
  }
}
