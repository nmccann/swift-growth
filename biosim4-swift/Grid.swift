import Foundation

let BARRIER = 0xffff

class Grid {
  var data: [Column]
  var barrierLocations: [Coord] = []
  var barrierCenters: [Coord] = []

  init(sizeX: Int, sizeY: Int) {
    data = .init(repeating: .init(numRows: sizeY), count: sizeX)
  }

  func nilFill() {
    data = data.map {
      var temp = $0
      temp.nilFill()
      return temp
    }
  }

  func randomFill() {
    data = data.map {
      var temp = $0
      temp.randomFill()
      return temp
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
    at(loc) == nil
  }

  func isBarrierAt(loc: Coord) -> Bool {
    at(loc) == BARRIER
  }

  /// Occupied means an agent is living there.
  func isOccupiedAt(loc: Coord) -> Bool {
    let value = at(loc)
    return value != nil && value != BARRIER
  }

  func isBorder(loc: Coord) -> Bool {
    loc.x == 0 || loc.x == sizeX() - 1 || loc.y == 0 || loc.y == sizeY() - 1
  }

  func at(_ loc: Coord) -> Int? {
    data[loc.x][loc.y]
  }

  func at(x: Int, y: Int) -> Int? {
    data[x][y]
  }

  func set(loc: Coord, val: Int?) {
    data[loc.x][loc.y] = val
  }

  func set(x: Int, y: Int, val: Int?) {
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

  // This generates barrier points, which are grid locations with value
  // BARRIER. A list of barrier locations is saved in private member
  // Grid::barrierLocations and, for some scenarios, Grid::barrierCenters.
  // Those members are available read-only with Grid::getBarrierLocations().
  // This function assumes an empty grid. This is typically called by
  // the main simulator thread after Grid::init() or Grid::zeroFill().

  // This file typically is under constant development and change for
  // specific scenarios.
  func applyBarrier(_ type: BarrierType?) {
    barrierLocations.removeAll()
    barrierCenters.removeAll() // used only for some barrier types

    guard let type = type else {
      return
    }

    //TODO: Implement from createBarrier.cpp
    switch type {
    case .verticalBarConstant: return
    case .verticalBarRandom: return
    case .fiveBlocks: return
    case .horizontalBarConstant: return
    case .threeIslandsRandom: return
    case .spots: return
    }
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
    var data: [Int?]

    init(numRows: Int) {
      data = .init(repeating: nil, count: numRows)
    }

    mutating func nilFill() {
      data = data.map { _ in nil }
    }

    mutating func randomFill() {
      data = data.map { _ in
        if Bool.random() == false {
          return nil
        } else {
          return Bool.random() == false ? BARRIER : 1
        }
      }
    }

    subscript(rowNum: Int) -> Int? {
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
