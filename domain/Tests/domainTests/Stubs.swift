import Foundation
@testable import domain

extension Indiv {
  static func stub(index: Int = 0,
                   loc: Coord = .init(x: 0, y: 0),
                   genome: Genome = makeRandomGenome()) -> Self {
    .init(index: index, loc: loc, genome: genome)
  }
}
