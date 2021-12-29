import Foundation

public struct Indiv: Equatable {
  struct ProbeDistance: Equatable {
    var short: Int
    var long: Int
  }
  public var alive: Bool
  let index: Int
  public var loc: Coord // refers to a location in grid[][]
  let birthLoc: Coord
  var age: Int
  let genome: Genome
  var nnet: NeuralNet // derived from .genome
  var responsiveness: Double // 0.0..1.0 (0 is like asleep)
  var oscPeriod: Int // 2..4*p.stepsPerGeneration (TBD, see executeActions())

  /// Distance to check for obstructions with long forward probe
  var probeDistance: ProbeDistance

  /// Direction of last movement
  var lastDirection: Direction

  /// Modified when some task is accomplished in relation to the current challenge
  var challengeBits: Int
  
  /// Returned sensor values range SENSOR_MIN...SENSOR_MAX
  func getSensor(_ sensor: Sensor, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    sensor.get(for: self, simStep: simStep, on: grid, with: parameters).clamped(to: 0.0...1.0)
  }
  
  
  /// This is called when any individual is spawned.
  /// The responsiveness parameter will be initialized here to maximum value
  /// of 1.0, then depending on which action activation function is used,
  /// the default undriven value may be changed to 1.0 or action midrange.
  init(index: Int,
       loc: Coord,
       genome: Genome,
       probeDistance: (short: Int, long: Int),
       maxNumberOfNeurons: Int,
       actions: Int,
       sensors: Int) {
    self.index = index
    self.loc = loc
    self.birthLoc = loc //commented out in original implementation
    self.age = 0
    self.oscPeriod = 34 //TODO: Define a constant
    self.alive = true
    self.lastDirection = .random()
    self.responsiveness = 0.5 // range 0.0..1.0
    self.probeDistance = .init(short: probeDistance.short, long: probeDistance.long)
    self.challengeBits = 0 // will be set true when some task gets accomplished
    self.genome = genome
    self.nnet = createWiringFromGenome(genome, maxNumberNeurons: maxNumberOfNeurons, actions: actions, sensors: sensors)
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

