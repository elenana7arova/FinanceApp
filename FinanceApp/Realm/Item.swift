//
//  DataModel.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 15.01.2021.
//
import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var isTransfer: Bool = false
    @objc dynamic var dateCreated: Date? = nil
    @objc dynamic var moneyFlow: Double = 0.0
   
    @objc dynamic var category: Category?
    @objc dynamic var account: Account?
    @objc dynamic var name: String = ""
    @objc dynamic var isIncome: Bool = true
    
    @objc dynamic var accountFrom: Account?
    @objc dynamic var accountTo: Account?
    
    
    convenience init(isTransfer: Bool, isIncome: Bool, moneyFlow: Double, name: String, category: Category?, account: Account?, dateCreated: Date) {
        self.init()
        self.isTransfer = isTransfer
        self.isIncome = isIncome
        self.moneyFlow = moneyFlow
        self.name = name
        self.category = category
        self.account = account
        self.dateCreated = dateCreated
    }
    
    convenience init(isTransfer: Bool, moneyFlow: Double, accountFrom: Account?, accountTo: Account?, dateCreated: Date) {
        self.init()
        self.isTransfer = isTransfer
        self.moneyFlow = moneyFlow
        self.accountFrom = accountFrom
        self.accountTo = accountTo
        self.dateCreated = dateCreated
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
