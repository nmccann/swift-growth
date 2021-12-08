import Foundation

struct Polar {
  let mag: Int
  let dir: Dir

  init(mag: Int = 0, dir: Compass = .center) {
    self.mag = mag
    self.dir = .init(dir: dir)
  }

  init(mag: Int, dir: Dir) {
    self.mag = mag
    self.dir = dir
  }

  func asCoord() -> Coord {
    guard dir.dir9 != .center else {
      return .init(x: 0, y: 0)
    }

    let radiansPerSlice = (Double.pi * 2) / 8
    let compassToRadians = [5, 6, 7, 4, 0, 0, 3, 2, 1].map { $0 * radiansPerSlice }
    let x = Int(round(Double(mag) * cos(compassToRadians[dir.dir9.rawValue])))
    let y = Int(round(Double(mag) * sin(compassToRadians[dir.dir9.rawValue])))
    return .init(x: x, y: y)
  }
}
