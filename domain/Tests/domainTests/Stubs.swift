import Foundation
@testable import domain

extension Indiv {
  static func stub(index: Int = 0,
                   loc: Coord = .init(x: 0, y: 0),
                   genome: Genome = makeRandomGenome(minLength: 10, maxLength: 10),
                   longProbeDistance: Int = 16,
                   maxNumberOfNeurons: Int = 10) -> Self {
    .init(index: index,
          loc: loc,
          genome: genome,
          longProbeDistance: longProbeDistance,
          maxNumberOfNeurons: maxNumberOfNeurons)
  }
}
