//
//  CreateProgressView.swift
//  dun (iOS)
//
//  Created by Luca Beetz on 09.01.22.
//

import SwiftUI

let availableIcons: [String] = ["flame", "drop", "repeat"]
let availableColors: [UIColor] = [.systemRed, .systemBlue, .systemCyan, .systemYellow, .systemOrange]


struct CreateProgressView: View {
    let viewModel: SummaryViewModel
    @State var category: String = ""
//    let category: String
    
    var categoryProvided: Bool = true
    
    @State private var name: String = ""
    @State private var unit: String = ""
    @State private var goalValue: Double = 0
    
    @State private var color: UIColor = UIColor.systemBlue
    @State private var icon: String = "flame"
    @State private var period: PeriodTime = PeriodTime.never
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            Form {
                if !categoryProvided {
                    TextField("Category", text: $category)
                }
                
                TextField("Name", text: $name)
                TextField("Goal value", value: $goalValue, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Unit", text: $unit)
                
                Picker("Color", selection: $color) {
                    ForEach(availableColors, id: \.self) { color in
                        Circle()
                            .fill(Color(uiColor: color))
                            .frame(width: 16.0, height: 16.0)
                    }
                }
                
                Picker("Icon", selection: $icon) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Image(systemName: icon).tag(icon)
                    }
                }
                
                Picker("Repeat", selection: $period) {
                    Text("Never").tag(PeriodTime.never)
                    Text("Daily").tag(PeriodTime.daily)
                    Text("Weekly").tag(PeriodTime.weekly)
                    Text("Monthly").tag(PeriodTime.monthly)
                }
                
                Button("Add progress") {
                    print(category)
                    viewModel.createNewProgress(category: category, name: name, goalValue: goalValue, unit: unit, color: color, icon: icon, period: period)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CreateProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProgressView(viewModel: SummaryViewModel(repository: HKRepository(), persistenceController: PersistenceController.preview), category: "Nutrition")
            .preferredColorScheme(.dark)
    }
}
