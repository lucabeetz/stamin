//
//  ActivityRingsView.swift
//  dun
//
//  Created by Luca Beetz on 06.01.22.
//

import Foundation
import SwiftUI
import HealthKit
import HealthKitUI

struct ActivityRingsView: UIViewRepresentable {
    let healthStore: HKHealthStore
    
    func makeUIView(context: Context) -> UIView {
        let frame    = CGRect(x: 0, y: 0, width: 200, height: 200)
        let activityRingsObject = HKActivityRingView(frame: frame)
        
        let calendar = Calendar.autoupdatingCurrent
        var components = calendar.dateComponents([.era, .year, .month, .day], from: Date())
        components.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: components)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { query, summaries, error in
            guard let summaries = summaries, summaries.count > 0
            else {
                return
            }
            
            activityRingsObject.setActivitySummary(summaries.first, animated: true)
        }
        
        healthStore.execute(query)
        
        return activityRingsObject
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
