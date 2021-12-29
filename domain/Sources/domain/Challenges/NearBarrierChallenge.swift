import Foundation

/// Survivors are those within radius of any barrier. Weighted by distance.
struct NearBarrierChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    let radius = Double(grid.size.x / 2)

    let distance =
    grid.barriers.lazy
      .map { individual.loc - $0 }
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
