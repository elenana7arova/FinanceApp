//
//  DatePredicates.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 14.04.2021.
//

import UIKit
import RealmSwift

let realm = try! Realm()

struct DatePredicates {
    enum Periods {
        case allTime, thisMonth, thisWeek, today
    }
    
    let now = Date()
    
    func filteredByPeriodItems(for period: Periods, items: Results<Item>?) -> (Results<Item>?) {
        switch period {
        case .thisMonth:
            return items!.filter("dateCreated >= %@ && dateCreated =< %@", now.startOfMonth, now.endOfMonth)
        case .thisWeek:
            return items!.filter("dateCreated >= %@ && dateCreated =< %@", now.startOfWeek, now.endOfWeek)
        case .today:
            return items!.filter("dateCreated >= %@ && dateCreated =< %@", now.startOfDay, now.endOfDay)
        case .allTime:
            return items
        }
    }

}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }

    var startOfWeek: Date {
        let calendar = Calendar(identifier: .gregorian)
        let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return calendar.date(byAdding: .day, value: 1, to: sunday)!
    }
    
    var endOfWeek: Date {
        let calendar = Calendar(identifier: .gregorian)
        let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return calendar.date(byAdding: .day, value: 7, to: sunday)!
    }
    
    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
}
