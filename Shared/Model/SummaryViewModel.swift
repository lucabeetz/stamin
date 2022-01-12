//
//  SummaryViewModel.swift
//  dun (iOS)
//
//  Created by Luca Beetz on 07.01.22.
//

import Foundation
import SwiftUI
import HealthKit

enum PeriodTime: Int32 {
    case never
    case daily
    case weekly
    case monthly
}

extension PeriodTime {
    func calcEndDate(startDate: Date) -> Date {
        switch self {
        case .daily:
            return Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        case .weekly:
            return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        case .monthly:
            return Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        case .never:
            return Calendar.current.date(byAdding: .year, value: 69, to: startDate)!
        }
    }
}

final class SummaryViewModel: ObservableObject {
    var repository: HKRepository
    var persistenceController: PersistenceController
    
    @Published var dailyProgresses: [Progress]
    @Published var dailyProgressesByCategory: [String: [Progress]]
    @Published var repeatingProgresses: [RepeatingProgress]
    
    @Published var moveEnergy: Double = -1
    @Published var moveEnergyGoal: Double = -1
    
    @Published var exerciseMinutes: Double = -1
    @Published var exerciseMinutesGoal: Double = -1
    
    @Published var standHours: Double = -1
    @Published var standHoursGoal: Double = -1
    
    @Published var mindfulMinutes: Double = 0
    @Published var weeklyKilometers: Double = 0
    
    init(repository: HKRepository, persistenceController: PersistenceController) {
        self.repository = repository
        self.persistenceController = persistenceController
        
        // Read repeating progresses
        self.repeatingProgresses = self.persistenceController.getAllRepeatingProgresses()
        self.dailyProgresses = self.persistenceController.getAllDailyProgresses()
        self.dailyProgressesByCategory = self.persistenceController.getAllDailyProgressesByCategory()
        
        // Create new progresses from repeating progresses
        if self.repeatingProgresses.isEmpty {
            self.addExampleRepeatingProgresses()
        }
        self.updateRepeatingProgresses()
        
        self.updateActivityData()
        print(self.dailyProgresses.count)
    }
    
    func updateActivityData() {
        repository.requestActivitySummary() {activitySummary in
            DispatchQueue.main.async {
                // Move energy and goal
                self.moveEnergy = activitySummary.activeEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
                self.moveEnergyGoal = activitySummary.activeEnergyBurnedGoal.doubleValue(for: HKUnit.kilocalorie())
                
                // Exercise time and goal
                self.exerciseMinutes = activitySummary.appleExerciseTime.doubleValue(for: HKUnit.minute())
                self.exerciseMinutesGoal = activitySummary.appleExerciseTimeGoal.doubleValue(for: HKUnit.minute())
                
                // Stand hours and goal
                self.standHours = activitySummary.appleStandHours.doubleValue(for: HKUnit.count())
                self.standHoursGoal = activitySummary.appleStandHoursGoal.doubleValue(for: HKUnit.count())
            }
        }
        
        repository.requestDailyMindfulMinutes() { mindfulMinutes in
            DispatchQueue.main.async {
                self.mindfulMinutes = mindfulMinutes
            }
        }
        
        repository.requestWeeklyRunKilometers() { weeklyKilometers in
            DispatchQueue.main.async {
                self.weeklyKilometers = weeklyKilometers
            }
        }
    }
    
    func updateRepeatingProgresses() {
        outer: for repeatingProgress in self.repeatingProgresses {
            let category = repeatingProgress.category!
            
            // Check if active progress for repeating template exists
            if self.dailyProgressesByCategory[category] != nil {
                for progress in self.dailyProgressesByCategory[category]! {
                    if progress.name! == repeatingProgress.name! {
                        // Continue to next repeating progress if active progress still exists
                        continue outer
                    }
                }
            }
            
            // Create new progress
            self.addProgress(category: repeatingProgress.category!, name: repeatingProgress.name!, goalValue: repeatingProgress.goalValue, unit: repeatingProgress.unit!, color:  UIColor.decode(data: repeatingProgress.color as! Data)!, icon: repeatingProgress.iconName!, period: PeriodTime(rawValue: repeatingProgress.period)!, repeatingId: repeatingProgress.objectID)
        }
        
        self.dailyProgressesByCategory = self.persistenceController.getAllDailyProgressesByCategory()
    }
    
    func createNewProgress(category: String, name: String, goalValue: Double, unit: String, color: UIColor, icon: String, period: PeriodTime) {
        print(period)
        if period == .never {
            self.addProgress(category: category, name: name, goalValue: goalValue, unit: unit, color: color, icon: icon, period: period)
        } else {
            self.addRepeatingProgress(category: category, name: name, goalValue: goalValue, unit: unit, color: color, icon: icon, period: period)
            self.updateRepeatingProgresses()
        }
    }
    
    func addRepeatingProgress(category: String, name: String, goalValue: Double, unit: String, color: UIColor, icon: String, period: PeriodTime) {
        let newRepeatingProgress = RepeatingProgress(context: self.persistenceController.container.viewContext)
        newRepeatingProgress.category = category
        newRepeatingProgress.name = name
        newRepeatingProgress.goalValue = goalValue
        newRepeatingProgress.unit = unit
        newRepeatingProgress.editValues = [1, 10, 100] as NSObject
        newRepeatingProgress.iconName = icon
        newRepeatingProgress.color = color.encode()! as NSObject
        newRepeatingProgress.period = period.rawValue
        
        self.repeatingProgresses = self.persistenceController.getAllRepeatingProgresses()
    }
    
    func addProgress(category: String, name: String, goalValue: Double, unit: String, color: UIColor, icon: String, period: PeriodTime, repeatingId: NSObject? = nil) {
        let newProgress = Progress(context: self.persistenceController.container.viewContext)
        newProgress.category = category
        newProgress.name = name
        newProgress.currentValue = 0
        newProgress.goalValue = goalValue
        newProgress.unit = unit
        newProgress.editValues = [1, 10, 100] as NSObject
        newProgress.iconName = icon
        newProgress.color = color.encode()! as NSObject
        newProgress.repeatingId = repeatingId
        
        // Calculate start and end dates of progress given period time
        switch period {
        case .never:
            newProgress.startDate = Calendar.current.startOfDay(for: Date())
        case .daily:
            newProgress.startDate = Calendar.current.startOfDay(for: Date())
        case .weekly:
            newProgress.startDate = Date().startOfWeek()
        case .monthly:
            newProgress.startDate = Date().startOfMonth()
        }
        
        newProgress.endDate = period.calcEndDate(startDate: newProgress.startDate!)
        
        // Update local list of progresses
        self.dailyProgressesByCategory = self.persistenceController.getAllDailyProgressesByCategory()
    }
    
    func deleteProgress(progress: Progress) {
        self.persistenceController.deleteProgress(progress: progress)
        self.repeatingProgresses = self.persistenceController.getAllRepeatingProgresses()
        self.dailyProgressesByCategory = self.persistenceController.getAllDailyProgressesByCategory()
    }
    
    func addExampleRepeatingProgresses() {
        let progressWater = RepeatingProgress(context: self.persistenceController.container.viewContext)
        progressWater.category = "Nutrition"
        progressWater.name = "Water"
        progressWater.goalValue = 2500
        progressWater.unit = "ML"
        progressWater.editValues = [50, 100, 200, 500] as NSObject
        progressWater.iconName = "drop"
        progressWater.color = UIColor.systemBlue.encode()! as NSObject
        progressWater.period = PeriodTime.daily.rawValue
        
        let progressCalories = RepeatingProgress(context: self.persistenceController.container.viewContext)
        progressCalories.category = "Nutrition"
        progressCalories.name = "Calories"
        progressCalories.goalValue = 2500
        progressCalories.unit = "KCAL"
        progressCalories.editValues = [50, 100, 200, 500] as NSObject
        progressCalories.iconName = "flame"
        progressCalories.color = UIColor.systemRed.encode()! as NSObject
        progressWater.period = PeriodTime.daily.rawValue
    }
}
