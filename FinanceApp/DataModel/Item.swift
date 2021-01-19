//
//  DataModel.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 15.01.2021.
//
import Foundation
import RealmSwift

class Item: Object {
    //@objc dynamic var category: Category?
    @objc dynamic var name: String = ""
    @objc dynamic var moneyFlow: Double = 0.0
    @objc dynamic var dateCreated: Date? = nil
    @objc dynamic var isIncome: Bool = true
    
    convenience init(isIncome: Bool, moneyFlow: Double, name: String, /*category: Category?, */dateCreated: Date) {
        self.init()
        self.isIncome = isIncome
        self.moneyFlow = moneyFlow
        self.name = name
        //self.category = category
        self.dateCreated = dateCreated
    }
}
