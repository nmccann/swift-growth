import Foundation

/// Survivors are those inside the circular area defined by
/// safeCenter and radius
struct CircleChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    let safeCenter = Coord(x: Int(Double(grid.size.x) / 4.0), y: Int(Double(grid.size.y) / 4.0))
    let radius = Double(grid.size.x) / 4.0
    let offset = safeCenter - individual.loc
    let distance = Double(offset.length)
    return distance <= radius ? .pass((radius - distance) / radius) : .fail(0)
  }
}

extension Challenge where Self == CircleChallenge {
  static func circle() -> Self { .init() }
}
