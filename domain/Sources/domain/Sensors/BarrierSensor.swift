import Foundation

// Maps current location along axis of 0...grid axis dimension-1 to sensor range 0.0..1.0
struct BarrierSensor: Sensor {
  enum Kind {
    /// Sense the nearest barrier along axis of last movement direction, mapped
    /// to sensor range 0.0..1.0
    case forward

    /// Sense the nearest barrier along axis perpendicular to last movement direction, mapped
    /// to sensor range 0.0..1.0
    case leftRight
  }

  let kind: Kind

  func get(for individual: Indiv, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    switch kind {
    case .forward:
      return barrierDistance(around: individual.loc,
                             direction: individual.lastDirection,
                             distance: individual.probeDistance.short,
                             on: grid)

    case .leftRight:
      return barrierDistance(around: individual.loc,
                             direction: individual.lastDirection.rotate90DegreesClockwise(),
                             distance: individual.probeDistance.short,
                             on: grid)
    }
  }
}

private extension BarrierSensor {
  /// Converts the number of locations (not including loc) to the next barrier location
  /// along opposite directions of the specified axis to the sensor range. If no barriers
  /// are found, the result is sensor mid-range. Ignores agents in the path.
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

