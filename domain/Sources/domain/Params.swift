import Foundation

public struct Params {
  public let population: Int // >= 0
  public let stepsPerGeneration: Int // > 0
  public let maxGenerations: Int // >= 0
  public let signalLayers: Int // >= 0
  public let genomeMaxLength: Int // > 0
  public let maxNumberNeurons: Int // > 0
  public let pointMutationRate: Double // 0.0..1.0
  public let geneInsertionDeletionRate: Double // 0.0..1.0
  public let deletionRatio: Double // 0.0..1.0
  public let killEnable: Bool
  public let sexualReproduction: Bool
  public let chooseParentsByFitness: Bool
  public let populationSensorRadius: Double // > 0.0
  public let signalSensorRadius: Int // > 0

  /// Value >= 0.0, kFactor of 1, 2, 3, or 4
  public let responsiveness: (value: Double, kFactor: Int) // >= 0.0

  public let probeDistance: (short: Int, long: Int) // > 0
  public let genomeComparisonMethod: GenomeComparison
  public let challenge: Challenge?
  public let barrierType: BarrierType?
  public let replaceBarrier: (type: BarrierType, generation: Int)?

  // These must not change after initialization

  public var size: (x: Int, y: Int)

  /// Minimum > 0
  public let genomeInitialLength: ClosedRange<Int> // > 0 and < genomeInitialLengthMax

  /// Actions that are available for neurons to use as outputs.
  /// Applied in order from first to last.
  public let actions: [Action]
  
  public static let defaults = Params(population: 200,
                                      stepsPerGeneration: 100,
                                      maxGenerations: 100,
                                      signalLayers: 1,
                                      genomeMaxLength: 20,
                                      maxNumberNeurons: 20 / 2,
                                      pointMutationRate: 0.0001,
                                      geneInsertionDeletionRate: 0, //Originally 0.0001, but currently can't support unequal length genes
                                      deletionRatio: 0.7,
                                      killEnable: false,
                                      sexualReproduction: true,
                                      chooseParentsByFitness: true,
                                      populationSensorRadius: 2.0,
                                      signalSensorRadius: 1,
                                      responsiveness: (value: 0.5, kFactor: 2),
                                      probeDistance: (short: 3, long: 16),
                                      genomeComparisonMethod: .hammingBits,
                                      challenge: .rightQuarter(),
                                      barrierType: nil,
                                      replaceBarrier: nil,
                                      size: (x: 120, y: 120),
                                      genomeInitialLength: 16...16,
                                      actions: [MoveXAction(),
                                                MoveYAction(),
                                                MoveAction { $0.indiv.lastDirection },
                                                MoveAction { $0.indiv.lastDirection.rotate90DegreesClockwise() },
                                                MoveAction { _ in .random() },
                                                OscillatorPeriodAction(),
                                                LongProbeDistanceAction(),
                                                ResponsivenessAction(),
                                                EmitSignalAction(layer: 0),
                                                MoveAction { _ in .east},
                                                MoveAction { _ in .west },
                                                MoveAction { _ in .north },
                                                MoveAction { _ in .south },
                                                MoveAction { $0.indiv.lastDirection.rotate90DegreesCounterClockwise() },
                                                MoveAction { $0.indiv.lastDirection.rotate90DegreesClockwise() },
                                                MoveAction { $0.indiv.lastDirection.rotate180Degrees() },
                                                KillAction()])
}
