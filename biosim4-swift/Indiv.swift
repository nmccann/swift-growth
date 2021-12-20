import Foundation

struct Indiv {
  var alive: Bool
  let index: Int // index into peeps[] container
  var loc: Coord // refers to a location in grid[][]
  let birthLoc: Coord
  var age: Int
  let genome: Genome
  var nnet: NeuralNet // derived from .genome
  var responsiveness: Double // 0.0..1.0 (0 is like asleep)
  var oscPeriod: Int // 2..4*p.stepsPerGeneration (TBD, see executeActions())
  var longProbeDist: Int // distance for long forward probe for obstructions
  var lastMoveDir: Dir // direction of last movement
  let challengeBits: Int // modified when the indiv accomplishes some task
  
  /// Returned sensor values range SENSOR_MIN..SENSOR_MAX
  func getSensor(_ sensor: Sensor, simStep: Int) -> Double {
    var sensorVal = 0.0
    
    switch sensor {
    case .age:
      // Converts age (units of simSteps compared to life expectancy)
      // linearly to normalized sensor range 0.0..1.0
      sensorVal = Double(age) / Double(p.stepsPerGeneration)
    case .boundaryDistance:
      // Finds closest boundary, compares that to the max possible dist
      // to a boundary from the center, and converts that linearly to the
      // sensor range 0.0..1.0
      let distanceX = min(loc.x, (p.sizeX - loc.x) - 1)
      let distanceY = min(loc.y, (p.sizeY - loc.y) - 1)
      let closest = min(distanceX, distanceY)
      let maxPossible = max(p.sizeX / 2 - 1, p.sizeY / 2 - 1)
      sensorVal = Double(closest) / Double(maxPossible)
    case .boundaryDistanceX:
      // Measures the distance to nearest boundary in the east-west axis,
      // max distance is half the grid width; scaled to sensor range 0.0..1.0.
      let minDistanceX = min(loc.x, (p.sizeX - loc.x) - 1)
      sensorVal = Double(minDistanceX) / (Double(p.sizeX) / 2.0)
    case .boundaryDistanceY:
      // Measures the distance to nearest boundary in the south-north axis,
      // max distance is half the grid height; scaled to sensor range 0.0..1.0.
      let minDistanceY = min(loc.y, (p.sizeY - loc.y) - 1)
      sensorVal = Double(minDistanceY) / (Double(p.sizeY) / 2.0)
    case .lastMoveDirectionX:
      // X component -1,0,1 maps to sensor values 0.0, 0.5, 1.0
      let lastX = lastMoveDir.asNormalizedCoord().x
      sensorVal = lastX == 0 ? 0.5 : (lastX == -1 ? 0.0 : 1.0)
    case .lastMoveDirectionY:
      // Y component -1,0,1 maps to sensor values 0.0, 0.5, 1.0
      let lastY = lastMoveDir.asNormalizedCoord().y
      sensorVal = lastY == 0 ? 0.5 : (lastY == -1 ? 0.0 : 1.0)
    case .locationX:
      // Maps current X location 0..p.sizeX-1 to sensor range 0.0..1.0
      sensorVal = Double(loc.x) / Double(p.sizeX - 1)
    case .locationY:
      // Maps current Y location 0..p.sizeY-1 to sensor range 0.0..1.0
      sensorVal = Double(loc.y) / Double(p.sizeY - 1)
    case .oscillator1:
      // Maps the oscillator sine wave to sensor range 0.0..1.0;
      // cycles starts at simStep 0 for everbody.
      let phase = Double(simStep % oscPeriod) / Double(oscPeriod) // 0.0..1.0
      var factor = -cos(phase * 2.0 * Double.pi)
      assert(factor >= -1.0 && factor <= 1.0)
      factor += 1.0 // convert to 0.0..2.0
      factor /= 2.0 // convert to 0.0..1.0
      // Clip any round-off error
      sensorVal = factor;
      sensorVal = min(1.0, max(0.0, sensorVal))
    case .longProbePopulationForward:
      // Measures the distance to the nearest other individual in the
      // forward direction. If non found, returns the maximum sensor value.
      // Maps the result to the sensor range 0.0..1.0.
      sensorVal = Double(longProbePopulationForward(loc: loc,
                                                    dir: lastMoveDir,
                                                    distance: longProbeDist)) / Double(longProbeDist)
    case .longProbeBarrierForward:
      // Measures the distance to the nearest barrier in the forward
      // direction. If non found, returns the maximum sensor value.
      // Maps the result to the sensor range 0.0..1.0.
      sensorVal = Double(longProbeBarrierForward(loc: loc,
                                                 dir: lastMoveDir,
                                                 distance: longProbeDist)) / Double(longProbeDist)
    case .population:
      // Returns population density in neighborhood converted linearly from
      // 0..100% to sensor range
      //TODO: Verify that this counts population correctly
      var countLocs = 0
      var countOccupied = 0
      func checkOccupancy(tloc: Coord) {
        countLocs += 1
        if grid.isOccupiedAt(loc: tloc) {
          countOccupied += 1
        }
      }
      
      grid.visitNeighborhood(loc: loc, radius: p.populationSensorRadius, f: checkOccupancy)
      sensorVal = Double(countOccupied) / Double(countLocs)
    case .populationForward:
      // Sense population density along axis of last movement direction, mapped
      // to sensor range 0.0..1.0
      sensorVal = getPopulationDensityAlongAxis(loc: loc, dir: lastMoveDir)
    case .populationLeftRight:
      // Sense population density along an axis 90 degrees from last movement direction
      sensorVal = getPopulationDensityAlongAxis(loc: loc, dir: lastMoveDir.rotate90DegCW())
    case .barrierForward:
      // Sense the nearest barrier along axis of last movement direction, mapped
      // to sensor range 0.0..1.0
      sensorVal = getShortProbeBarrierDistance(loc: loc,
                                               dir: lastMoveDir,
                                               distance: p.shortProbeBarrierDistance)
    case .barrierLeftRight:
      // Sense the nearest barrier along axis perpendicular to last movement direction, mapped
      // to sensor range 0.0..1.0
      sensorVal = getShortProbeBarrierDistance(loc: loc,
                                               dir: lastMoveDir.rotate90DegCW(),
                                               distance: p.shortProbeBarrierDistance)
    case .random:
      // Returns a random sensor value in the range 0.0..1.0.
      sensorVal = Double.random(in: 0...1)
    case .signal0:
      // Returns magnitude of signal0 in the local neighborhood, with
      // 0.0..maxSignalSum converted to sensorRange 0.0..1.0
      sensorVal = getSignalDensity(loc: loc, layer: 0)
    case .signal0Forward:
      // Sense signal0 density along axis of last movement direction
      sensorVal = getSignalDensityAlongAxis(loc: loc, dir: lastMoveDir, layer: 0)
    case .signal0LeftRight:
      // Sense signal0 density along an axis perpendicular to last movement direction
      sensorVal = getSignalDensityAlongAxis(loc: loc, dir: lastMoveDir.rotate90DegCW(), layer: 0)
    default:
      //TODO: Implement remaining sensors
      sensorVal = .random(in: SENSOR_MIN...SENSOR_MAX)
    }
    
    if sensorVal.isNaN || sensorVal < -0.01 || sensorVal > 1.01 {
      print("Clipping sensorVal of \(sensorVal) for \(sensor.name)")
      sensorVal = max(0.0, min(sensorVal, 1.0))
    }
    
    assert(!sensorVal.isNaN && sensorVal >= -0.01 && sensorVal <= 1.01)
    
    return sensorVal
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

