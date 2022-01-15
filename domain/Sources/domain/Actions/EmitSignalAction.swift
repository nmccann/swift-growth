import Foundation

/// Emit signal to given layer - if this action value is below a threshold, nothing emitted.
/// Otherwise convert the action value to a probability of emitting one unit of signal (pheromone).
/// If this action neuron is enabled but not driven, nothing will be emitted.
struct EmitSignalAction: Action {
  /// Layer upon which to emit if adjusted level exceeds threshold
  let layer: Int

  /// A value between 0.0 and 1.0; 0.5 is midlevel
  let threshold: Double

  /// Function that when given a value between 0.0 and 1.0, returns true or false
  let probabilityCurve: (Double) -> Bool

  init(layer: Int, threshold: Double = 0.5, probabilityCurve: @escaping (Double) -> Bool = prob2bool(_:)) {
    self.layer = layer
    self.threshold = threshold
    self.probabilityCurve = probabilityCurve
  }

  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Params) {
    var level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
    level *= result.adjustedResponsiveness

    guard level > threshold && probabilityCurve(level) else {
      return
    }

    result.signalToLayer = layer
  }
}
