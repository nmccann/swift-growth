import Foundation

public struct Parameters {
  public var population: Int // >= 0
  public var stepsPerGeneration: Int // > 0
  public var maxGenerations: Int // >= 0
  public var signalLayers: Int // >= 0
  public var genomeMaxLength: Int // > 0
  public var maxNumberNeurons: Int // > 0
  public var pointMutationRate: Double // 0.0..1.0
  public var geneInsertionDeletionRate: Double // 0.0..1.0
  public var deletionRatio: Double // 0.0..1.0
  public var sexualReproduction: Bool
  public var chooseParentsByFitness: Bool
  public var populationSensorRadius: Double // > 0.0
  public var signalSensorRadius: Int // > 0

  /// Value >= 0.0, kFactor of 1, 2, 3, or 4 - used to derive the response cuve
  public var responsiveness: (value: Double, kFactor: Int) // >= 0.0

  /// Initial responsiveness of all individuals
  public var initialResponsiveness: Double

  public var probeDistance: (short: Int, long: Int) // > 0
  public var genomeComparisonMethod: GenomeComparison
  public var challenge: Challenge?
  public var generatedBarrier: GeneratedBarrier?
  public var shouldPersistManualBarriers: Bool
  public var replaceBarrier: (type: GeneratedBarrier, generation: Int)?

  // These must not change after initialization

  public var size: Size

  /// Minimum > 0
  public var genomeInitialLength: ClosedRange<Int> // > 0 and < genomeMaxLength

  public var sensors: [Sensor]

  /// Actions that are available for neurons to use as outputs.
  /// Applied in order from first to last.
  public var actions: [Action]
  
  public static let defaults = Parameters(population: 200,
                                          stepsPerGeneration: 100,
                                          maxGenerations: 100,
                                          signalLayers: 1,
                                          genomeMaxLength: 20,
                                          maxNumberNeurons: 20 / 2,
                                          pointMutationRate: 0.0001,
                                          geneInsertionDeletionRate: 0.0001,
                                          deletionRatio: 0.7,
                                          sexualReproduction: true,
                                          chooseParentsByFitness: true,
                                          populationSensorRadius: 2.0,
                                          signalSensorRadius: 1,
                                          responsiveness: (value: 0.5, kFactor: 2),
                                          initialResponsiveness: 0.5,
                                          probeDistance: (short: 3, long: 16),
                                          genomeComparisonMethod: .jaroWinkler,
                                          challenge: .rightQuarter(),
                                          generatedBarrier: .verticalBarRandom,
                                          shouldPersistManualBarriers: true,
                                          replaceBarrier: nil,
                                          size: .init(width: 120, height: 120),
                                          genomeInitialLength: 16...16,
                                          sensors: [AgeSensor(),
                                                    BoundaryDistanceSensor(axis: .both),
                                                    BoundaryDistanceSensor(axis: .x),
                                                    BoundaryDistanceSensor(axis: .y),
                                                    LastMoveDirectionSensor(axis: .x),
                                                    LastMoveDirectionSensor(axis: .y),
                                                    LocationSensor(axis: .x),
                                                    LocationSensor(axis: .y),
                                                    OscillatorSensor(),
                                                    LongProbePopulationForwardSensor(),
                                                    LongProbeBarrierForwardSensor(),
                                                    PopulationSensor(kind: .forward),
                                                    PopulationSensor(kind: .leftRight),
                                                    BarrierSensor { $0.lastDirection },
                                                    BarrierSensor { $0.lastDirection.rotate90DegreesClockwise() },
                                                    RandomSensor(),
                                                    SignalSensor(kind: .neighborhood, layer: 0),
                                                    SignalSensor(kind: .forward, layer: 0),
                                                    SignalSensor(kind: .leftRight, layer: 0),
                                                    GeneticSimilaritySensor()],
                                          actions: [MoveAxisAction(\.x),
                                                    MoveAxisAction(\.y),
                                                    MoveAction { $0.individual.lastDirection },
                                                    MoveAction { $0.individual.lastDirection.rotate90DegreesClockwise() },
                                                    MoveAction { _ in .random() },
                                                    OscillatorPeriodAction(),
                                                    LongProbeDistanceAction(max: 32),
                                                    ResponsivenessAction(),
                                                    EmitSignalAction(layer: 0),
                                                    MoveAction(direction: .east),
                                                    MoveAction(direction: .west),
                                                    MoveAction(direction: .north),
                                                    MoveAction(direction: .south),
                                                    MoveAction { $0.individual.lastDirection.rotate90DegreesCounterClockwise() },
                                                    MoveAction { $0.individual.lastDirection.rotate90DegreesClockwise() },
                                                    MoveAction { $0.individual.lastDirection.rotate180Degrees() },
                                                    KillAction()])
}
