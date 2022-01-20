import Foundation
import Surge
import Algorithms

let SIGNAL_MIN = 0.0
let SIGNAL_MAX = 255.0 // Equivalent to UInt8.max
let SIGNAL_DAMPING = 1.0 - (1.0 / SIGNAL_MAX)

public struct Signals: Equatable {
  var layers: [Layer]
  let size: Size

  init(layers: Int, size: Size) {
    self.layers = .init(repeating: .init(numCols: size.width, numRows: size.height), count: layers)
    self.size = size
  }

  func getMagnitude(layer: Int, loc: Coord) -> Int {
    Int(layers[layer].data[loc.x, loc.y])
  }

  // Increases the specified location by centerIncreaseAmount,
  // and increases the neighboring cells by neighborIncreaseAmount

  // Is it ok that multiple readers are reading this container while
  // this single thread is writing to it?  todo!!!
  mutating func increment(layer: Int, loc: Coord) {
    let radius = 1.5
    let centerIncreaseAmount = 2.0
    let neighborIncreaseAmount = 1.0

    visitNeighborhood(loc: loc, radius: radius) { neighborLoc in
      if layers[layer][neighborLoc.x, neighborLoc.y] < SIGNAL_MAX {
        layers[layer][neighborLoc.x, neighborLoc.y] = min(SIGNAL_MAX, layers[layer][neighborLoc.x, neighborLoc.y] + neighborIncreaseAmount)
      }
    }

    if layers[layer][loc.x, loc.y] < SIGNAL_MAX {
      layers[layer][loc.x, loc.y] = min(SIGNAL_MAX, layers[layer][loc.x, loc.y] + centerIncreaseAmount)
    }
  }

  mutating func zeroFill() {
    layers = .init(repeating: .init(numCols: size.width, numRows: size.height), count: layers.count)
  }

  mutating func fade(layer: Int, by damping: Double) {
    layers[layer].data = Surge.mul(damping, layers[layer].data)
  }

  //TODO: Avoid duplicating from Grid
  func visitNeighborhood(loc: Coord, radius: Double, f: (Coord) -> Void) {
    for dx in (-min(Int(radius), loc.x)...min(Int(radius), (size.width - loc.x) - 1)) {
      let x = loc.x + dx
      assert(x >= 0 && x < size.width)
      let extentY = Int((pow(radius, 2) - pow(Double(dx), 2)).squareRoot())

      for dy in (-min(extentY, loc.y)...min(extentY, (size.height - loc.y) - 1)) {
        let y = loc.y + dy
        assert(y >= 0 && y < size.height)
        f(.init(x: x, y: y))
      }
    }
  }

  subscript(layer: Int) -> Layer {
    get {
      layers[layer]
    }

    set {
      layers[layer] = newValue
    }
  }

  struct Layer: Equatable {
    var data: Matrix<Double>

    init(numCols: Int, numRows: Int) {
      data = .init(rows: numRows, columns: numCols, repeatedValue: 0)
    }

    mutating func fade(by damping: Double) {
      data = Surge.mul(SIGNAL_DAMPING, data)
    }

    public subscript(row: Int, column: Int) -> Double {
      get {
        data[row, column]
      }

      set {
        data[row, column] = newValue
      }
    }
  }
}
