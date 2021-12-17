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
  case LOC_X             // I distance from left edge
  case LOC_Y             // I distance from bottom
  case BOUNDARY_DIST_X   // I X distance to nearest edge of world
  case BOUNDARY_DIST     // I distance to nearest edge of world
  case BOUNDARY_DIST_Y   // I Y distance to nearest edge of world
  case GENETIC_SIM_FWD   // I genetic similarity forward
  case LAST_MOVE_DIR_X   // I +- amount of X movement in last movement
  case LAST_MOVE_DIR_Y   // I +- amount of Y movement in last movement
  case LONGPROBE_POP_FWD // W long look for population forward
  case LONGPROBE_BAR_FWD // W long look for barriers forward
  case POPULATION        // W population density in neighborhood
  case POPULATION_FWD    // W population density in the forward-reverse axis
  case POPULATION_LR     // W population density in the left-right axis
  case OSC1              // I oscillator +-value
  case AGE               // I
  case BARRIER_FWD       // W neighborhood barrier distance forward-reverse axis
  case BARRIER_LR        // W neighborhood barrier distance left-right axis
  case RANDOM            //   random sensor value, uniform distribution
  case SIGNAL0           // W strength of signal0 in neighborhood
  case SIGNAL0_FWD       // W strength of signal0 in the forward-reverse axis
  case SIGNAL0_LR        // W strength of signal0 in the left-right axis

  var name: String {
    switch self {
    case .LOC_X: return "loc X"
    case .LOC_Y: return "loc Y"
    case .BOUNDARY_DIST_X: return "boundary dist X"
    case .BOUNDARY_DIST: return "boundary dist"
    case .BOUNDARY_DIST_Y: return "boundary dist Y"
    case .GENETIC_SIM_FWD: return "genetic similarity fwd"
    case .LAST_MOVE_DIR_X: return "last move dir X"
    case .LAST_MOVE_DIR_Y: return "last move dir Y"
    case .LONGPROBE_POP_FWD: return "long probe population fwd"
    case .LONGPROBE_BAR_FWD: return "long probe barrier fwd"
    case .POPULATION: return "population"
    case .POPULATION_FWD: return "population fwd"
    case .POPULATION_LR: return "population LR"
    case .OSC1: return "osc1"
    case .AGE: return "age"
    case .BARRIER_FWD: return "short probe barrier fwd-rev"
    case .BARRIER_LR: return "show probe barrier left-right"
    case .RANDOM: return "random"
    case .SIGNAL0: return "signal 0"
    case .SIGNAL0_FWD: return "signal 0 fwd"
    case .SIGNAL0_LR: return "signal 0 LR"
    }
  }

  // TODO: Support arbitrary disabling - because of neuron renumbering, that might cause issues
  static let enabled: [Sensor] = [.LOC_X,
                                  .LOC_Y,
                                  .BOUNDARY_DIST_X,
                                  .BOUNDARY_DIST,
                                  .BOUNDARY_DIST_Y,
                                  .GENETIC_SIM_FWD,
                                  .LAST_MOVE_DIR_X,
                                  .LAST_MOVE_DIR_Y,
                                  .LONGPROBE_POP_FWD,
                                  .LONGPROBE_BAR_FWD,
                                  .POPULATION,
                                  .POPULATION_FWD,
                                  .POPULATION_LR,
                                  .OSC1,
                                  .AGE,
                                  .BARRIER_FWD,
                                  .BARRIER_LR,
                                  .RANDOM,
                                  .SIGNAL0,
                                  .SIGNAL0_FWD,
                                  .SIGNAL0_LR]
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
                                  .MOVE_REVERSE]
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
