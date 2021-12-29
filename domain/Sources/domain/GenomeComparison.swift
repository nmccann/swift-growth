import Foundation
import Algorithms

public enum GenomeComparison {
  case jaroWinkler
  case hammingBits
  case hammingBytes

  /// Returns 0.0..1.0
  ///
  /// ToDo: optimize by approximation for long genomes
  func similarity(_ lhs: Genome, _ rhs: Genome) -> Double {
    switch self {
    case .jaroWinkler:
      if lhs.count > rhs.count {
        return jaroWinklerDistance(lhs, rhs)
      } else {
        return jaroWinklerDistance(rhs, lhs)
      }
    case .hammingBits: return hammingDistanceBits(lhs, rhs)
    case .hammingBytes: return hammingDistanceBytes(lhs, rhs)
    }
  }

  /// returns 0.0..1.0
  /// Samples random pairs of individuals regardless if they are alive or not
  public func diversityFor(_ individuals: [Indiv], initialPopulation: Int) -> Double {
    guard initialPopulation >= 2 else {
      return 0
    }

    // count limits the number of genomes sampled for performance reasons.
    let count = min(1000, initialPopulation) // todo: !!! p.analysisSampleSize;

    let similaritySum = (0..<count).reduce(into: 0.0) { partialResult, _ in
      let individuals = individuals.randomSample(count: 2)
      partialResult += similarity(individuals[0].genome, individuals[1].genome)
    }

    return 1.0 - (similaritySum / Double(count))
  }
}

private extension GenomeComparison {
  /// The jaro_winkler_distance() function is adapted from the C version at
  /// https://github.com/miguelvps/c/blob/master/jarowinkler.c
  /// under a GNU license, ver. 3. This comparison function is useful if
  /// the simulator allows genomes to change length, or if genes are allowed
  /// to relocate to different offsets in the genome. I.e., this function is
  /// tolerant of gaps, relocations, and genomes of unequal lengths.
  ///
  func jaroWinklerDistance(_ lhs: Genome, _ rhs: Genome) -> Double {
    //TODO: This has been cleaned up a little from the
    //original implementation, but could be greatly improved
    guard !lhs.isEmpty && !rhs.isEmpty else {
      return 0
    }

    var matches = 0
    var transpositions = 0
    let maxNumberOfGenesToCompare = 20

    let lhsLength = min(maxNumberOfGenesToCompare, lhs.count) //optimization: approximate for long genomes
    let rhsLength = min(maxNumberOfGenesToCompare, rhs.count)

    var lhsFlags: [Int] = .init(repeating: 0, count: lhsLength)
    var rhsFlags: [Int] = .init(repeating: 0, count: rhsLength)
    let range = max(0, max(lhsLength, rhsLength) / 2 - 1)

    // calculate matching characters
    for i in 0..<rhsLength {
      for j in max(i - range, 0)..<(min(i + range + 1, lhsLength)) {
        guard lhs[j] == rhs[i] else {
          continue
        }

        lhsFlags[j] = 1
        rhsFlags[i] = 1
        matches += 1
        break
      }
    }

    guard matches > 0 else {
      return 0
    }

    // calculate character transpositions
    var l = 0
    for i in 0..<rhsLength {
      guard rhsFlags[i] == 1 else {
        continue
      }

      for j in l..<lhsLength {
        guard lhsFlags[j] == 1 else {
          continue
        }

        l = j + 1
        transpositions += lhs[j] != rhs[i] ? 1 : 0
        break
      }
    }

    transpositions /= 2

    // Jaro distance
    let lhsMatchPercent = Double(matches) / Double(lhsLength)
    let rhsMatchPercent = Double(matches) / Double(rhsLength)
    let transposedMatchPercent = Double(matches - transpositions) / Double(matches)
    let components = [lhsMatchPercent, rhsMatchPercent, transposedMatchPercent]
    return components.reduce(0, +) / Double(components.count)
  }

  /// Works only for genomes of equal length
  func hammingDistanceBits(_ lhs: Genome, _ rhs: Genome) -> Double {
    assert(lhs.count == rhs.count)
    let lhsBytes = lhs.withUnsafeBufferPointer { [UInt8](Data(buffer: $0)) }
    let rhsBytes = rhs.withUnsafeBufferPointer { [UInt8](Data(buffer: $0)) }

    let bitCount = zip(lhsBytes, rhsBytes).reduce(into: 0) { partialResult, bytes in
      partialResult += (bytes.0 ^ bytes.1).nonzeroBitCount
    }

    let lengthBits = lhsBytes.count * 8

    // For two completely random bit patterns, about half the bits will differ,
    // resulting in c. 50% match. We will scale that by 2X to make the range
    // from 0 to 1.0. We clip the value to 1.0 in case the two patterns are
    // negatively correlated for some reason.
    return 1.0 - min(1.0, (2.0 * Double(bitCount)) / Double(lengthBits))
  }

  /// Works only for genomes of equal length
  func hammingDistanceBytes(_ lhs: Genome, _ rhs: Genome) -> Double {
    assert(lhs.count == rhs.count)
    let lhsBytes = lhs.withUnsafeBufferPointer { [UInt8](Data(buffer: $0)) }
    let rhsBytes = rhs.withUnsafeBufferPointer { [UInt8](Data(buffer: $0)) }

    let byteCount = zip(lhsBytes, rhsBytes).reduce(into: 0) { partialResult, bytes in
      partialResult += bytes.0 == bytes.1 ? 1 : 0
    }

    return Double(byteCount) / Double(lhsBytes.count)
  }
}
