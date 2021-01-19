//
//  Category.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 19.01.2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var categoryName: String = ""
    @objc dynamic var dateCreated: Date? = nil
    let categoryItems = List<Item>()
}
