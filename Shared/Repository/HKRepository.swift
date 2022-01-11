//
//  HKRepository.swift
//  dun (iOS)
//
//  Created by Luca Beetz on 07.01.22.
//

import Foundation
import HealthKit

final class HKRepository {
    var healthStore: HKHealthStore?
    
    let objectTypes: Set<HKObjectType> = [
        HKObjectType.activitySummaryType(),
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    ]
    
    init() {
        healthStore = HKHealthStore()
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let store = healthStore else {
            return
        }
        
        store.requestAuthorization(toShare: nil, read: objectTypes) { success, error in
            completion(success)
        }
    }
    
    func requestActivitySummary(completion: @escaping (HKActivitySummary) -> Void) {
        let calendar = Calendar.autoupdatingCurrent
        var components = calendar.dateComponents([.era, .year, .month, .day], from: Date())
        components.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: components)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { query, summaries, error in
            guard let summaries = summaries, summaries.count > 0
            else {
                return
            }
            
            completion(summaries.first!)
        }
        
        healthStore!.execute(query)
    }
    
    func requestDailyMindfulMinutes(completion: @escaping (TimeInterval) -> Void) {
        let sampleType = HKSampleType.categoryType(forIdentifier: .mindfulSession)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let results = results, results.count > 0
            else {
                completion(0)
                return
            }
            
            var totalTime = TimeInterval()
            for result in results {
                totalTime += result.endDate.timeIntervalSince(result.startDate)
            }
            completion(totalTime / 60)
        }
        
        healthStore!.execute(query)
    }
    
    func requestWeeklyRunKilometers(completion: @escaping (Double) -> Void) {
        let startDate = Date().startOfWeek()
        
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {query, results, error in
            guard let results = results as? [HKWorkout]
            else {
                completion(0)
                return
            }
            
            var weeklyDistance: Double = 0
            for workout in results {
                if workout.startDate < startDate {
                    break
                }
                
                if workout.workoutActivityType == HKWorkoutActivityType.running {
                    let workoutDistance = workout.totalDistance?.doubleValue(for: HKUnit.meter())
                    weeklyDistance += workoutDistance!
                }
            }
            
            completion(weeklyDistance / 1000)
        }
        
        healthStore!.execute(query)
    }
}
