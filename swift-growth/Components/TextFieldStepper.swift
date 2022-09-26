import SwiftUI

struct TextFieldStepper<T: Strideable & LosslessStringConvertible>: View {
  let title: LocalizedStringKey
  @Binding var value: T
  let step: T.Stride?

  init(_ title: LocalizedStringKey, value: Binding<T>, step: T.Stride? = nil) {
    self.title = title
    _value = value
    self.step = step
  }

  var body: some View {
    HStack {
      TextField(title, text: $value.asString)
      Group {
        if let step = step {
          Stepper(title, value: $value, step: step)
        } else {
          Stepper(title, value: $value)
        }
      }.labelsHidden()
    }
  }
}
