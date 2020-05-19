//
//  Date+.swift
//  SleepTimerAssignment
//
//  Created by Mykola Aleshchenko on 17.05.2020.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import Foundation

extension Date {
    private var dateFormat: String {
        return "HH:mm"
    }
    
    private var fullFormat: String {
        return "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter
    }
    
    var fullFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = fullFormat
        return formatter
    }
    
    var noSeconds: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: self)
        return calendar.date(from: dateComponents) ?? Date()
    }
    
    static func timeDifference(startDate: Date) -> Int {
        return Int(Date().timeIntervalSince(startDate))
    }
    
    func timeString() -> String {
        return dateFormatter.string(from: self.noSeconds)
    }
    
    func fullDateString() -> String {
        return fullFormatter.string(from: self)
    }
}
