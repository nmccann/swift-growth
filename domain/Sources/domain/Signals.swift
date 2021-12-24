import Foundation
import Surge
import Algorithms

let SIGNAL_MIN = 0.0
let SIGNAL_MAX = 255.0 // Equivalent to UInt8.max
let SIGNAL_DAMPING = 1.0 - (1.0 / SIGNAL_MAX)

public struct Signals {
  var layers: [Layer]


  init(layers: Int, sizeX: Int, sizeY: Int) {
    self.layers = .init(repeating: .init(numCols: sizeX, numRows: sizeY), count: layers)
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

    grid.visitNeighborhood(loc: loc, radius: radius) { neighborLoc in
      if layers[layer][neighborLoc.x, neighborLoc.y] < SIGNAL_MAX {
        layers[layer][neighborLoc.x, neighborLoc.y] = min(SIGNAL_MAX, layers[layer][neighborLoc.x, neighborLoc.y] + neighborIncreaseAmount)
      }
    }

    if layers[layer][loc.x, loc.y] < SIGNAL_MAX {
      layers[layer][loc.x, loc.y] = min(SIGNAL_MAX, layers[layer][loc.x, loc.y] + centerIncreaseAmount)
    }
  }

  mutating func zeroFill() {
    layers = layers.map {
      var result = $0
      result.zeroFill()
      return result
    }
  }

  mutating func fade(layer: Int, by damping: Double) {
    layers[layer].data = Surge.mul(damping, layers[layer].data)
  }

  subscript(layer: Int) -> Layer {
    get {
      layers[layer]
    }

    set {
      layers[layer] = newValue
    }
  }

  struct Layer {
    var data: Matrix<Double>

    init(numCols: Int, numRows: Int) {
      data = .init(rows: numRows, columns: numCols, repeatedValue: 0)
    }

    mutating func zeroFill() {
      data = .init(rows: data.rows, columns: data.columns, repeatedValue: 0)
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
