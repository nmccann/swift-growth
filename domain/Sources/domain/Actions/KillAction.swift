import Foundation

/// Kill forward -- if this action value is > threshold, value is converted to probability
/// of an attempted murder. Probabilities under the threshold are considered 0.0.
/// If this action neuron is enabled but not driven, the neighbors are safe.
struct KillAction: Action {
  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Params) {
    let killThreshold = 0.5  // 0.0..1.0; 0.5 is midlevel
    var level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
    level *= result.adjustedResponsiveness

    guard level > killThreshold && prob2bool((level - ACTION_MIN) / ACTION_RANGE) else {
      return
    }

    let otherLoc = result.indiv.loc + result.indiv.lastDirection

    guard grid.isInBounds(loc: otherLoc) && grid.isOccupiedAt(loc: otherLoc) else {
      return
    }

    let indiv2 = grid.getIndiv(loc: otherLoc)
    let distance = (result.indiv.loc - indiv2.loc).length
    assert(distance == 1)
    result.killed.append(indiv2)
  }
}
