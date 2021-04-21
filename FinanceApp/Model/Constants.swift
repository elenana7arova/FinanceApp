//
//  Constants.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 18.03.2021.
//

import Foundation
import RealmSwift

//let realm = try! Realm()

struct K {
    static let defaultCategory = realm.object(ofType: Category.self, forPrimaryKey: "3A483FE5-98A8-4B77-A5EC-A8C776D22472")
    static let defaultSource = realm.object(ofType: Category.self, forPrimaryKey: "DC2023E6-44B6-4768-8CB4-7FE403ED84E3")
    static let defaultAccount = realm.object(ofType: Account.self, forPrimaryKey: "893717BF-F210-4EDE-ABB2-94212C3A81C0")
    static let defaultAccountIfDeleted = realm.object(ofType: Account.self, forPrimaryKey: "3E4AD6DC-E5E8-4D3E-8D6C-9913CA487D4D")
    
    static let categoryColors: [[UIColor?]] = [[
        UIColor(named: "russian_red"),
        UIColor(named: "blue"),
        UIColor(named: "dark_blue"),
        UIColor(named: "pink"),
        UIColor(named: "lazur")], [
        UIColor(named: "yellow"),
        UIColor(named: "orange"),
        UIColor(named: "light_green"),
        UIColor(named: "violet"),
        UIColor(named: "dark_gray")
    ]]
}
