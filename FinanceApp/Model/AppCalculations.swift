//
//  AppCalculations.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 02.03.2021.
//

import UIKit
import RealmSwift

struct Values {
    // incomes and outcomes
    var tIncome: Double
    var tOutcome: Double
    
    var mIncome: Double
    var mOutcome: Double
    
    var wIncome: Double
    var wOutcome: Double
    
    var allIncome: Double
    var allOutcome: Double
    
    // transfers
    var tInTransfer: Double
    var tOutTransfer: Double

    var mInTransfer: Double
    var mOutTransfer: Double

    var wInTransfer: Double
    var wOutTransfer: Double
    
    var allInTransfer: Double
    var allOutTransfer: Double
    
    // balance
    var balance: Double
}

struct AppCalculations {
    let realm = try! Realm()
    var values: Values?
    
    enum Mode {
        case today, weekly, monthly, allTime
    }
    
    func setMode(mode: Mode) -> String {
        switch mode {
        case .today:
            return "Today"
        case .weekly:
            return "This week"
        case .monthly:
            return "This month"
        case .allTime:
            return "All time"
        }
    }
    
    mutating func periodValues(for account: Account?) {
        let calendar = Calendar.current
        let now = Date()
        
        // incomes and outcomes
        var tIncome = 0.0
        var tOutcome = 0.0
        
        var mIncome = 0.0
        var mOutcome = 0.0
        
        var wIncome = 0.0
        var wOutcome = 0.0
        
        var allIncome = 0.0
        var allOutcome = 0.0
        
        // transfers
        var tInTransfer = 0.0
        var tOutTransfer = 0.0

        var mInTransfer = 0.0
        var mOutTransfer = 0.0

        var wInTransfer = 0.0
        var wOutTransfer = 0.0
        
        var allInTransfer = 0.0
        var allOutTransfer = 0.0
        
        // balance
        var balance = 0.0
        //print(account?.accountName)
        
        var objects = realm.objects(Item.self).filter("isTransfer == false")
        if let acc = account {
            objects = objects.filter("account.id = %@", acc.id)
        }
        
        for object in objects {
            if object.isIncome {
                dateIsPresent(date: object.dateCreated!) ? (balance += object.moneyFlow) : ()
                    //balance += object.moneyFlow
                
                allIncome += object.moneyFlow
                if calendar.isDateInToday(object.dateCreated!) {
                    tIncome += object.moneyFlow
                }
                if calendar.isDate(now, equalTo: object.dateCreated!, toGranularity: .month) {
                    mIncome += object.moneyFlow
                }
                if calendar.isDate(now, equalTo: object.dateCreated!, toGranularity: .weekdayOrdinal) {
                    wIncome += object.moneyFlow
                }
            }
            else {
                dateIsPresent(date: object.dateCreated!) ? (balance -= object.moneyFlow) : ()
                //balance -= object.moneyFlow
                allOutcome -= object.moneyFlow
                if calendar.isDateInToday(object.dateCreated!) {
                    tOutcome -= object.moneyFlow
                }
                if calendar.isDate(now, equalTo: object.dateCreated!, toGranularity: .month) {
                    mOutcome -= object.moneyFlow
                }
                if calendar.isDate(now, equalTo: object.dateCreated!, toGranularity: .weekdayOrdinal) {
                    wOutcome += object.moneyFlow
                }
            }
        }

        var transfers = realm.objects(Item.self).filter("isTransfer == true")
        for transfer in transfers {
            if transfer.accountFrom == account {
                dateIsPresent(date: transfer.dateCreated!) ? (balance -= transfer.moneyFlow) : ()
                //balance -= transfer.moneyFlow
                allOutTransfer += transfer.moneyFlow
                
                if calendar.isDateInToday(transfer.dateCreated!) {
                    tOutTransfer += transfer.moneyFlow
                }
                if calendar.isDate(now, equalTo: transfer.dateCreated!, toGranularity: .month) {
                    mOutTransfer += transfer.moneyFlow
                }
                if calendar.isDate(now, equalTo: transfer.dateCreated!, toGranularity: .weekdayOrdinal) {
                    wOutTransfer += transfer.moneyFlow
                }
            }
            else if transfer.accountTo == account {
                dateIsPresent(date: transfer.dateCreated!) ? (balance += transfer.moneyFlow) : ()
                //balance += transfer.moneyFlow
                allInTransfer += transfer.moneyFlow
                
                if calendar.isDateInToday(transfer.dateCreated!) {
                    tInTransfer += transfer.moneyFlow
                }
                if calendar.isDate(now, equalTo: transfer.dateCreated!, toGranularity: .month) {
                    mInTransfer += transfer.moneyFlow
                }
                if calendar.isDate(now, equalTo: transfer.dateCreated!, toGranularity: .weekdayOrdinal) {
                    wInTransfer += transfer.moneyFlow
                }
            }
        }
                

        values = Values(tIncome: tIncome,
                        tOutcome: tOutcome,
                        mIncome: mIncome,
                        mOutcome: mOutcome,
                        wIncome: wIncome,
                        wOutcome: wOutcome,
                        allIncome: allIncome,
                        allOutcome: allOutcome,
                        
                        tInTransfer: tInTransfer,
                        tOutTransfer: tOutTransfer,
                        mInTransfer: mInTransfer,
                        mOutTransfer: mOutTransfer,
                        wInTransfer: wInTransfer,
                        wOutTransfer: wOutTransfer,
                        allInTransfer: allInTransfer,
                        allOutTransfer: allOutTransfer,
                        
                        balance: balance)
    }
    
    
    func getBalance() -> Double {
        return values?.balance ?? 0.0
    }
    
    func getTComes() -> (tIncome: Double, tOutcome: Double) {
        return (values?.tIncome ?? 0.0, values?.tOutcome ?? 0.0)
    }
    
    func getMComes() -> (mIncome: Double, mOutcome: Double) {
        return (values?.mIncome ?? 0.0, values?.mOutcome ?? 0.0)
    }
    
    func getWComes() -> (wIncome: Double, wOutcome: Double) {
        return (values?.wIncome ?? 0.0, values?.wOutcome ?? 0.0)
    }
    
    func getAllComes() -> (allIncome: Double, allOutcome: Double) {
        return (values?.allIncome ?? 0.0, values?.allOutcome ?? 0.0)
    }
    
    
    
    
    func getTTransfers() -> (tInTransfer: Double, tOutTransfer: Double) {
        return (values?.tInTransfer ?? 0.0, values?.tOutTransfer ?? 0.0)
    }

    func getMTransfers() -> (mInTransfer: Double, mOutTransfer: Double) {
        return (values?.mInTransfer ?? 0.0, values?.mOutTransfer ?? 0.0)
    }

    func getWTransfers() -> (wInTransfer: Double, wOutTransfer: Double) {
        return (values?.wInTransfer ?? 0.0, values?.wOutTransfer ?? 0.0)
    }
    
    func getAllTransfers() -> (allInTransfer: Double, allOutTransfer: Double) {
        return (values?.allInTransfer ?? 0.0, values?.allOutTransfer ?? 0.0)
    }
    
    
    
    
    func dateIsPresent(date: Date) -> Bool {
        let now = Date()
        return date <= now ? true : false
    }
}
