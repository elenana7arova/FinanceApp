//
//  AddViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 16.01.2021.
//

import UIKit
import RealmSwift

class AddItemViewController: UIViewController {
    
    // MARK: - Variables
    @IBOutlet weak var valueTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var chooseInOut: UISegmentedControl!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var sourceOrCategoryLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var chooseAccountButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    let realm = try! Realm()
    var delegate: ItemViewControllerDelegate?
    var chosenCategory: Category?
    var chosenAccount: Account?
    var itemToEdit: Item!
    
    var currentItemIsEditing: Bool = false
    private var isIncome: Bool = true
    private var symbol: String = ""
    
    var accountPreChosen: Account?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        valueTextfield.keyboardType = .decimalPad
        self.hideKeyboardWhenTappedAround()
        defaults.set(true, forKey: "isIncome")
        if currentItemIsEditing {
            deleteButton.isHidden = false
            //chooseAccountButton.isHidden = false
            addButton.setTitle("Edit", for: .normal)
            itemToEdit.isIncome ? (chooseInOut.selectedSegmentIndex = 0) : (chooseInOut.selectedSegmentIndex = 1)
            segmentedControlChanged(chooseInOut)
            chosenCategory = itemToEdit?.category
            chosenAccount = itemToEdit?.account
        }
        else {
            deleteButton.isHidden = true
            addButton.setTitle("Add", for: .normal)
            defaults.bool(forKey: "isIncome") ? (chosenCategory = K.defaultSource) : (chosenCategory = K.defaultCategory)
            chosenAccount = K.defaultAccount
            
        }
        
        if accountPreChosen != nil {
            chosenAccount = accountPreChosen
            //chooseAccountButton.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if currentItemIsEditing {
            valueTextfield.text = String(itemToEdit.moneyFlow)
            nameTextfield.text = itemToEdit.name
            datePicker.date = itemToEdit.dateCreated!
            if let parent = self.presentingViewController?.childViewControllerForPointerLock as? ItemViewController {
                parent.tableView.reloadData()
                parent.pagerView.reloadData()
            }
        }
        categoryLabel.text = chosenCategory?.categoryName
        accountLabel.text = chosenAccount?.accountName 
    }
    
    
    // MARK: - IBActions
    @IBAction func chooseCategoryPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCategoryViewController", sender: "chooseCategory")
    }
    
    @IBAction func chooseAccountPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToAccountViewController", sender: "chooseAccount")
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isIncome = true
            defaults.set(true, forKey: "isIncome")
            sourceOrCategoryLabel.text = "Source"
            categoryLabel.text = K.defaultSource?.categoryName
            chosenCategory = K.defaultSource
            addButton.backgroundColor = UIColor(named: "green")
            symbol = "+"
        }
        else {
            isIncome = false
            defaults.set(false, forKey: "isIncome")
            sourceOrCategoryLabel.text = "Category"
            categoryLabel.text = K.defaultCategory?.categoryName
            chosenCategory = K.defaultCategory
            addButton.backgroundColor = UIColor(named: "red")
            symbol = "-"
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        var moneyFlow: Double {
            if valueTextfield.text!.contains(",") {
                return Double(valueTextfield.text!.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            }
            return Double(valueTextfield.text!) ?? 0.0
        }
        
        let newItem = Item(
                           isTransfer: false,
                           isIncome: isIncome,
                           moneyFlow: moneyFlow,
                           name: nameTextfield.text!,
                           category: chosenCategory,
                           account: chosenAccount,
                           dateCreated: datePicker.date)

        if currentItemIsEditing {
            newItem.id = itemToEdit.id
        }
        delegate?.save(item: newItem)
        performSegue(withIdentifier: "goBackToItemViewController", sender: "addButton")
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.delete(item: itemToEdit)
        performSegue(withIdentifier: "goBackToItemViewController", sender: "deleteButton")
    }
    
    // swipe down to hide the pop-up
    var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    @IBAction func cancelSwiped(_ sender: UIPanGestureRecognizer) {
        guard sender.view != nil else { return }
        let touchPoint = sender.location(in: self.view?.window)
        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        }
        else if sender.state == UIGestureRecognizer.State.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(
                    x: 0,
                    y: touchPoint.y - initialTouchPoint.y,
                    width: self.view.frame.size.width,
                    height: self.view.frame.size.height
                )
            }
        }
        else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
            if touchPoint.y - initialTouchPoint.y > self.view.frame.size.height / 3.5 {
                self.performSegue(withIdentifier: "goBackToItemViewController", sender: "cancelButton")
            }
            else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(
                        x: 0,
                        y: 0,
                        width: self.view.frame.size.width,
                        height: self.view.frame.size.height
                    )
                })
            }
        }
    }
    
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCategoryViewController" {
            let nextVC = segue.destination as! CategoryViewController
            nextVC.isSource = isIncome
            if isIncome {
                nextVC.title = "Sources"
            }
            else {
                nextVC.title = "Categories"
            }
        }
        
        if segue.identifier == "goToAccountViewController" {
            let nextVC = segue.destination as! AccountViewController
        }
        
        if segue.identifier == "goBackToItemViewController" {
            let previousVC = segue.destination as! ItemViewController
            //if sender as! String != "cancelButton" {
            
            if sender as! String == "addButton" {
                previousVC.setIndexOfAccount(for: chosenAccount)
                //delegate?.setIndexOfAccount(for: chosenAccount)
            }
            previousVC.pagerView.reloadData()
        }
        
    }
}

// MARK: - Extension for keyboard
extension AddItemViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

