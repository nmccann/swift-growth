import Foundation

/// Returns magnitude of signal on given layer with
/// 0.0...maxSignalSum converted to sensorRange 0.0...1.0
struct SignalSensor: Sensor {
  enum Kind {
    /// Sense signal density in local neighborhood
    case neighborhood

    /// Sense signal density along axis of last movement direction
    case forward

    /// Sense signal density along an axis perpendicular to last movement direction
    case leftRight
  }

  let kind: Kind
  let layer: Int

  func get(for individual: Individual, on world: World) -> Double {
    switch kind {
    case .neighborhood:
      return density(around: individual.loc, distance: Double(world.parameters.signalSensorRadius), on: world)

    case .forward:
      return densityAlongAxis(around: individual.loc,
                              direction: individual.lastDirection,
                              distance: Double(world.parameters.signalSensorRadius),
                              on: world)

    case .leftRight:
      return densityAlongAxis(around: individual.loc,
                              direction: individual.lastDirection.rotate90DegreesClockwise(),
                              distance: Double(world.parameters.signalSensorRadius),
                              on: world)
    }
  }
}

private extension SignalSensor {
  /// returns magnitude of the specified signal layer in a neighborhood, with
  /// 0.0..maxSignalSum converted to the sensor range.
  func density(around location: Coord, distance: Double, on world: World) -> Double {
    var countLocs = 0
    var sum = 0.0

    func signalCheck(tloc: Coord) {
      countLocs += 1
      sum += Double(world.signals.getMagnitude(layer: layer, loc: tloc))
    }

    world.grid.visitNeighborhood(loc: location, radius: distance, f: signalCheck(tloc:))
    let maxSum = Double(countLocs) * SIGNAL_MAX
    return sum / maxSum // convert to 0.0...1.0
  }

  /// Converts the signal density along the specified axis to sensor range. The
  /// values of cell signal levels are scaled by the inverse of their distance times
  /// the positive absolute cosine of the difference of their angle and the
  /// specified axis. The maximum positive or negative magnitude of the sum is
  /// about 2*radius*SIGNAL_MAX (?). We don't adjust for being close to a border,
  /// so signal densities along borders and in corners are commonly sparser than
  /// away from borders.
  func densityAlongAxis(around location: Coord, direction: Direction, distance: Double, on world: World) -> Double {
    var sum = 0.0
    let directionVector = direction.asNormalizedCoord()

    func signalCheck(tloc: Coord) {
      guard tloc != location else {
        return
      }

      let offset = tloc - location
      let projectionOnDirection = directionVector.x * offset.x + directionVector.y * offset.y
      let contribution = Double(projectionOnDirection * world.signals.getMagnitude(layer: layer, loc: location)) / Double(offset.x * offset.x + offset.y * offset.y)
      sum += contribution
    }

    world.grid.visitNeighborhood(loc: location,
                           radius: distance,
                           f: signalCheck(tloc:))

    let maxSumMagnitude = 6.0 * distance * SIGNAL_MAX
    assert(sum >= -maxSumMagnitude && sum <= maxSumMagnitude)

    var sensorVal = sum / maxSumMagnitude // convert to -1.0...1.0
    sensorVal = (sensorVal + 1.0) / 2.0 // convert to 0.0...1.0

    return sensorVal
  }
}

