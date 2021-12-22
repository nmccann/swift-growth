import Foundation

let SENSOR_MIN: Double = 0.0
let SENSOR_MAX: Double = 1.0
let SENSOR_RANGE = SENSOR_MAX - SENSOR_MIN

let NEURON_MIN: Double = -1.0
let NEURON_MAX: Double = 1.0
let NEURON_RANGE: Double = NEURON_MAX - NEURON_MIN

let ACTION_MIN: Double = 0.0
let ACTION_MAX: Double = 1.0
let ACTION_RANGE = ACTION_MAX - ACTION_MIN

// Place the sensor neuron you want enabled prior to NUM_SENSES. Any
// that are after NUM_SENSES will be disabled in the simulator.
// If new items are added to this enum, also update the name functions
// in analysis.cpp.
// I means data about the individual, mainly stored in Indiv
// W means data about the environment, mainly stored in Peeps or Grid
enum Sensor: Int, CaseIterable {
  case locationX,             // I distance from left edge
       locationY,             // I distance from bottom
       boundaryDistanceX,   // I X distance to nearest edge of world
       boundaryDistance,     // I distance to nearest edge of world
       boundaryDistanceY,   // I Y distance to nearest edge of world
       geneticSimilarityForward,   // I genetic similarity forward
       lastMoveDirectionX,   // I +- amount of X movement in last movement
       lastMoveDirectionY,   // I +- amount of Y movement in last movement
       longProbePopulationForward, // W long look for population forward
       longProbeBarrierForward, // W long look for barriers forward
       population,        // W population density in neighborhood
       populationForward,    // W population density in the forward-reverse axis
       populationLeftRight,     // W population density in the left-right axis
       oscillator1,              // I oscillator +-value
       age,               // I
       barrierForward,       // W neighborhood barrier distance forward-reverse axis
       barrierLeftRight,        // W neighborhood barrier distance left-right axis
       random,            //   random sensor value, uniform distribution
       signal0,           // W strength of signal0 in neighborhood
       signal0Forward,       // W strength of signal0 in the forward-reverse axis
       signal0LeftRight        // W strength of signal0 in the left-right axis
  
  var name: String {
    switch self {
    case .locationX: return "loc X"
    case .locationY: return "loc Y"
    case .boundaryDistanceX: return "boundary dist X"
    case .boundaryDistance: return "boundary dist"
    case .boundaryDistanceY: return "boundary dist Y"
    case .geneticSimilarityForward: return "genetic similarity fwd"
    case .lastMoveDirectionX: return "last move dir X"
    case .lastMoveDirectionY: return "last move dir Y"
    case .longProbePopulationForward: return "long probe population fwd"
    case .longProbeBarrierForward: return "long probe barrier fwd"
    case .population: return "population"
    case .populationForward: return "population fwd"
    case .populationLeftRight: return "population LR"
    case .oscillator1: return "osc1"
    case .age: return "age"
    case .barrierForward: return "short probe barrier fwd-rev"
    case .barrierLeftRight: return "show probe barrier left-right"
    case .random: return "random"
    case .signal0: return "signal 0"
    case .signal0Forward: return "signal 0 fwd"
    case .signal0LeftRight: return "signal 0 LR"
    }
  }
  
  // TODO: Support arbitrary disabling - because of neuron renumbering, that might cause issues
  static let enabled: [Sensor] = [.locationX,
                                  .locationY,
                                  .boundaryDistanceX,
                                  .boundaryDistance,
                                  .boundaryDistanceY,
                                  .geneticSimilarityForward,
                                  .lastMoveDirectionX,
                                  .lastMoveDirectionY,
                                  .longProbePopulationForward,
                                  .longProbeBarrierForward,
                                  .population,
                                  .populationForward,
                                  .populationLeftRight,
                                  .oscillator1,
                                  .age,
                                  .barrierForward,
                                  .barrierLeftRight,
                                  .random,
                                  .signal0,
                                  .signal0Forward,
                                  .signal0LeftRight]
}

// Place the action neuron you want enabled prior to NUM_ACTIONS. Any
// that are after NUM_ACTIONS will be disabled in the simulator.
// If new items are added to this enum, also update the name functions
// in analysis.cpp.
// I means the action affects the individual internally (Indiv)
// W means the action also affects the environment (Peeps or Grid)
enum Action: Int, CaseIterable {
  case MOVE_X                   // W +- X component of movement
  case MOVE_Y                   // W +- Y component of movement
  case MOVE_FORWARD             // W continue last direction
  case MOVE_RL                  // W +- component of movement
  case MOVE_RANDOM              // W
  case SET_OSCILLATOR_PERIOD    // I
  case SET_LONGPROBE_DIST       // I
  case SET_RESPONSIVENESS       // I
  case EMIT_SIGNAL0             // W
  case MOVE_EAST                // W
  case MOVE_WEST                // W
  case MOVE_NORTH               // W
  case MOVE_SOUTH               // W
  case MOVE_LEFT                // W
  case MOVE_RIGHT               // W
  case MOVE_REVERSE             // W
  case KILL_FORWARD             // W
  
  var name: String {
    switch self {
    case .MOVE_X: return "move X"
    case .MOVE_Y: return "move Y"
    case .MOVE_FORWARD: return "move fwd"
    case .MOVE_RL: return "move R-L"
    case .MOVE_RANDOM: return "move random"
    case .SET_OSCILLATOR_PERIOD: return "set osc1"
    case .SET_LONGPROBE_DIST: return "set longprobe dist"
    case .SET_RESPONSIVENESS: return "set inv-responsiveness"
    case .EMIT_SIGNAL0: return "emit signal 0"
    case .MOVE_EAST: return "move east"
    case .MOVE_WEST: return "move west"
    case .MOVE_NORTH: return "move north"
    case .MOVE_SOUTH: return "move south"
    case .MOVE_LEFT: return "move left"
    case .MOVE_RIGHT: return "move right"
    case .MOVE_REVERSE: return "move reverse"
    case .KILL_FORWARD: return "kill fwd"
    }
  }
  
  // TODO: Support arbitrary disabling - because of neuron renumbering, that might cause issues
  static let enabled: [Action] = [.MOVE_X,
                                  .MOVE_Y,
                                  .MOVE_FORWARD,
                                  .MOVE_RL,
                                  .MOVE_RANDOM,
                                  .SET_OSCILLATOR_PERIOD,
                                  .SET_LONGPROBE_DIST,
                                  .SET_RESPONSIVENESS,
                                  .EMIT_SIGNAL0,
                                  .MOVE_EAST,
                                  .MOVE_WEST,
                                  .MOVE_NORTH,
                                  .MOVE_SOUTH,
                                  .MOVE_LEFT,
                                  .MOVE_RIGHT,
                                  .MOVE_REVERSE,
                                  .KILL_FORWARD]
}

func printSensorsActions() {
  print("""
Capabilities:
--Sensors--
  \(Sensor.enabled.map(\.name).joined(separator: "\n\t"))
--Actions--
  \(Action.enabled.map(\.name).joined(separator: "\n\t"))
""")
}
