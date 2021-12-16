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


  /// This is called when any individual is spawned.
  /// The responsiveness parameter will be initialized here to maximum value
  /// of 1.0, then depending on which action activation function is used,
  /// the default undriven value may be changed to 1.0 or action midrange.
  init(index: Int, loc: Coord, genome: Genome) {
    self.index = index
    self.loc = loc
    self.birthLoc = loc //commented out in original implementation
    grid.set(loc: loc, val: index) //TODO: Avoid mutating global state like this
    self.age = 0
    self.oscPeriod = 34 //TODO: Define a constant
    self.alive = true
    self.lastMoveDir = .random8()
    self.responsiveness = 0.5 // range 0.0..1.0
    self.longProbeDist = p.longProbeDistance //TODO: Avoid referencing global state
    self.challengeBits = 0 // will be set true when some task gets accomplished
    self.genome = genome
    self.nnet = createWiringFromGenome(genome)
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

