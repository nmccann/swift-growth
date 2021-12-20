import Foundation

func getPopulationDensityAlongAxis(loc: Coord, dir: Dir) -> Double {
  // Converts the population along the specified axis to the sensor range. The
  // locations of neighbors are scaled by the inverse of their distance times
  // the positive absolute cosine of the difference of their angle and the
  // specified axis. The maximum positive or negative magnitude of the sum is
  // about 2*radius. We don't adjust for being close to a border, so populations
  // along borders and in corners are commonly sparser than away from borders.
  // An empty neighborhood results in a sensor value exactly midrange; below
  // midrange if the population density is greatest in the reverse direction,
  // above midrange if density is greatest in forward direction.
  assert(dir.dir9 != .center) // require a defined axis
  
  var sum = 0.0
  let dirVec = dir.asNormalizedCoord()
  let len = dirVec.floatingLength
  //TODO: Check if this division is redundant - seems like it should be given that we're already dealing with a normalized vector
  let dirVecX = Double(dirVec.x) / len
  let dirVecY = Double(dirVec.y) / len // Unit vector components along dir
  
  func checkOccupancy(tloc: Coord) {
    guard tloc != loc, grid.isOccupiedAt(loc: tloc) else {
      return
    }

    let offset = tloc - loc
    let projection = dirVecX * Double(offset.x) + dirVecY * Double(offset.y) // Magnitude of projection along dir
    let contribution = projection / Double(offset.x * offset.x + offset.y * offset.y)
    sum += contribution
  }
  
  grid.visitNeighborhood(loc: loc, radius: p.populationSensorRadius, f: checkOccupancy(tloc:))
  
  let maxSumMagnitude = 6.0 * p.populationSensorRadius
  assert(sum >= -maxSumMagnitude && sum <= maxSumMagnitude)
  
  var sensorVal = sum / maxSumMagnitude // convert to -1.0...1.0
  sensorVal = (sensorVal + 1.0) / 2.0 // convert to 0.0...1.0
  
  return sensorVal
}

/// Returns the number of locations to the next agent in the specified
/// direction, not including loc. If the probe encounters a boundary or a
/// barrier before reaching the provided distance, returns distance.
/// Returns 0..distance.
func longProbePopulationForward(loc: Coord, dir: Dir, distance: Int) -> Int {
  var loc = loc
  assert(distance > 0)
  var count = 0
  loc = loc + dir
  var numLocsToTest = distance
  while numLocsToTest > 0 && grid.isInBounds(loc: loc) && grid.isEmptyAt(loc: loc) {
    count += 1
    loc = loc + dir
    numLocsToTest -= 1
  }
  
  if numLocsToTest > 0 && (!grid.isInBounds(loc: loc) || grid.isBarrierAt(loc: loc)) {
    return distance
  } else {
    return count
  }
}

/// Returns the number of locations to the next barrier in the
/// specified direction, not including loc. Ignores agents in the way.
/// If the distance to the border is less than the provided distance
/// and no barriers are found, returns distance.
/// Returns 0..distance.
func longProbeBarrierForward(loc: Coord, dir: Dir, distance: Int) -> Int {
  var loc = loc
  assert(distance > 0)
  var count = 0
  loc = loc + dir
  var numLocsToTest = distance
  while numLocsToTest > 0 && grid.isInBounds(loc: loc) && grid.isBarrierAt(loc: loc) {
    count += 1
    loc = loc + dir
    numLocsToTest -= 1
  }
  
  if numLocsToTest > 0 && !grid.isInBounds(loc: loc) {
    return distance
  } else {
    return count
  }
}

/// Converts the number of locations (not including loc) to the next barrier location
/// along opposite directions of the specified axis to the sensor range. If no barriers
/// are found, the result is sensor mid-range. Ignores agents in the path.
func getShortProbeBarrierDistance(loc loc0: Coord, dir: Dir, distance: Int) -> Double {
  var countForward = 0
  var countReverse = 0
  var loc = loc0 + dir
  var numLocsToTest = distance
  
  // Scan positive direction
  while numLocsToTest > 0 && grid.isInBounds(loc: loc) && !grid.isBarrierAt(loc: loc) {
    countForward += 1
    loc = loc + dir
    numLocsToTest -= 1
  }
  
  if numLocsToTest > 0 && !grid.isInBounds(loc: loc) {
    countForward = distance
  }
  
  // Scan negative direction
  numLocsToTest = distance
  loc = loc0 - dir
  while numLocsToTest > 0 && grid.isInBounds(loc: loc) && !grid.isBarrierAt(loc: loc) {
    countReverse += 1
    loc = loc - dir
    numLocsToTest -= 1
  }
  
  if numLocsToTest > 0 && !grid.isInBounds(loc: loc) {
    countReverse = distance
  }
  
  var sensorVal = Double((countForward - countReverse) + distance) // convert to 0...2*distance
  sensorVal = (sensorVal / 2.0) / Double(distance) // convert to 0.0...1.0
  return sensorVal
}

/// returns magnitude of the specified signal layer in a neighborhood, with
/// 0.0..maxSignalSum converted to the sensor range.
func getSignalDensity(loc: Coord, layer: Int) -> Double {
  var countLocs = 0
  var sum = 0.0
  
  func signalCheck(tloc: Coord) {
    countLocs += 1
    sum += Double(signals.getMagnitude(layer: layer, loc: tloc))
  }
  
  grid.visitNeighborhood(loc: loc, radius: Double(p.signalSensorRadius), f: signalCheck(tloc:))
  let maxSum = Double(countLocs * SIGNAL_MAX)
  return sum / maxSum // convert to 0.0...1.0
}

/// Converts the signal density along the specified axis to sensor range. The
/// values of cell signal levels are scaled by the inverse of their distance times
/// the positive absolute cosine of the difference of their angle and the
/// specified axis. The maximum positive or negative magnitude of the sum is
/// about 2*radius*SIGNAL_MAX (?). We don't adjust for being close to a border,
/// so signal densities along borders and in corners are commonly sparser than
/// away from borders.
func getSignalDensityAlongAxis(loc: Coord, dir: Dir, layer: Int) -> Double {
  assert(dir.dir9 != .center) // require a defined axis

  var sum = 0.0
  let dirVec = dir.asNormalizedCoord()
  let len = dirVec.floatingLength
  //TODO: Check if this division is redundant - seems like it should be given that we're already dealing with a normalized vector
  let dirVecX = Double(dirVec.x) / len
  let dirVecY = Double(dirVec.y) / len // Unit vector components along dir

  func signalCheck(tloc: Coord) {
    guard tloc != loc else {
      return
    }

    let offset = tloc - loc
    let projection = dirVecX * Double(offset.x) + dirVecY * Double(offset.y) // Magnitude of projection along dir
    let contribution = (projection * Double(signals.getMagnitude(layer: layer, loc: loc))) / Double(offset.x * offset.x + offset.y * offset.y)
    sum += contribution
  }

  grid.visitNeighborhood(loc: loc,
                         radius: Double(p.signalSensorRadius),
                         f: signalCheck(tloc:))

  let maxSumMagnitude = 6.0 * Double(p.signalSensorRadius * SIGNAL_MAX)
  assert(sum >= -maxSumMagnitude && sum <= maxSumMagnitude)

  var sensorVal = sum / maxSumMagnitude // convert to -1.0...1.0
  sensorVal = (sensorVal + 1.0) / 2.0 // convert to 0.0...1.0

  return sensorVal
}

// Returns 0.0..1.0
func genomeSimilarity(_ lhs: Genome, _ rhs: Genome) -> Double {
  //TODO: Implement correctly
  .random(in: 0.0...1.0)
}
