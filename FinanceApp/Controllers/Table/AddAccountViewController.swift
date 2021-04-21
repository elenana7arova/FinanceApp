//
//  AddAccountViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 26.03.2021.
//

import UIKit
import RealmSwift

class AddAccountViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var accountNameTextfield: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    let realm = try! Realm()
    var accountToEdit: Account?
    var delegate: AccountViewControllerDelegate?
    
    var currentAccountIsEditing: Bool = false
    var chosenAccountIsGoingToBeEdited: Bool = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentAccountIsEditing {
            addButton.setTitle("Edit", for: .normal)
            if accountToEdit == K.defaultAccount {
                deleteButton.isHidden = true
            }
            else {
                deleteButton.isHidden = false
            }
            accountNameTextfield.text = accountToEdit?.accountName
        }
        else {
            addButton.setTitle("Add", for: .normal)
            deleteButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let newAccount = Account()
        newAccount.accountName = accountNameTextfield.text!
        newAccount.dateCreated = Date()
        
        if currentAccountIsEditing, let account = accountToEdit {
            newAccount.id = account.id
            newAccount.dateCreated = account.dateCreated
        }
        delegate?.save(account: newAccount)
        performSegue(withIdentifier: "goBackToAccountViewController", sender: "addButton")
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.delete(account: accountToEdit!)
        performSegue(withIdentifier: "goBackToAccountViewController", sender: "deleteButton")
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
            if touchPoint.y - initialTouchPoint.y > self.view.frame.size.height / 5 {
                self.performSegue(withIdentifier: "goBackToAccountViewController", sender: "cancelButton")
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
    
    // MARK: - Seques
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackToAccountViewController" {
            let previousVC = segue.destination as! AccountViewController
            if sender as! String == "deleteButton" && chosenAccountIsGoingToBeEdited {
                previousVC.isInvalidated = true
            }
        }
    }
}
