import Foundation

// Measures the distance to the nearest barrier in the forward
// direction. If non found, returns the maximum sensor value.
// Maps the result to the sensor range 0.0..1.0.
struct LongProbePopulationForwardSensor: Sensor {
  func get(for individual: Indiv, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    let distance = individual.probeDistance.long
    return populationCount(from: individual.loc, in: individual.lastDirection, for: distance, on: grid) / Double(distance)
  }
}

private extension LongProbePopulationForwardSensor {
  /// Returns the number of locations to the next agent in the specified
  /// direction, not including loc. If the probe encounters a boundary or a
  /// barrier before reaching the provided distance, returns distance.
  /// Returns 0..distance.
  func populationCount(from loc: Coord, in direction: Direction, for distance: Int, on grid: Grid) -> Double {
    var loc = loc
    assert(distance > 0)
    var count = 0
    loc = loc + direction
    var numLocsToTest = distance
    while numLocsToTest > 0 && grid.isInBounds(loc: loc) && grid.isEmptyAt(loc: loc) {
      count += 1
      loc = loc + direction
      numLocsToTest -= 1
    }

    if numLocsToTest > 0 && (!grid.isInBounds(loc: loc) || grid.isBarrierAt(loc: loc)) {
      return Double(distance)
    } else {
      return Double(count)
    }
  }
}

