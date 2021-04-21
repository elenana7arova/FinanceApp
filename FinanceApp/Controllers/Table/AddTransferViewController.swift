//
//  AddTransferController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 30.03.2021.
//

import UIKit
import RealmSwift

class AddTransferViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var valueTextfield: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var fromAccountLabel: UILabel!
    @IBOutlet weak var toAccountLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    let realm = try! Realm()
    var delegate: ItemViewControllerDelegate?
    var chosenAccountFrom: Account?
    var chosenAccountTo: Account?
    
    var transferToEdit: Item!
    var currentTransferIsEditing: Bool = false
    
    var accountFromPreChosen: Account?

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        valueTextfield.keyboardType = .decimalPad
        self.hideKeyboardWhenTappedAround()
        if currentTransferIsEditing {
            deleteButton.isHidden = false
            addButton.setTitle("Edit", for: .normal)
            chosenAccountFrom = transferToEdit?.accountFrom
            chosenAccountTo = transferToEdit?.accountTo
        }
        else {
            deleteButton.isHidden = true
            addButton.setTitle("Add", for: .normal)
            chosenAccountFrom = K.defaultAccount
            chosenAccountTo = /*K.defaultAccount*/ realm.objects(Account.self).filter("id != %@ && id != %@", chosenAccountFrom!.id, K.defaultAccountIfDeleted!.id).first
        }

        if accountFromPreChosen != nil{
            chosenAccountFrom = accountFromPreChosen
            chosenAccountTo = /*K.defaultAccount*/ realm.objects(Account.self).filter("id != %@ && id != %@", chosenAccountFrom!.id, K.defaultAccountIfDeleted!.id).first
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if currentTransferIsEditing {
            valueTextfield.text = String(transferToEdit.moneyFlow)
            datePicker.date = transferToEdit.dateCreated!
            if let parent = self.presentingViewController?.childViewControllerForPointerLock as? ItemViewController {
                parent.tableView.reloadData()
            }
        }
        fromAccountLabel.text = chosenAccountFrom?.accountName
        toAccountLabel.text = chosenAccountTo?.accountName
    }

    // MARK: - IBActions
    @IBAction func chooseFromAccount(_ sender: UIButton) {
        performSegue(withIdentifier: "goToAccountViewController", sender: "from")
    }
    
    @IBAction func chooseToAccount(_ sender: UIButton) {
        performSegue(withIdentifier: "goToAccountViewController", sender: "to")
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        var moneyFlow: Double {
            if valueTextfield.text!.contains(",") {
                return Double(valueTextfield.text!.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            }
            return Double(valueTextfield.text!) ?? 0.0
        }
        
        let newTransfer = Item(
                               isTransfer: true,
                               moneyFlow: moneyFlow,
                               accountFrom: chosenAccountFrom,
                               accountTo: chosenAccountTo,
                               dateCreated: datePicker.date)

        if currentTransferIsEditing {
            newTransfer.id = transferToEdit.id
        }
        if newTransfer.accountFrom == newTransfer.accountTo {
            let alert = UIAlertController(title: "You should choose different accounts.", message: "", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            delegate?.save(item: newTransfer)
            performSegue(withIdentifier: "goBackToItemViewController", sender: "addButton")
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.delete(item: transferToEdit)
        performSegue(withIdentifier: "goBackToItemViewController", sender: "deleteButton")
    }
    
    @IBAction func changeAccountsButtonPressed(_ sender: UIButton) {
        swap(&chosenAccountFrom, &chosenAccountTo)
        self.viewWillAppear(true)
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
                self.performSegue(withIdentifier: "goBackToItemViewController", sender: "tableViewRow")
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
        // return back
    }
    
    // MARK: - Seques
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAccountViewController" {
            let nextVC = segue.destination as! AccountViewController
            if sender as! String == "from" {
                nextVC.accountMode = .accountFrom
            }
            else if sender as! String == "to" {
                nextVC.accountMode = .accountTo
            }
        }
        
        if segue.identifier == "goBackToItemViewController" {
            let previousVC = segue.destination as! ItemViewController
            if sender as! String == "addButton" {
                previousVC.setIndexOfAccount(for: chosenAccountTo)
            }
            //previousVC.transferIsActive = (realm.objects(Account.self).count > 2) ? true : false
            previousVC.transferButton.setState(isActive: ((realm.objects(Account.self).count > 2) ? true : false))
            previousVC.pagerView.reloadData()
        }
    }
    
}
