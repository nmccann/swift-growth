import SwiftUI
import domain

struct ParameterFormView<Footer: View>: View {
  @Binding var parameters: Parameters
  @ViewBuilder let footer: () -> Footer

  var body: some View {
    Form {
      ScrollView {
        Section(content: content, footer: footer)
      }
    }.padding()
  }

  @ViewBuilder
  func content() -> some View {
    Group {
      HStack {
        TextFieldStepper("Width", value: .init(get: { parameters.size.width },
                                               set: { parameters.size = .init(width: $0,
                                                                              height: parameters.size.height)}))
        TextFieldStepper("Height", value: .init(get: { parameters.size.height },
                                                set: { parameters.size = .init(width: parameters.size.width,
                                                                               height: $0)}))
      }
      TextFieldStepper("Population", value: $parameters.population)
      TextFieldStepper("Steps Per Generation", value: $parameters.stepsPerGeneration)
      TextFieldStepper("Max Generations", value: $parameters.maxGenerations)
      TextFieldStepper("Signal Layers", value: $parameters.signalLayers)
      TextFieldStepper("Genome Max Length", value: $parameters.genomeMaxLength)
      TextFieldStepper("Max Neurons", value: $parameters.maxNumberNeurons)
      TextFieldStepper("Point Mutation Rate", value: $parameters.pointMutationRate, step: 0.0001)
      TextFieldStepper("Gene Insertion/Deletion Rate", value: $parameters.geneInsertionDeletionRate, step: 0.0001)
    }

    Group {
      TextFieldStepper("Initial Responsiveness", value: $parameters.initialResponsiveness, step: 0.05)

      Slider(value: $parameters.deletionRatio, in: 0.0...1.0, step: 0.01) {
        Text("Deletion Ratio – \(parameters.deletionRatio, specifier: "%.2f")")
      }

      Toggle("Sexual Reproduction", isOn: $parameters.sexualReproduction)

      Toggle("Parents By Fitness", isOn: $parameters.chooseParentsByFitness)
      Toggle("Persist Manual Barriers", isOn: $parameters.shouldPersistManualBarriers)
      Slider(value: $parameters.signalSensorRadius.asDouble, in: 0...16, step: 1) {
        Text("Signal Sensor Radius – \(parameters.signalSensorRadius)")
      }
    }
  }
}
