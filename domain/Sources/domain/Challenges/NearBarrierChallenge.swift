import Foundation

/// Survivors are those within radius of any barrier. Weighted by distance.
struct NearBarrierChallenge: Challenge {
  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    let radius = Double(grid.size.width / 2)

    let distance =
    grid.barriers.lazy
      .map { individual.loc - $0.coord }
      .map(\.length)
      .map(Double.init)
      .min()

    guard let distance = distance else {
      return .fail(0)
    }

    return distance <= radius ? .pass(1.0 - (distance / radius)) : .fail(0)
  }
}

extension Challenge where Self == NearBarrierChallenge {
  static func nearBarrier() -> Self { .init() }
}
