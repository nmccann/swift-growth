import Foundation

/// Survivors are those within the specified radius of any corner.
/// Assumes square arena.
struct CornerChallenge: Challenge {
  enum Scoring {
    case weighted, unweighted
  }

  let scoring: Scoring

  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    switch scoring {
    case .weighted:
      return innerTest(indiv: individual, on: grid) { pass, radius, distance in pass ? (radius - distance) / radius : 0 }

    case .unweighted:
      return innerTest(indiv: individual, on: grid) { pass, _, _ in pass ? 1 : 0 }
    }
  }
}

private extension CornerChallenge {
  /// Survivors are those within the specified radius of any corner.
  /// Assumes square arena.
  /// - Parameters:
  ///   - indiv: The individual being scored
  ///   - scoring: Used to apply different scoring curves
  /// - Returns: An indication of whether the individual passed the challenge, and their accompanying score
  func innerTest(indiv: Indiv,
                  on grid: Grid,
                  scoring: (_ pass: Bool, _ radius: Double, _ distance: Double) -> Double) -> ChallengeResult {
    assert(grid.size.x == grid.size.y)
    let radius = Double(grid.size.x) / 8.0

    let topLeftDistance = Double((Coord(x: 0, y: 0) - indiv.loc).length)
    if topLeftDistance <= radius
    {
      return .pass(scoring(true, radius, topLeftDistance))
    }

    let bottomLeftDistance = Double((Coord(x: 0, y: grid.size.y - 1) - indiv.loc).length)
    if bottomLeftDistance <= radius
    {
      return .pass(scoring(true, radius, bottomLeftDistance))
    }

    let topRightDistance = Double((Coord(x: grid.size.x - 1, y: 0) - indiv.loc).length)
    if topRightDistance <= radius
    {
      return .pass(scoring(true, radius, topRightDistance))
    }

    let bottomRightDistance = Double((Coord(x: grid.size.x - 1, y: grid.size.y - 1) - indiv.loc).length)
    if bottomRightDistance <= radius
    {
      return .pass(scoring(true, radius, bottomRightDistance))
    }

    return .fail(scoring(false, radius, topLeftDistance))
  }
}

extension Challenge where Self == CornerChallenge {
  static func corner(scoring: CornerChallenge.Scoring) -> Self { .init(scoring: scoring) }
}
