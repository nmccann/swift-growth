import Foundation

struct Indiv {
  var alive: Bool
  let index: Int // index into peeps[] container
  var loc: Coord // refers to a location in grid[][]
  let birthLoc: Coord
  let age: Int
  let genome: Genome
  let nnet: NeuralNet // derived from .genome
  var responsiveness: Double // 0.0..1.0 (0 is like asleep)
  var oscPeriod: Int // 2..4*p.stepsPerGeneration (TBD, see executeActions())
  var longProbeDist: Int // distance for long forward probe for obstructions
  var lastMoveDir: Dir // direction of last movement
  let challengeBits: Int // modified when the indiv accomplishes some task


  /// reads sensors, returns actions
  func feedForward(simStep: Int) -> [Double] {
    fatalError()
  }


  /// Returned sensor values range SENSOR_MIN..SENSOR_MAX
  func getSensor(_ sensor: Sensor, simStep: Int) -> Double {
    fatalError()
  }

  init(index: Int, loc: Coord, genome: inout Genome) {
    fatalError()
  }

  /// creates .nnet member from .genome member
  func createWiringFromGenome() {
    fatalError()
  }

  func printNeuralNet() {
    fatalError()
  }

  func printIGraphEdgeList() {
    fatalError()
  }

  func printGenome() {
    fatalError()
  }
}
