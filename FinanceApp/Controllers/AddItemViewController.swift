//
//  AddViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 16.01.2021.
//

import UIKit
import RealmSwift

class AddItemViewController: UIViewController {
    @IBOutlet weak var valueTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var chooseInOut: UISegmentedControl!
    @IBOutlet weak var categoryLabel: UILabel!
    
    let realm = try! Realm()
    var delegate: RealmMethodsDelegate?
    
    private var isIncome: Bool = true
    var symbol: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.5399025535, green: 0.6090398423, blue: 0.4922998214, alpha: 1)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.view.backgroundColor = #colorLiteral(red: 0.5399025535, green: 0.6090398423, blue: 0.4922998214, alpha: 1)
            isIncome = true
            symbol = "+"
        }
        else {
            self.view.backgroundColor = #colorLiteral(red: 0.668336181, green: 0.4221193506, blue: 0.51485036, alpha: 1)
            isIncome = false
            symbol = "-"
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        var moneyFlow: Double {
            return Double(valueTextfield.text!)!
        }
        
        let newItem = Item(isIncome: isIncome, moneyFlow: moneyFlow, name: nameTextfield.text!, dateCreated: datePicker.date)

        delegate?.save(item: newItem)
        self.dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


