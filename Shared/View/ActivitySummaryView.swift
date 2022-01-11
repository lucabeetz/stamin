//
//  ActivitySummaryView.swift
//  dun (iOS)
//
//  Created by Luca Beetz on 06.01.22.
//

import SwiftUI
import HealthKit

struct ActivitySummaryView: View {
    @ObservedObject var viewModel: SummaryViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Move")
                    .font(.callout)
                
                HStack(alignment: .bottom,spacing: 0.0) {
                    Text(viewModel.moveEnergy.cleanValue + "/" + viewModel.moveEnergyGoal.cleanValue)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.red)
                    Text("KCAL")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                }
                .padding(.bottom, 1.0)
                
                Text("Exercise")
                    .font(.callout)
                HStack(alignment: .bottom,spacing: 0.0) {
                    Text(viewModel.exerciseMinutes.cleanValue + "/" + viewModel.exerciseMinutesGoal.cleanValue)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.green)
                    Text("MIN")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                }
                .padding(.bottom, 1.0)
                
                Text("Stand")
                    .font(.callout)
                HStack(alignment: .bottom,spacing: 0.0) {
                    Text(viewModel.standHours.cleanValue + "/" + viewModel.standHoursGoal.cleanValue)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.blue)
                    Text("HRS")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color.blue)
                }
                .padding(.bottom, 1.0)
            }
            
            Spacer()
            
            ActivityRingsView(healthStore: HKHealthStore())
                .frame(width: 120, height: 120)
        }
    }
}

struct ActivitySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitySummaryView(viewModel: SummaryViewModel(repository: HKRepository(), persistenceController: PersistenceController.preview))
    }
}
