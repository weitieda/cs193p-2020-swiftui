//
//  FoundationExtensions.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Foundation

extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}

extension Data {
    var utf8: String? { String(data: self, encoding: .utf8 ) }
}

extension String {
    var trim: String {
        var trimmed = self.drop(while: { $0.isWhitespace })
        while trimmed.last?.isWhitespace ?? false {
            trimmed = trimmed.dropLast()
        }
        return String(trimmed)
    }

    var base64: String? { self.data(using: .utf8)?.base64EncodedString() }
    
    func contains(elementIn array: [String]) -> Bool {
        array.contains(where: { self.contains($0) })
    }
}

extension DateFormatter {
    static var short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    static var shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static var shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    static func stringRelativeToToday(_ today: Date, from date: Date) -> String {
        let dateComponents = Calendar.current.dateComponents(in: .current, from: date)
        var nowComponents = Calendar.current.dateComponents(in: .current, from: today)
        if dateComponents.isSameDay(as: nowComponents) {
            return "today at " + DateFormatter.shortTime.string(from: date)
        }
        nowComponents = Calendar.current.dateComponents(in: .current, from: today.addingTimeInterval(24*60*60))
        if dateComponents.isSameDay(as: nowComponents) {
            return "tomorrow at " + DateFormatter.shortTime.string(from: date)
        }
        nowComponents = Calendar.current.dateComponents(in: .current, from: today.addingTimeInterval(-24*60*60))
        if dateComponents.isSameDay(as: nowComponents) {
            return "yesterday at " + DateFormatter.shortTime.string(from: date)
        }
        return DateFormatter.short.string(from: date)
    }
}

extension DateComponents {
    func isSameDay(as other: DateComponents) -> Bool {
        return self.year == other.year && self.month == other.month && self.day == other.day
    }
}
