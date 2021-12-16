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
func responseCurve(_ r: Double) -> Double {
  let k = Double(p.responsivenessCurveKFactor)
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
 SET_RESPONSIVENESS action - immediately change indiv.responsiveness to the action
 level scaled to 0.0..1.0 (because we have exclusive access to this member in
 our own individual during this function)
 SET_OSCILLATOR_PERIOD action - immediately change our individual's indiv.oscPeriod
 to the action level exponentially scaled to 2..2048 (TBD)
 EMIT_SIGNALn action(s) - immediately increment the signal level at our agent's
 location using signals.increment() (using a thread-safe call)
 KILL_FORWARD action - queue the other agent for deferred death with
 peeps.queueForDeath()

 The deferred movement and death queues will be emptied by the caller at the end of the
 simulator step by endOfSimStep() in a single thread after all individuals have been
 evaluated multithreadedly.
 **********************************************************************************/
func executeActions(indiv: inout Indiv, levels: [Action: Double]) {
  // Responsiveness action - convert neuron action level from arbitrary float range
  // to the range 0.0..1.0. If this action neuron is enabled but not driven, will
  // default to mid-level 0.5.
  if var level = levels[.SET_RESPONSIVENESS] {
    level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
    indiv.responsiveness = level
  }

  // For the rest of the action outputs, we'll apply an adjusted responsiveness
  // factor (see responseCurve() for more info). Range 0.0..1.0.
  let responsivenessAdjusted = responseCurve(indiv.responsiveness)

  // Oscillator period action - convert action level nonlinearly to
  // 2..4*p.stepsPerGeneration. If this action neuron is enabled but not driven,
  // will default to 1.5 + e^(3.5) = a period of 34 simSteps.
  if let periodf = levels[.SET_OSCILLATOR_PERIOD] {
    let newPeriodf01 = (tanh(periodf) + 1.0) / 2.0 // convert to 0.0..1.0
    let newPeriod = 1 + Int(1.5 + exp(7.0 * newPeriodf01))
    assert(newPeriod >= 2 && newPeriod <= 2048)
    indiv.oscPeriod = newPeriod
  }

  // Set longProbeDistance - convert action level to 1..maxLongProbeDistance.
  // If this action neuron is enabled but not driven, will default to
  // mid-level period of 17 simSteps.
  if var level = levels[.SET_LONGPROBE_DIST] {
    let maxLongProbeDistance = 32
    level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
    level = 1 + level * Double(maxLongProbeDistance)
    indiv.longProbeDist = Int(UInt(level))
  }

  // Emit signal0 - if this action value is below a threshold, nothing emitted.
  // Otherwise convert the action value to a probability of emitting one unit of
  // signal (pheromone).
  // Pheromones may be emitted immediately (see signals.cpp). If this action neuron
  // is enabled but not driven, nothing will be emitted.
  if var level = levels[.EMIT_SIGNAL0] {
    let emitThreshold = 0.5  // 0.0..1.0; 0.5 is midlevel
    level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
    level *= responsivenessAdjusted

    if level > emitThreshold && prob2bool(level) {
      //TODO: Enable after porting signals
//      signals.increment(0, indiv.loc);
    }
  }

  // Kill forward -- if this action value is > threshold, value is converted to probability
  // of an attempted murder. Probabilities under the threshold are considered 0.0.
  // If this action neuron is enabled but not driven, the neighbors are safe.
  if var level = levels[.KILL_FORWARD], p.killEnable {
    let killThreshold = 0.5  // 0.0..1.0; 0.5 is midlevel
    level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
    level *= responsivenessAdjusted

    if level > killThreshold && prob2bool((level - ACTION_MIN) / ACTION_RANGE) {
      let otherLoc = indiv.loc + indiv.lastMoveDir;

      if grid.isInBounds(loc: otherLoc) && grid.isOccupiedAt(loc: otherLoc) {
        var indiv2 = peeps.getIndiv(loc: otherLoc)
        if indiv2.alive {
          let distance = (indiv.loc - indiv2.loc).length
          assert(distance == 1);
          peeps.queueForDeath(indiv2)
        }
      }
    }
  }

  // ------------- Movement action neurons ---------------

  // There are multiple action neurons for movement. Each type of movement neuron
  // urges the individual to move in some specific direction. We sum up all the
  // X and Y components of all the movement urges, then pass the X and Y sums through
  // a transfer function (tanh()) to get a range -1.0..1.0. The absolute values of the
  // X and Y values are passed through prob2bool() to convert to -1, 0, or 1, then
  // multiplied by the component's signum. This results in the x and y components of
  // a normalized movement offset. I.e., the probability of movement in either
  // dimension is the absolute value of tanh of the action level X,Y components and
  // the direction is the sign of the X, Y components. For example, for a particular
  // action neuron:
  //     X, Y == -5.9, +0.3 as raw action levels received here
  //     X, Y == -0.999, +0.29 after passing raw values through tanh()
  //     Xprob, Yprob == 99.9%, 29% probability of X and Y becoming 1 (or -1)
  //     X, Y == -1, 0 after applying the sign and probability
  //     The agent will then be moved West (an offset of -1, 0) if it's a legal move.

  var level: Double
  var offset: Coord
  let lastMoveOffset = indiv.lastMoveDir.asNormalizedCoord()

  // moveX,moveY will be the accumulators that will hold the sum of all the
  // urges to move along each axis. (+- floating values of arbitrary range)
  var moveX = levels[.MOVE_X] ?? 0.0
  var moveY = levels[.MOVE_Y] ?? 0.0

  moveX += levels[.MOVE_EAST] ?? 0
  moveX -= levels[.MOVE_WEST] ?? 0
  moveY += levels[.MOVE_NORTH] ?? 0
  moveY -= levels[.MOVE_SOUTH] ?? 0

  if let level = levels[.MOVE_FORWARD] {
    moveX += Double(lastMoveOffset.x) * level
    moveY += Double(lastMoveOffset.y) * level
  }

  if let level = levels[.MOVE_REVERSE] {
    moveX -= Double(lastMoveOffset.x) * level
    moveY -= Double(lastMoveOffset.y) * level
  }

  if let level = levels[.MOVE_LEFT] {
    offset = indiv.lastMoveDir.rotate90DegCCW().asNormalizedCoord()
    moveX += Double(offset.x) * level
    moveY += Double(offset.y) * level
  }

  if let level = levels[.MOVE_RIGHT] {
    offset = indiv.lastMoveDir.rotate90DegCW().asNormalizedCoord()
    moveX += Double(offset.x) * level
    moveY += Double(offset.y) * level
  }

  if let level = levels[.MOVE_RL] {
    offset = indiv.lastMoveDir.rotate90DegCW().asNormalizedCoord()
    moveX += Double(offset.x) * level
    moveY += Double(offset.y) * level
  }

  if let level = levels[.MOVE_RANDOM] {
    offset = Dir.random8().asNormalizedCoord()
    moveX += Double(offset.x) * level
    moveY += Double(offset.y) * level
  }

  // Convert the accumulated X, Y sums to the range -1.0..1.0 and scale by the
  // individual's responsiveness (0.0..1.0) (adjusted by a curve)
  moveX = tanh(moveX);
  moveY = tanh(moveY);
  moveX *= responsivenessAdjusted;
  moveY *= responsivenessAdjusted;

  // The probability of movement along each axis is the absolute value
  let probX = prob2bool(abs(moveX)) ? 1 : 0 // convert abs(level) to 0 or 1
  let probY = prob2bool(abs(moveY)) ? 1 : 0 // convert abs(level) to 0 or 1

  // The direction of movement (if any) along each axis is the sign
  let signumX = moveX < 0.0 ? -1 : 1
  let signumY = moveY < 0.0 ? -1 : 1

  // Generate a normalized movement offset, where each component is -1, 0, or 1
  let movementOffset = Coord(x: Int(probX * signumX), y: Int(probY * signumY))

  // Move there if it's a valid location
  let newLoc = indiv.loc + movementOffset

  if grid.isInBounds(loc: newLoc) && grid.isEmptyAt(loc: newLoc) {
    peeps.queueForMove(indiv, newLoc: newLoc)
  }
}
