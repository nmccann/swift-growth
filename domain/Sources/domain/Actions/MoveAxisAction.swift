import Foundation

struct MoveAxisAction: Action {
  let axis: WritableKeyPath<CGPoint, CGFloat>

  init(_ axis: WritableKeyPath<CGPoint, CGFloat>) {
    self.axis = axis
  }

  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Parameters) {
    result.movePotential[keyPath: axis] += level
  }
}
