import SwiftUI

extension Binding where Value == Int {
  var asDouble: Binding<Double> {
    .init(get: { Double(wrappedValue) },
          set: { wrappedValue = Int($0) })
  }
}

extension Binding where Value: LosslessStringConvertible {
  var asString: Binding<String> {
    .init(get: { wrappedValue.description },
          set: {
      wrappedValue = Value($0) ?? wrappedValue
    })
  }
}
