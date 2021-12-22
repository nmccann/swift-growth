import Foundation

let BARRIER = 0xffff

class Grid {
  var data: [Column]
  var barrierLocations: [Coord] = []
  var barrierCenters: [Coord] = []
  let size: (x: Int, y: Int)

  init(sizeX: Int, sizeY: Int) {
    data = .init(repeating: .init(numRows: sizeY), count: sizeX)
    self.size = (x: sizeX, y: sizeY)
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

  func isInBounds(loc: Coord) -> Bool {
    loc.x >= 0 && loc.x < size.x && loc.y >= 0 && loc.y < size.y
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
    loc.x == 0 || loc.x == size.x - 1 || loc.y == 0 || loc.y == size.y - 1
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

    func drawBox(min: (x: Int, y: Int), max: (x: Int, y: Int)) {
      for x in min.x...max.x {
        for y in min.y...max.y {
          grid.set(x: x, y: y, val: BARRIER)
          barrierLocations.append(.init(x: x, y: y))
        }
      }
    }

    switch type {
    case .verticalBarConstant:
      let min = (x: size.x / 2, y: size.y / 4)
      let max = (x: min.x + 1, y: min.y + size.y / 2)
      drawBox(min: min, max: max)
    case .verticalBarRandom:
      //TODO: Make less sensitive to grid size (fails if height / 2 - 20 is less than 20)
      let min = (x: Int.random(in: 20...(size.x - 20)), y: Int.random(in: 20...(size.y / 2 - 20)))
      let max = (x: min.x + 1, y: min.y + size.y / 2)
      drawBox(min: min, max: max)
    case .fiveBlocks: return //TODO
    case .horizontalBarConstant: return //TODO
    case .threeIslandsRandom: return // TODO
    case .spotsRandom:
      let numberOfLocations = 5
      let radius = 5.0

      for _ in 0..<numberOfLocations {
        let loc = Coord(x: .random(in: 0..<size.x), y: .random(in: 0..<size.y))
        visitNeighborhood(loc: loc, radius: radius) {
          grid.set(loc: $0, val: BARRIER)
          barrierLocations.append($0)
        }
      }
    }
  }

  func getBarrierLocations() -> [Coord] {
    barrierLocations
  }

  func getBarrierCenters() -> [Coord] {
    barrierCenters
  }

  func visitNeighborhood(loc: Coord, radius: Double, f: (Coord) -> Void) {
    for dx in (-min(Int(radius), loc.x)...min(Int(radius), (size.x - loc.x) - 1)) {
      let x = loc.x + dx
      assert(x >= 0 && x < size.x)
      let extentY = Int((pow(radius, 2) - pow(Double(dx), 2)).squareRoot())

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
