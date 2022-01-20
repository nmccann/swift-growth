import Foundation

public struct Size: Equatable {
  public let width: Int
  public let height: Int

  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }
}

public extension CGSize {
  init(_ size: Size) {
    self.init(width: size.width, height: size.height)
  }
}
