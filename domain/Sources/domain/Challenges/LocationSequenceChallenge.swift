import Foundation

/// Survivors are those that contacted one or more specified locations in a sequence,
/// ranked by the number of locations contacted. There will be a bit set in their
/// challengeBits member for each location contacted.
struct LocationSequenceChallenge: Challenge {
  let radius: Double

  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult {
    // If this challenge is enabled, the individual gets a bit set in their challengeBits
    // member if they are within a specified radius of a barrier center. They have to
    // visit the barriers in sequential order.
    var result = result


    //TODO: Possible performance improvement, use challenge bits to skip barriers
    //on subsequent iterations
    //TODO: Restore the sequential nature of this challenge, cannot currently do this as
    //the barriers have no specific order. Perhaps introduce a new kind like "Flag" or "Objective"
    let sorted = grid.barriers.sorted { $0.coord.x < $1.coord.x }

    for (n, center) in sorted.enumerated() {
      let bit = 1 << n

      if result.individual.challengeBits & bit == 0 {
        if Double((result.individual.loc - center.coord).length) <= radius {
          result.individual.challengeBits |= bit
        }

        //Break out of loop so additional barriers are ignored until next iteration
        break
      }
    }

    return result
  }

  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    let bits = individual.challengeBits
    let count = bits.nonzeroBitCount
    let maxNumberOfBits = MemoryLayout.size(ofValue: bits) * 8

    return count > 0 ? .pass(Double(count) / Double(maxNumberOfBits)) : .fail(0)
  }
}

extension Challenge where Self == LocationSequenceChallenge {
  static func locationSequence(radius: Double = 9.0) -> Self {
    .init(radius: radius)
  }
}
