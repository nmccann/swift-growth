import Foundation

// Some of the survival challenges to try. Some are interesting, some
// not so much. Fine-tune the challenges by tweaking the corresponding code
// in survival-criteria
enum Challenge: Int {
  case circle,
       rightHalf,
       rightQuarter,
       string,
       centerWeighted,
       centerUnweighted,
       corner,
       cornerWeighted,
       migrateDistance,
       centerSparse,
       leftEighth,
       radioactiveWalls,
       againstAnyWall,
       touchAnyWall,
       eastWestEighths,
       nearBarrier,
       pairs,
       locationSequence,
       altruism,
       altruismSacrifice
}
