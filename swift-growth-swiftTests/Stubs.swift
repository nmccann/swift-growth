import Foundation
@testable import swift_growth

extension Indiv {
  static func stub(index: Int = 0,
                   loc: Coord = .init(x: 0, y: 0),
                   genome: Genome = makeRandomGenome()) -> Self {
    .init(index: index, loc: loc, genome: genome)
  }
}
