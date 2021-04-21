//
//  Category.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 19.01.2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var id = NSUUID().uuidString 
    @objc dynamic var categoryName: String = ""
    @objc dynamic var dateCreated: Date? = nil
    @objc dynamic var isSource: Bool = true
    @objc dynamic var color: String = "dark_gray"
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
