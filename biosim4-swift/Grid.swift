import Foundation

let EMPTY = 0
let BARRIER = 0xffff
let NOT_OCCUPIED = Set([EMPTY, BARRIER])

class Grid {
  var data: [Column]
  var barrierLocations: [Coord] = []
  var barrierCenters: [Coord] = []

  init(sizeX: Int, sizeY: Int) {
    data = .init(repeating: .init(numRows: sizeY), count: sizeX)
  }

  func zeroFill() {
    for var column in data {
      column.zeroFill()
    }
  }

  func sizeX() -> Int {
    data.count
  }

  func sizeY() -> Int {
    data[0].size()
  }

  func isInBounds(loc: Coord) -> Bool {
    loc.x >= 0 && loc.x < sizeX() && loc.y >= 0 && loc.y < sizeY()
  }

  func isEmptyAt(loc: Coord) -> Bool {
    at(loc) == EMPTY
  }

  func isBarrierAt(loc: Coord) -> Bool {
    at(loc) == BARRIER
  }

  /// Occupied means an agent is living there.
  func isOccupiedAt(loc: Coord) -> Bool {
    !NOT_OCCUPIED.contains(at(loc))
  }

  func isBorder(loc: Coord) -> Bool {
    loc.x == 0 || loc.x == sizeX() - 1 || loc.y == 0 || loc.y == sizeY() - 1
  }

  func at(_ loc: Coord) -> Int {
    data[loc.x][loc.y]
  }

  func at(x: Int, y: Int) -> Int {
    data[x][y]
  }

  func set(loc: Coord, val: Int) {
    data[loc.x][loc.y] = val
  }

  func set(x: Int, y: Int, val: Int) {
    data[x][y] = val
  }

  func findEmptyLocation() -> Coord {
    //TODO: Original implementation pulls size from the simulator parameters, not sure why though
    let size = (x: sizeX(), y: sizeY())

    while true {
      let loc = Coord(x: .random(in: 0..<size.x),
                      y: .random(in: 0..<size.y))

      if isEmptyAt(loc: loc) {
        return loc
      }
    }
  }

  func createBarrier(barrierType: Int) {
    //TODO: Implement from createBarrier.cpp
  }

  func getBarrierLocations() -> [Coord] {
    barrierLocations
  }

  func getBarrierCenters() -> [Coord] {
    barrierCenters
  }

  func visitNeighborhood(loc: Coord, radius: Double, f: (Coord) -> Void) {
    let size = (x: sizeX(), y: sizeY())

    for dx in (-min(Int(radius), loc.x)...min(Int(radius), (size.x - loc.x) - 1)) {
      let x = loc.x + dx
      assert(x >= 0 && x < size.x)
      let extentY = Int((pow(radius, 2) - pow(Double(dx), 2).squareRoot()))

      for dy in (-min(extentY, loc.y)...min(extentY, (size.y - loc.y) - 1)) {
        let y = loc.y + dy
        assert(y >= 0 && y < size.y)
        f(.init(x: x, y: y))
      }
    }
  }

  subscript(columnXNum: Int) -> Column {
    get {
      data[columnXNum]
    }

    set {
      data[columnXNum] = newValue
    }
  }
}

extension Grid {
  struct Column {
    var data: [Int]

    init(numRows: Int) {
      data = .init(repeating: 0, count: numRows)
    }

    mutating func zeroFill() {
      data = data.map { _ in 0 }
    }

    subscript(rowNum: Int) -> Int {
      get {
        data[rowNum]
      }

      set {
        data[rowNum] = newValue
      }
    }

    func size() -> Int {
      data.count
    }
  }
}
