import Foundation

public struct Indiv {
  public var alive: Bool
  let index: Int // index into peeps[] container
  public var loc: Coord // refers to a location in grid[][]
  let birthLoc: Coord
  var age: Int
  let genome: Genome
  var nnet: NeuralNet // derived from .genome
  var responsiveness: Double // 0.0..1.0 (0 is like asleep)
  var oscPeriod: Int // 2..4*p.stepsPerGeneration (TBD, see executeActions())

  /// Distance to check for obstructions with long forward probe
  var probeDistance: (short: Int, long: Int)

  /// Direction of last movement
  var lastDirection: Direction

  /// Modified when some task is accomplished in relation to the current challenge
  var challengeBits: Int
  
  /// Returned sensor values range SENSOR_MIN..SENSOR_MAX
  func getSensor(_ sensor: Sensor, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    var sensorVal = 0.0
    
    switch sensor {
    case .age:
      // Converts age (units of simSteps compared to life expectancy)
      // linearly to normalized sensor range 0.0..1.0
      sensorVal = Double(age) / Double(parameters.stepsPerGeneration)
    case .boundaryDistance:
      // Finds closest boundary, compares that to the max possible dist
      // to a boundary from the center, and converts that linearly to the
      // sensor range 0.0..1.0
      let distanceX = min(loc.x, (grid.size.x - loc.x) - 1)
      let distanceY = min(loc.y, (grid.size.y - loc.y) - 1)
      let closest = min(distanceX, distanceY)
      let maxPossible = max(grid.size.x / 2 - 1, grid.size.y / 2 - 1)
      sensorVal = Double(closest) / Double(maxPossible)
    case .boundaryDistanceX:
      // Measures the distance to nearest boundary in the east-west axis,
      // max distance is half the grid width; scaled to sensor range 0.0..1.0.
      let minDistanceX = min(loc.x, (grid.size.x - loc.x) - 1)
      sensorVal = Double(minDistanceX) / (Double(grid.size.x) / 2.0)
    case .boundaryDistanceY:
      // Measures the distance to nearest boundary in the south-north axis,
      // max distance is half the grid height; scaled to sensor range 0.0..1.0.
      let minDistanceY = min(loc.y, (grid.size.y - loc.y) - 1)
      sensorVal = Double(minDistanceY) / (Double(grid.size.y) / 2.0)
    case .lastMoveDirectionX:
      // X component -1,0,1 maps to sensor values 0.0, 0.5, 1.0
      let lastX = lastDirection.asNormalizedCoord().x
      sensorVal = lastX == 0 ? 0.5 : (lastX == -1 ? 0.0 : 1.0)
    case .lastMoveDirectionY:
      // Y component -1,0,1 maps to sensor values 0.0, 0.5, 1.0
      let lastY = lastDirection.asNormalizedCoord().y
      sensorVal = lastY == 0 ? 0.5 : (lastY == -1 ? 0.0 : 1.0)
    case .locationX:
      // Maps current X location 0..grid.size.x-1 to sensor range 0.0..1.0
      sensorVal = Double(loc.x) / Double(grid.size.x - 1)
    case .locationY:
      // Maps current Y location 0..grid.size.y-1 to sensor range 0.0..1.0
      sensorVal = Double(loc.y) / Double(grid.size.y - 1)
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
      let distance = probeDistance.long
      sensorVal = Double(longProbePopulationForward(loc: loc,
                                                    direction: lastDirection,
                                                    distance: distance,
                                                    on: grid)) / Double(distance)
    case .longProbeBarrierForward:
      // Measures the distance to the nearest barrier in the forward
      // direction. If non found, returns the maximum sensor value.
      // Maps the result to the sensor range 0.0..1.0.
      let distance = probeDistance.long
      sensorVal = Double(longProbeBarrierForward(loc: loc,
                                                 direction: lastDirection,
                                                 distance: distance,
                                                 on: grid)) / Double(distance)
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
      
      grid.visitNeighborhood(loc: loc, radius: parameters.populationSensorRadius, f: checkOccupancy)
      sensorVal = Double(countOccupied) / Double(countLocs)
    case .populationForward:
      // Sense population density along axis of last movement direction, mapped
      // to sensor range 0.0..1.0
      sensorVal = getPopulationDensityAlongAxis(loc: loc,
                                                direction: lastDirection,
                                                on: grid,
                                                with: parameters)
    case .populationLeftRight:
      // Sense population density along an axis 90 degrees from last movement direction
      sensorVal = getPopulationDensityAlongAxis(loc: loc,
                                                direction: lastDirection.rotate90DegreesClockwise(),
                                                on: grid,
                                                with: parameters)
    case .barrierForward:
      // Sense the nearest barrier along axis of last movement direction, mapped
      // to sensor range 0.0..1.0
      sensorVal = getShortProbeBarrierDistance(loc: loc,
                                               direction: lastDirection,
                                               distance: probeDistance.short,
                                               on: grid)
    case .barrierLeftRight:
      // Sense the nearest barrier along axis perpendicular to last movement direction, mapped
      // to sensor range 0.0..1.0
      sensorVal = getShortProbeBarrierDistance(loc: loc,
                                               direction: lastDirection.rotate90DegreesClockwise(),
                                               distance: probeDistance.short,
                                               on: grid)
    case .random:
      // Returns a random sensor value in the range 0.0..1.0.
      sensorVal = .random(in: 0...1)
    case .signal0:
      // Returns magnitude of signal0 in the local neighborhood, with
      // 0.0..maxSignalSum converted to sensorRange 0.0..1.0
      sensorVal = getSignalDensity(loc: loc, layer: 0, on: grid, with: parameters)
    case .signal0Forward:
      // Sense signal0 density along axis of last movement direction
      sensorVal = getSignalDensityAlongAxis(loc: loc, direction: lastDirection, layer: 0, on: grid, with: parameters)
    case .signal0LeftRight:
      // Sense signal0 density along an axis perpendicular to last movement direction
      sensorVal = getSignalDensityAlongAxis(loc: loc, direction: lastDirection.rotate90DegreesClockwise(), layer: 0, on: grid, with: parameters)
    case .geneticSimilarityForward:
      // Return minimum sensor value if nobody is alive in the forward adjacent location,
      // else returns a similarity match in the sensor range 0.0..1.0
      let loc2 = loc + lastDirection;
      if (grid.isInBounds(loc: loc2) && grid.isOccupiedAt(loc: loc2)) {
        let indiv2 = peeps.getIndiv(loc: loc2)
        if indiv2.alive {
          sensorVal = parameters.genomeComparisonMethod.similarity(genome, indiv2.genome) // 0.0..1.0
        }
      }
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
  init(index: Int,
       loc: Coord,
       genome: Genome,
       probeDistance: (short: Int, long: Int),
       maxNumberOfNeurons: Int,
       actionsCount: Int) {
    self.index = index
    self.loc = loc
    self.birthLoc = loc //commented out in original implementation
    self.age = 0
    self.oscPeriod = 34 //TODO: Define a constant
    self.alive = true
    self.lastDirection = .random()
    self.responsiveness = 0.5 // range 0.0..1.0
    self.probeDistance = probeDistance
    self.challengeBits = 0 // will be set true when some task gets accomplished
    self.genome = genome
    self.nnet = createWiringFromGenome(genome, maxNumberNeurons: maxNumberOfNeurons, actionsCount: actionsCount)
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

