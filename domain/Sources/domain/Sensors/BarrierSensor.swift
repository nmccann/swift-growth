import Foundation

/// Converts the number of locations (not including loc) to the next barrier location
/// along opposite directions of the specified axis to the sensor range. If no barriers
/// are found, the result is sensor mid-range. Ignores agents in the path.
struct BarrierSensor: Sensor {
  /// Sense the nearest barrier in positive and negative direction along axis, mapped
  /// to sensor range 0.0..1.0
  let direction: (Individual) -> Direction

  func get(for individual: Individual, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    barrierDistance(around: individual.loc,
                    direction: direction(individual),
                    distance: individual.probeDistance.short,
                    on: grid).clamped(to: 0...1)
  }
}

private extension BarrierSensor {
  func barrierDistance(around loc0: Coord, direction: Direction, distance: Int, on grid: Grid) -> Double {
    var countForward = 0
    var countReverse = 0
    var loc = loc0 + direction
    var numLocsToTest = distance

    // Scan positive direction
    while numLocsToTest > 0 && grid.isInBounds(loc: loc) && !grid.isBarrierAt(loc: loc) {
      countForward += 1
      loc = loc + direction
      numLocsToTest -= 1
    }

    if numLocsToTest > 0 && !grid.isInBounds(loc: loc) {
      countForward = distance
    }

    // Scan negative direction
    numLocsToTest = distance
    loc = loc0 - direction
    while numLocsToTest > 0 && grid.isInBounds(loc: loc) && !grid.isBarrierAt(loc: loc) {
      countReverse += 1
      loc = loc - direction
      numLocsToTest -= 1
    }

    if numLocsToTest > 0 && !grid.isInBounds(loc: loc) {
      countReverse = distance
    }

    var sensorVal = Double((countForward - countReverse) + distance) // convert to 0...2*distance
    sensorVal = (sensorVal / 2.0) / Double(distance) // convert to 0.0...1.0
    return sensorVal
  }
}

