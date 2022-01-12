//
//  Extensions.swift
//  dun (iOS)
//
//  Created by Luca Beetz on 08.01.22.
//

import Foundation
import SwiftUI
import CoreData

extension UIColor {
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    static func decode(data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) 
    }
}

extension Double {
    var cleanValue: String {
        return String(format: "%.0f", self)
    }
}

extension Date {
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    func startOfMonth(using calendar: Calendar = .current) -> Date {
        calendar.dateComponents([.calendar, .year, .month], from: self).date!
    }
}
