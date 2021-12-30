import Foundation

/// Survivors are those inside the circular area defined by
/// safeCenter and radius
struct CircleChallenge: Challenge {
  enum Scoring {
    case weighted, unweighted
  }

  let radius: Double
  let location: Coord
  let scoring: Scoring

  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    switch scoring {
    case .weighted:
      return innerTest(individual, on: grid) { pass, radius, distance in pass ? (radius - distance) / radius : 0 }
    case .unweighted:
      return innerTest(individual, on: grid) { pass, _, _ in pass ? 1 : 0 }
    }
  }
}

private extension CircleChallenge {
  func innerTest(_ individual: Individual,
                 on grid: Grid,
                 scoreFunction: (_ pass: Bool, _ radius: Double, _ distance: Double) -> Double) -> ChallengeResult {
    let offset = location - individual.loc
    let distance = Double(offset.length)
    return distance <= radius ? .pass(scoreFunction(true, radius, distance)) : .fail(scoreFunction(false, radius, distance))
  }
}

extension Challenge where Self == CircleChallenge {
  static func circle(with radius: Double, at location: Coord, scoring: CircleChallenge.Scoring) -> Self { .init(radius: radius, location: location, scoring: scoring) }
}
