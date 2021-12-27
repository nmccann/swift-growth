import Foundation

// Measures the distance to the nearest other individual in the
// forward direction. If none found, returns the maximum sensor value.
// Maps the result to the sensor range 0.0..1.0.
struct LongProbeBarrierForwardSensor: Sensor {
  func get(for individual: Indiv, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    let distance = individual.probeDistance.long
    return barrierCount(from: individual.loc, in: individual.lastDirection, for: distance, on: grid) / Double(distance)
  }
}

private extension LongProbeBarrierForwardSensor {
  /// Returns the number of locations to the next barrier in the
  /// specified direction, not including loc. Ignores agents in the way.
  /// If the distance to the border is less than the provided distance
  /// and no barriers are found, returns distance.
  /// Returns 0..distance.
  func barrierCount(from loc: Coord, in direction: Direction, for distance: Int, on grid: Grid) -> Double {
    var loc = loc
    assert(distance > 0)
    var count = 0
    loc = loc + direction
    var numLocsToTest = distance
    while numLocsToTest > 0 && grid.isInBounds(loc: loc) && grid.isBarrierAt(loc: loc) {
      count += 1
      loc = loc + direction
      numLocsToTest -= 1
    }

    if numLocsToTest > 0 && !grid.isInBounds(loc: loc) {
      return Double(distance)
    } else {
      return Double(count)
    }
  }
}

