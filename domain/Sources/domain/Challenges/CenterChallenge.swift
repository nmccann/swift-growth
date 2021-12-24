import Foundation

/// Survivors are those within the specified radius of the center. The score
/// is linearly weighted by distance from the center.
struct CenterChallenge: Challenge {
  enum Scoring {
    case weighted, unweighted
  }

  let scoring: Scoring

  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    let radius = Double(grid.size.x) / 3.0
    let safeCenter = Coord(x: Int(Double(grid.size.x) / 2.0), y: Int(Double(grid.size.y) / 2.0))
    let circle = CircleChallenge(radius: radius,
                                 location: safeCenter,
                                 scoring: circleScoring)

    return circle.test(individual, on: grid)
  }
}

private extension CenterChallenge {
  var circleScoring: CircleChallenge.Scoring {
    switch scoring {
    case .weighted: return .weighted
    case .unweighted: return .unweighted
    }
  }
}

extension Challenge where Self == CenterChallenge {
  static func center(scoring: CenterChallenge.Scoring) -> Self { .init(scoring: scoring) }
}
