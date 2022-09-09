import Foundation

/// Given a factor in the range 0.0..1.0, return a bool with the
/// probability of it being true proportional to factor. For example, if
/// factor == 0.2, then there is a 20% chance this function will
/// return true.
func prob2bool(_ factor: Double) -> Bool {
  assert(factor >= 0.0 && factor <= 1.0)
  return Double.random(in: 0.0...1.0) < factor
}

/// This takes a probability from 0.0..1.0 and adjusts it according to an
/// exponential curve. The steepness of the curve is determined by the K factor
/// which is a small positive integer. This tends to reduce the activity level
/// a bit (makes the peeps less reactive and jittery).
func responseCurve(_ r: Double, factor: Int) -> Double {
  let k = Double(factor)
  return pow(r - 2.0, -2.0 * k) - pow(2.0, -2.0 * k) * (1.0 - r)
}

/**********************************************************************************
 Action levels are driven by sensors or internal neurons as connected by an agent's
 neural net brain. Each agent's neural net is reevaluated once each simulator
 step (simStep). After evaluating the action neuron outputs, this function is
 called to execute the actions according to their output levels. This function is
 called in multi-threaded mode and operates on a single individual while other
 threads are doing to the same to other individuals.
 
 Action (their output) values arrive here as floating point values of arbitrary
 range (because they are the raw sums of zero or more weighted inputs) and will
 eventually be converted in this function to a probability 0.0..1.0 of actually
 getting executed.
 
 For the various possible action neurons, if they are driven by a sufficiently
 strong level, we do this:
 
 MOVE_* actions- queue our agent for deferred movement with peeps.queueForMove(); the
 queue will be executed at the end of the multithreaded loop in a single thread.
 SET_RESPONSIVENESS action - immediately change individual.responsiveness to the action
 level scaled to 0.0..1.0 (because we have exclusive access to this member in
 our own individual during this function)
 SET_OSCILLATOR_PERIOD action - immediately change our individual's individual.oscPeriod
 to the action level exponentially scaled to 2..2048 (TBD)
 EMIT_SIGNALn action(s) - immediately increment the signal level at our agent's
 location using signals.increment() (using a thread-safe call)
 KILL_FORWARD action - queue the other agent for deferred death with
 peeps.queueForDeath()
 
 The deferred movement and death queues will be emptied by the caller at the end of the
 simulator step by endOfSimStep() in a single thread after all individuals have been
 evaluated multithreadedly.
 **********************************************************************************/
func executeActions(for individual: Individual,
                    levels: [(Action, Double)],
                    on grid: Grid,
                    with parameters: Parameters,
                    probabilityCurve: (Double) -> Bool) -> ActionResult {
  let curve: (Double) -> Double = { [kFactor=parameters.responsiveness.kFactor] value in responseCurve(value, factor: kFactor) }

  var result = levels.reduce(into: ActionResult(individual: individual, killed: [], responseCurve: curve)) { partialResult, actionAndLevel in
    actionAndLevel.0.apply(to: &partialResult, level: actionAndLevel.1, on: grid, with: parameters)
  }

  // Convert the accumulated X, Y sums to the range -1.0..1.0 and scale by the
  // individual's responsiveness (0.0..1.0) (adjusted by a curve)
  var moveX = tanh(result.movePotential.x)
  var moveY = tanh(result.movePotential.y)
  moveX *= result.adjustedResponsiveness
  moveY *= result.adjustedResponsiveness

  // The probability of movement along each axis is the absolute value
  let probX = probabilityCurve(abs(moveX)) ? 1 : 0 // convert abs(level) to 0 or 1
  let probY = probabilityCurve(abs(moveY)) ? 1 : 0 // convert abs(level) to 0 or 1

  // The direction of movement (if any) along each axis is the sign
  let signumX = moveX < 0.0 ? -1 : 1
  let signumY = moveY < 0.0 ? -1 : 1

  // Generate a normalized movement offset, where each component is -1, 0, or 1
  let movementOffset = Coord(x: Int(probX * signumX), y: Int(probY * signumY))

  // Move there if it's a valid location
  let proposedLocation = result.individual.loc + movementOffset

  if grid.isInBounds(loc: proposedLocation) && grid.isEmptyAt(loc: proposedLocation) {
    result.newLocation = proposedLocation
  }

  return result
}

public struct ActionResult {
  var individual: Individual
  var newLocation: Coord?
  var signalToLayer: Int?
  var killed: [Individual]
  let responseCurve: (Double) -> Double
  var movePotential: CGPoint = .zero

  /// Range 0.0..1.0. Used for most actions other than those
  /// that directly modify the responsiveness
  var adjustedResponsiveness: Double {
    responseCurve(individual.responsiveness)
  }
}
