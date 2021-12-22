import Foundation

/// Some of the survival challenges to try. Some are interesting, some
/// not so much. Fine-tune the challenges by tweaking the corresponding code
/// in survival-criteria
enum Challenge {
  /// Survivors are those inside the circular area defined by
  /// safeCenter and radius
  case circle

  /// Survivors are all those on the right side of the arena
  case rightHalf

  /// Survivors are all those on the right quarter of the arena
  case rightQuarter

  /// Survivors are all those on the left eighth of the arena
  case leftEighth

  /// Survivors are those not touching the border and with exactly the number
  /// of neighbors defined by neighbors and radius, where neighbors includes self
  case string

  /// Survivors are those within the specified radius of the center. The score
  /// is linearly weighted by distance from the center.
  case centerWeighted

  /// Survivors are those within the specified radius of the center
  case centerUnweighted

  /// Survivors are those within the specified outer radius of the center and with
  /// the specified number of neighbors in the specified inner radius.
  /// The score is not weighted by distance from the center.
  case centerSparse

  /// Survivors are those within the specified radius of any corner.
  /// Assumes square arena.
  case corner

  /// Survivors are those within the specified radius of any corner. The score
  /// is linearly weighted by distance from the corner point.
  /// Assumes square arena.
  case cornerWeighted

  /// This challenge is handled in endOfSimStep(), where individuals may die
  /// at the end of any sim step. There is nothing else to do here at the
  /// end of a generation. All remaining alive become parents.
  case radioactiveWalls

  /// Survivors are those touching any wall at the end of the generation
  case touchAnyWall

  /// This challenge is partially handled in endOfSimStep(), where individuals
  /// that are touching a wall are flagged in their Indiv record. They are
  /// allowed to continue living. Here at the end of the generation, any that
  /// never touch a wall will die. All that touched a wall at any time during
  /// their life will become parents.
  case againstAnyWall

  /// Everybody survives and are candidate parents, but scored by how far
  /// they migrated from their birth location.
  case migrateDistance

  /// Survivors are all those on the left or right eighths of the arena
  case eastWestEighths

  /// Survivors are those within radius of any barrier center. Weighted by distance.
  case nearBarrier

  /// Survivors are those not touching a border and with exactly one neighbor which has no other neighbor
  case pairs

  /// Survivors are those that contacted one or more specified locations in a sequence,
  /// ranked by the number of locations contacted. There will be a bit set in their
  /// challengeBits member for each location contacted.
  case locationSequence

  /// Survivors are all those within the specified radius of the NE corner
  case altruismSacrifice

  /// Survivors are those inside the circular area defined by
  /// safeCenter and radius
  case altruism
}
