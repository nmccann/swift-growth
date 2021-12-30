import Foundation

/// Survivors are those inside the circular area defined by
/// safeCenter and radius
struct AltruismChallenge: Challenge {
  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    let size = CGSize(width: grid.size.x, height: grid.size.y)
    let safeCenter = Coord(x: Int(size.width / 4.0), y: Int(size.height / 4.0))
    let radius = size.width / 4.0 // in a 128^2 world, holds 3216
    let offset = safeCenter - individual.loc
    let distance = Double(offset.length)
    return distance <= radius ? .pass((radius - distance) / radius) : .fail(0)
  }
}

extension Challenge where Self == AltruismChallenge {
  static func altruism() -> Self { .init() }
}
