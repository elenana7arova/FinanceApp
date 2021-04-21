//
//  Account.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 26.03.2021.
//

import Foundation
import RealmSwift

class Account: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var accountName: String = ""
    @objc dynamic var dateCreated: Date? = nil
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
