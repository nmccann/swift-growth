import XCTest
import Nimble
@testable import domain

class DirectionTests: XCTestCase {
  func testRotate() {
    let sut = Direction.northEast
    expect(sut.rotate(n: 1)) == .east
    expect(sut.rotate(n: 2)) == .southEast
    expect(sut.rotate(n: -1)) == .north
    expect(sut.rotate(n: -2)) == .northWest
    expect(sut) == .north.rotate(n: 1)
    expect(Direction.southWest.rotate(n: -2)) == .southEast
  }
  
  func testAsNormalizedCoord() {
    var sut: Coord
    
    sut = Direction.southWest.asNormalizedCoord()
    expect(sut) == Coord(x: -1, y: -1)
    
    sut = Direction.south.asNormalizedCoord()
    expect(sut) == Coord(x: 0, y: -1)
    
    sut = Direction.southEast.asNormalizedCoord()
    expect(sut) == Coord(x: 1, y: -1)
    
    sut = Direction.west.asNormalizedCoord()
    expect(sut) == Coord(x: -1, y: 0)
    
    sut = Direction.east.asNormalizedCoord()
    expect(sut) == Coord(x: 1, y: 0)
    
    sut = Direction.northWest.asNormalizedCoord()
    expect(sut) == Coord(x: -1, y: 1)
    
    sut = Direction.north.asNormalizedCoord()
    expect(sut) == Coord(x: 0, y: 1)
    
    sut = Direction.northEast.asNormalizedCoord()
    expect(sut) == Coord(x: 1, y: 1)
  }
  
  func testAsNormalizedPolar() {
    var sut: Polar
    
    sut = Direction.southWest.asNormalizedPolar()
    expect(sut) == Polar(magnitude: 1, direction: .southWest)
    
    sut = Direction.south.asNormalizedPolar()
    expect(sut) == Polar(magnitude: 1, direction: .south)
    
    sut = Direction.southEast.asNormalizedPolar()
    expect(sut) == Polar(magnitude: 1, direction: .southEast)
    
    sut = Direction.west.asNormalizedPolar()
    expect(sut) == Polar(magnitude: 1, direction: .west)
    
    sut = Direction.east.asNormalizedPolar()
    expect(sut) == Polar(magnitude: 1, direction: .east)
    
    sut = Direction.northWest.asNormalizedPolar()
    expect(sut) == Polar(magnitude: 1, direction: .northWest)
    
    sut = Direction.north.asNormalizedPolar()
    expect(sut) == Polar(magnitude: 1, direction: .north)
    
    sut = Direction.northEast.asNormalizedPolar()
    expect(sut) == Polar(magnitude: 1, direction: .northEast)
  }
}
