import Foundation

/// Kill forward -- if this action value is > threshold, value is converted to probability
/// of an attempted murder. Probabilities under the threshold are considered 0.0.
/// If this action neuron is enabled but not driven, the neighbors are safe.
struct KillAction: Action {
  /// A value between 0.0 and 1.0; 0.5 is midlevel
  let threshold: Double

  /// Function that when given a value between 0.0 and 1.0, returns true or false
  let probabilityCurve: (Double) -> Bool

  init(threshold: Double = 0.5, probabilityCurve: @escaping (Double) -> Bool = prob2bool(_:)) {
    self.threshold = threshold
    self.probabilityCurve = probabilityCurve
  }

  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Params) {
    var level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
    level *= result.adjustedResponsiveness

    guard level > threshold && probabilityCurve((level - ACTION_MIN) / ACTION_RANGE) else {
      return
    }

    let otherLoc = result.individual.loc + result.individual.lastDirection

    guard grid.isInBounds(loc: otherLoc) && grid.isOccupiedAt(loc: otherLoc) else {
      return
    }

    guard case .occupied(by: let other) = grid[otherLoc] else {
      return
    }

    let distance = (result.individual.loc - other.loc).length
    assert(distance == 1)
    result.killed.append(other)
  }
}
