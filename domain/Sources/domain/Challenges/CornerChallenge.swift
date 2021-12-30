import Foundation

/// Survivors are those within the specified radius of any corner.
/// Assumes square arena.
struct CornerChallenge: Challenge {
  enum Scoring {
    case weighted, unweighted
  }

  let scoring: Scoring

  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    switch scoring {
    case .weighted: return innerTest(individual, on: grid)
    case .unweighted:  return innerTest(individual, on: grid)
    }
  }
}

private extension CornerChallenge {
  var circleScoring: CircleChallenge.Scoring {
    switch scoring {
    case .weighted: return .weighted
    case .unweighted: return .unweighted
    }
  }

  /// Survivors are those within the specified radius of any corner.
  /// Assumes square arena.
  /// - Parameters:
  ///   - individual: The individual being scored
  /// - Returns: An indication of whether the individual passed the challenge, and their accompanying score
  func innerTest(_ individual: Individual,
                  on grid: Grid) -> ChallengeResult {
    assert(grid.size.x == grid.size.y)
    let radius = Double(grid.size.x) / 8.0

    return allCorners(with: radius, on: grid).lazy
      .map { $0.test(individual, on: grid) }
      .first(where: \.didPass) ?? .fail(0)
  }

  func allCorners(with radius: Double, on grid: Grid) -> [Challenge] {
    let scoring = circleScoring
    let topLeft = CircleChallenge(radius: radius, location: .init(x: 0, y: 0), scoring: scoring)
    let bottomLeft = CircleChallenge(radius: radius, location: .init(x: 0, y: grid.size.y - 1), scoring: scoring)
    let topRight = CircleChallenge(radius: radius, location: .init(x: grid.size.x - 1, y: 0), scoring: scoring)
    let bottomRight = CircleChallenge(radius: radius, location: .init(x: grid.size.x - 1, y: grid.size.y - 1), scoring: scoring)
    return [topLeft, bottomLeft, topRight, bottomRight]
  }
}

extension Challenge where Self == CornerChallenge {
  static func corner(scoring: CornerChallenge.Scoring) -> Self { .init(scoring: scoring) }
}
