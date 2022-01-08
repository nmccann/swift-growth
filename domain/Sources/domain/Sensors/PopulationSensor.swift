import Foundation

// Maps current location along axis of 0...grid axis dimension-1 to sensor range 0.0..1.0
struct PopulationSensor: Sensor {
  enum Kind {
    /// Returns population density in neighborhood converted linearly from
    /// sensor range 0.0..1.0
    case neighborhood

    /// Sense population density along axis of last movement direction, mapped
    /// to sensor range 0.0..1.0
    case forward

    /// Sense population density along an axis 90 degrees from last movement direction
    case leftRight
  }

  let kind: Kind
  
  func get(for individual: Individual, on world: World) -> Double {
    switch kind {
    case .neighborhood:
      return density(around: individual.loc,
                     distance: world.parameters.populationSensorRadius,
                     on: world.grid)

    case .forward:
      return densityAlongAxis(around: individual.loc,
                              direction: individual.lastDirection,
                              distance: world.parameters.populationSensorRadius,
                              on: world.grid)

    case .leftRight:
      return densityAlongAxis(around: individual.loc,
                              direction: individual.lastDirection.rotate90DegreesClockwise(),
                              distance: world.parameters.populationSensorRadius,
                              on: world.grid)
    }
  }
}

private extension PopulationSensor {
  func density(around location: Coord, distance: Double, on grid: Grid) -> Double {
    var countLocs = 0
    var countOccupied = 0
    func checkOccupancy(tloc: Coord) {
      countLocs += 1
      if grid.isOccupiedAt(loc: tloc) {
        countOccupied += 1
      }
    }

    grid.visitNeighborhood(loc: location, radius: distance, f: checkOccupancy)
    return Double(countOccupied) / Double(countLocs)
  }

  func densityAlongAxis(around location: Coord, direction: Direction, distance: Double, on grid: Grid) -> Double {
    // Converts the population along the specified axis to the sensor range. The
    // locations of neighbors are scaled by the inverse of their distance times
    // the positive absolute cosine of the difference of their angle and the
    // specified axis. The maximum positive or negative magnitude of the sum is
    // about 2*radius. We don't adjust for being close to a border, so populations
    // along borders and in corners are commonly sparser than away from borders.
    // An empty neighborhood results in a sensor value exactly midrange; below
    // midrange if the population density is greatest in the reverse direction,
    // above midrange if density is greatest in forward direction.
    var sum = 0.0
    let directionVector = direction.asNormalizedCoord()

    func checkOccupancy(tloc: Coord) {
      guard tloc != location, grid.isOccupiedAt(loc: tloc) else {
        return
      }

      let offset = tloc - location
      let projectionOnDirection = directionVector.x * offset.x + directionVector.y * offset.y
      let contribution = Double(projectionOnDirection) / Double(offset.x * offset.x + offset.y * offset.y)
      sum += contribution
    }

    grid.visitNeighborhood(loc: location, radius: distance, f: checkOccupancy(tloc:))

    let maxSumMagnitude = 6.0 * distance
    assert(sum >= -maxSumMagnitude && sum <= maxSumMagnitude)

    var sensorVal = sum / maxSumMagnitude // convert to -1.0...1.0
    sensorVal = (sensorVal + 1.0) / 2.0 // convert to 0.0...1.0

    return sensorVal
  }
}

