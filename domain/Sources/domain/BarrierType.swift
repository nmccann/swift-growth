import Foundation

enum BarrierType {
  /// Vertical bar in constant location
  case verticalBarConstant

  /// Vertical bar in random location
  case verticalBarRandom

  /// five blocks staggered
  case fiveBlocks

  /// Horizontal bar in constant location
  case horizontalBarConstant

  /// Three floating islands -- different locations every generation
  case threeIslandsRandom

  /// Spots, specified number, radius, locations  -- different locations every generation
  case spotsRandom
}
