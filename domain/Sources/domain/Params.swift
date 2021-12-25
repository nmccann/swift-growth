import Foundation

public struct Params {
  public let population: Int // >= 0
  public let stepsPerGeneration: Int // > 0
  public let maxGenerations: Int // >= 0
  public let numThreads: Int // > 0
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
  public let responsiveness: Double // >= 0.0
  public let responsivenessCurveKFactor: Int // 1, 2, 3, or 4
  public let longProbeDistance: Int // > 0
  public let shortProbeBarrierDistance: Int // > 0
  public let valenceSaturationMag: Double
  public let saveVideo: Bool
  public let videoStride: Int // > 0
  public let videoSaveFirstFrames: Int // >= 0, overrides videoStride
  public let displayScale: Int
  public let agentSize: Int
  public let genomeAnalysisStride: Int // > 0
  public let displaySampleGenomes: Int // >= 0
  public let genomeComparisonMethod: GenomeComparison
  public let updateGraphLog: Bool
  public let updateGraphLogStride: Int // > 0
  public let challenge: Challenge?
  public let barrierType: BarrierType?
  public let replaceBarrier: (type: BarrierType, generation: Int)?

  // These must not change after initialization
  public var sizeX: Int // 2..0x10000
  public var sizeY: Int // 2..0x10000
  public let genomeInitialLengthMin: Int // > 0 and < genomeInitialLengthMax
  public let genomeInitialLengthMax: Int // > 0 and > genomeInitialLengthMin
  public let logDir: String
  public let imageDir: String
  public let graphLogUpdateCommand: String
  
  public static let defaults = Params(population: 200,
                                      stepsPerGeneration: 100,
                                      maxGenerations: 100,
                                      numThreads: 1,
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
                                      responsiveness: 0.5,
                                      responsivenessCurveKFactor: 2,
                                      longProbeDistance: 16,
                                      shortProbeBarrierDistance: 3,
                                      valenceSaturationMag: 0.5,
                                      saveVideo: true,
                                      videoStride: 1,
                                      videoSaveFirstFrames: 0,
                                      displayScale: 1,
                                      agentSize: 2,
                                      genomeAnalysisStride: 1,
                                      displaySampleGenomes: 0,
                                      genomeComparisonMethod: .hammingBits,
                                      updateGraphLog: false,
                                      updateGraphLogStride: 16,
                                      challenge: .corner(scoring: .weighted),
                                      barrierType: nil,
                                      replaceBarrier: nil,
                                      sizeX: 120,
                                      sizeY: 120,
                                      genomeInitialLengthMin: 16,
                                      genomeInitialLengthMax: 16,
                                      logDir: "./logs/",
                                      imageDir: "./images/",
                                      graphLogUpdateCommand: "/usr/bin/gnuplot --persist ./tools/graphlog.gp")
}
