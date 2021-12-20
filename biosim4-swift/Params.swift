import Foundation

struct Params {
  let population: Int // >= 0
  let stepsPerGeneration: Int // > 0
  let maxGenerations: Int // >= 0
  let numThreads: Int // > 0
  let signalLayers: Int // >= 0
  let genomeMaxLength: Int // > 0
  let maxNumberNeurons: Int // > 0
  let pointMutationRate: Double // 0.0..1.0
  let geneInsertionDeletionRate: Double // 0.0..1.0
  let deletionRatio: Double // 0.0..1.0
  let killEnable: Bool
  let sexualReproduction: Bool
  let chooseParentsByFitness: Bool
  let populationSensorRadius: Double // > 0.0
  let signalSensorRadius: Int // > 0
  let responsiveness: Double // >= 0.0
  let responsivenessCurveKFactor: Int // 1, 2, 3, or 4
  let longProbeDistance: Int // > 0
  let shortProbeBarrierDistance: Int // > 0
  let valenceSaturationMag: Double
  let saveVideo: Bool
  let videoStride: Int // > 0
  let videoSaveFirstFrames: Int // >= 0, overrides videoStride
  let displayScale: Int
  let agentSize: Int
  let genomeAnalysisStride: Int // > 0
  let displaySampleGenomes: Int // >= 0
  let genomeComparisonMethod: Int // 0 = Jaro-Winkler; 1 = Hamming
  let updateGraphLog: Bool
  let updateGraphLogStride: Int // > 0
  let challenge: Challenge?
  let barrierType: BarrierType?
  let replaceBarrierType: BarrierType?
  let replaceBarrierTypeGenerationNumber: Int // >= 0
  
  // These must not change after initialization
  var sizeX: Int // 2..0x10000
  var sizeY: Int // 2..0x10000
  let genomeInitialLengthMin: Int // > 0 and < genomeInitialLengthMax
  let genomeInitialLengthMax: Int // > 0 and > genomeInitialLengthMin
  let logDir: String
  let imageDir: String
  let graphLogUpdateCommand: String
  
  static let defaults = Params(population: 100,
                               stepsPerGeneration: 100,
                               maxGenerations: 100,
                               numThreads: 1,
                               signalLayers: 1,
                               genomeMaxLength: 20,
                               maxNumberNeurons: 20 / 2,
                               pointMutationRate: 0.0001,
                               geneInsertionDeletionRate: 0.0001,
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
                               genomeComparisonMethod: 1,
                               updateGraphLog: false,
                               updateGraphLogStride: 16,
                               challenge: .circle,
                               barrierType: nil,
                               replaceBarrierType: nil,
                               replaceBarrierTypeGenerationNumber: -1,
                               sizeX: 60,
                               sizeY: 60,
                               genomeInitialLengthMin: 16,
                               genomeInitialLengthMax: 16,
                               logDir: "./logs/",
                               imageDir: "./images/",
                               graphLogUpdateCommand: "/usr/bin/gnuplot --persist ./tools/graphlog.gp")
}
