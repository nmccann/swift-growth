import Foundation

let SIGNAL_MIN = 0
let SIGNAL_MAX = 255 // Equivalent to UInt8.max

struct Signals {
  var data: [Layer]


  init(layers: Int, sizeX: Int, sizeY: Int) {
    data = .init(repeating: .init(numCols: sizeX, numRows: sizeY), count: layers)
  }

  func getMagnitude(layer: Int, loc: Coord) -> Int {
    data[layer][loc.x][loc.y]
  }

  // Increases the specified location by centerIncreaseAmount,
  // and increases the neighboring cells by neighborIncreaseAmount

  // Is it ok that multiple readers are reading this container while
  // this single thread is writing to it?  todo!!!
  mutating func increment(layer: Int, loc: Coord) {
    let radius = 1.5
    let centerIncreaseAmount = 2
    let neighborIncreaseAmount = 1

    grid.visitNeighborhood(loc: loc, radius: radius) { neighborLoc in
      if data[layer][neighborLoc.x][neighborLoc.y] < SIGNAL_MAX {
        data[layer][neighborLoc.x][neighborLoc.y] = min(SIGNAL_MAX, data[layer][neighborLoc.x][neighborLoc.y] + neighborIncreaseAmount)
      }
    }

    if data[layer][loc.x][loc.y] < SIGNAL_MAX {
      data[layer][loc.x][loc.y] = min(SIGNAL_MAX, data[layer][loc.x][loc.y] + centerIncreaseAmount)
    }
  }

  mutating func zeroFill() {
    data = data.map {
      var result = $0
      result.zeroFill()
      return result
    }
  }

  mutating func fade(layer: Int) {
    let fadeAmount = 1

    for x in 0..<p.sizeX {
      for y in 0..<p.sizeY {
        if data[layer][x][y] >= fadeAmount {
          data[layer][x][y] -= fadeAmount // fade center cell
        } else {
          data[layer][x][y] = 0
        }
      }
    }
  }

  subscript(layer: Int) -> Layer {
    get {
      data[layer]
    }

    set {
      data[layer] = newValue
    }
  }

  struct Layer {
    var data: [Column]

    init(numCols: Int, numRows: Int) {
      data = .init(repeating: .init(numRows: numRows), count: numCols)
    }

    mutating func zeroFill() {
      data = data.map {
        var result = $0
        result.zeroFill()
        return result
      }
    }

    subscript(colNum: Int) -> Column {
      get {
        data[colNum]
      }

      set {
        data[colNum] = newValue
      }
    }
  }

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
  }
}
