import Foundation

public struct Individual: Equatable {
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

  public let color: Color
  
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
    self.color = colorFrom(genome)
  }
}

public struct Color: Equatable {
  public let red: Double
  public let green: Double
  public let blue: Double
}

private func colorFrom(_ genome: Genome) -> Color {
  guard let first = genome.first, let last = genome.last  else {
    return .init(red: 0, green: 0, blue: 0)
  }

  /// - Returns: 1 if even, 0 if odd
  func isEven(_ value: Int) -> Int {
    value.isMultiple(of: 2) ? 1 : 0
  }

  func lumaFrom(red: Int, green: Int, blue: Int) -> Int {
    ((red * 3) + blue + (green * 4)) / 8
  }

  let raw: Int = isEven(genome.count) |
  first.sourceType.rawValue << 1 |
  last.sourceType.rawValue << 2 |
  first.sinkType.rawValue << 3 |
  last.sinkType.rawValue << 4 |
  isEven(first.sourceNum) << 5 |
  isEven(first.sinkNum) << 6 |
  isEven(last.sourceNum) << 7

  let maxColorValue = 0xb0
  let maxLumaValue = 0xb0

  var red = raw
  var green = (raw & 0x1f) << 3
  var blue = (raw & 7) << 5


  if lumaFrom(red: red, green: green, blue: blue) > maxLumaValue {
    red = red > maxColorValue ? red % maxColorValue : red
    green = green > maxColorValue ? green % maxColorValue : green
    blue = blue > maxColorValue ? blue % maxColorValue : blue
  }

  return .init(red: Double(red) / 255.0, green: Double(green) / 255.0, blue: Double(blue) / 255.0)
}
