import XCTest
import Nimble
@testable import domain

class PolarTests: XCTestCase {
  func testAsCoord() {
    var sut: Coord
    
    sut = Polar(magnitude: 0, direction: nil).asCoord()
    expect(sut) == .zero
    
    sut = Polar(magnitude: 10, direction: nil).asCoord()
    expect(sut) == .zero
    
    sut = Polar(magnitude: 20, direction: .north).asCoord()
    expect(sut) == Coord(x: 0, y: 20)
    
    sut = Polar(magnitude: 12, direction: .west).asCoord()
    expect(sut) == Coord(x: -12, y: 0)
    
    sut = Polar(magnitude: 14, direction: .northEast).asCoord()
    expect(sut) == Coord(x: 10, y: 10)
    
    sut = Polar(magnitude: -14, direction: .northEast).asCoord()
    expect(sut) == Coord(x: -10, y: -10)
    
    sut = Polar(magnitude: 14, direction: .east).asCoord()
    expect(sut) == Coord(x: 14, y: 0)
    
    sut = Polar(magnitude: -14, direction: .east).asCoord()
    expect(sut) == Coord(x: -14, y: 0)
  }
}
