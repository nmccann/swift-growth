import Foundation

/// Survivors are those within the specified radius of the center
struct CenterUnweightedChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    let safeCenter = Coord(x: Int(Double(grid.size.x) / 2.0), y: Int(Double(grid.size.y) / 2.0))
    let radius = Double(grid.size.x) / 3.0
    let offset = safeCenter - individual.loc
    let distance = Double(offset.length)
    return distance <= radius ? .pass(1) : .fail(0)
  }
}

extension Challenge where Self == CenterUnweightedChallenge {
  static func centerUnweighted() -> Self { .init() }
}
