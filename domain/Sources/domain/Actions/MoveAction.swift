import Foundation

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

// moveX,moveY will be the accumulators that will hold the sum of all the
// urges to move along each axis. (+- floating values of arbitrary range)
struct MoveAction: Action {
  let direction: (ActionResult) -> Direction

  init(direction: @escaping (ActionResult) -> Direction) {
    self.direction = direction
  }

  init(direction: Direction) {
    self.direction = { _ in direction }
  }

  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Parameters) {
    let offset = direction(result).asNormalizedCoord()
    result.movePotential = .init(x: result.movePotential.x + (Double(offset.x) * level),
                                 y: result.movePotential.y + (Double(offset.y) * level))
  }
}
