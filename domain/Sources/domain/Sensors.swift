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

func printSensorsActions() {
  //TODO: Introduce action printing again
  print("""
Capabilities:
--Sensors--
  \(Sensor.enabled.map(\.name).joined(separator: "\n\t"))
""")
}
