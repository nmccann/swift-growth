import Foundation

/// Emit signal0 - if this action value is below a threshold, nothing emitted.
/// Otherwise convert the action value to a probability of emitting one unit of
/// signal (pheromone).
/// Pheromones may be emitted immediately (see signals.cpp). If this action neuron
/// is enabled but not driven, nothing will be emitted.
struct EmitSignalAction: Action {
  let layer: Int

  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Params) {
    let emitThreshold = 0.5  // 0.0..1.0; 0.5 is midlevel
    var level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
    level *= result.adjustedResponsiveness

    guard level > emitThreshold && prob2bool(level) else {
      return
    }

    result.signalToLayer = layer
  }
}
