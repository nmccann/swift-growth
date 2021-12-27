import Foundation
@testable import domain

extension Indiv {
  static func stub(index: Int = 0,
                   loc: Coord = .init(x: 0, y: 0),
                   genome: Genome = makeRandomGenome(10...10),
                   probeDistance: (short: Int, long: Int) = (short: 3, long: 16),
                   maxNumberOfNeurons: Int = 10,
                   actions: Int = 17, sensors: Int = 20) -> Self {
    .init(index: index,
          loc: loc,
          genome: genome,
          probeDistance: probeDistance,
          maxNumberOfNeurons: maxNumberOfNeurons,
          actions: actions,
          sensors: sensors)
  }
}
