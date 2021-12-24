import Foundation

/// Survivors are those within the specified radius of the center. The score
/// is linearly weighted by distance from the center.
struct CenterWeightedChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    let safeCenter = Coord(x: Int(Double(grid.size.x) / 2.0), y: Int(Double(grid.size.y) / 2.0))
    let radius = Double(grid.size.x) / 3.0
    let offset = safeCenter - individual.loc
    let distance = Double(offset.length)
    return distance <= radius ? .pass((radius - distance) / radius) : .fail(0)
  }
}

extension Challenge where Self == CenterWeightedChallenge {
  static func centerWeighted() -> Self { .init() }
}
