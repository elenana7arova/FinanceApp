//
//  Extensions.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 15.04.2021.
//

import UIKit

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}

extension Array {
    var tail: Array {
        return Array(self.dropFirst())
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UserDefaults {
    func indexPath(forKey key: String) -> IndexPath? {
        guard let indexArray = array(forKey: key) as? [Int] else { return nil }
        return IndexPath(row: indexArray[0], section: indexArray[1])
    }

    func set(_ indexPath: IndexPath, forKey key: String) {
        set([indexPath.row, indexPath.section], forKey: key)
    }
}

extension UIColor {
    var name: String? {
        let str = String(describing: self).dropLast()
        guard let nameRange = str.range(of: "name = ") else {
            return nil
        }
        let cropped = str[nameRange.upperBound ..< str.endIndex]
        if cropped.isEmpty {
            return nil
        }
        return String(cropped)
    }
}
