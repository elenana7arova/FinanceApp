//
//  AccountViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 26.03.2021.
//

import UIKit
import RealmSwift

protocol AccountViewControllerDelegate {
    func save(account: Account)
    func delete(account: Account)
}

class AccountViewController: UIViewController, AccountViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let realm = try! Realm()
    var accounts: Results<Account>?
    var chosenAccount: Account?
    var account: Account?
    
    enum AccountMode {
        case accountFrom, accountTo
    }
    var accountMode: AccountMode?
    var chosenAccountFrom: Account?
    var chosenAccountTo: Account?
    
    var currentAccountIsEditing = false
    var chosenAccountIsGoingToBeEdited: Bool = false
    var isInvalidated: Bool = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.bottom = 40
        loadAccounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if let navbar = navigationController?.navigationBar {
            navbar.backgroundColor = UIColor(named: "light_gray")
            navbar.backItem?.title = ""
            navbar.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 30) /* UIFontWeightRegular */
            ]
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isInvalidated {
            tableView.delegate?.tableView?(tableView, didSelectRowAt: [0,0])
        }
        
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        account = nil
        performSegue(withIdentifier: "goToAddAccountViewController", sender: self)
    }
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
        //back from here
    }
    
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        if sender.state == .began {
        let point = sender.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: point) {
                if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                    chosenAccountIsGoingToBeEdited = true
                }
                account = accounts?[indexPath.row]
                generator.impactOccurred()
                performSegue(withIdentifier: "goToAddAccountViewController", sender: self)
            }
        }
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
        cell.accountNameLabel.text = accounts?[indexPath.row].accountName
        
        if let parent = navigationController?.viewControllers.first as? AddItemViewController {
            if parent.chosenAccount == accounts?[indexPath.row] {
                cell.accessoryType = .checkmark
            }
        }
        
        if let parent = navigationController?.viewControllers.first as? AddTransferViewController {
            if parent.chosenAccountFrom == accounts?[indexPath.row], accountMode == .accountFrom {
                cell.accessoryType = .checkmark
            }
            else if parent.chosenAccountTo == accounts?[indexPath.row], accountMode == .accountTo {
                cell.accessoryType = .checkmark
            }
        }
        
        if isInvalidated {
            indexPath == [0,0] ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenAccount = accounts?[indexPath.row]
        performSegue(withIdentifier: "goBackFromAccountViewController", sender: self)
    }
    
    // MARK: - REALM METHODS
    func loadAccounts() {
        accounts = realm.objects(Account.self).filter("id != %@", K.defaultAccountIfDeleted!.id).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func save(account: Account) {
        do {
            try realm.write {
                realm.create(Account.self, value: account, update: .modified)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    
    func delete(account: Account) {
        do {
            try realm.write {
                let items = realm.objects(Item.self).filter("isTransfer == false && account.id = %@", account.id)
                for item in items {
                    item.account = K.defaultAccountIfDeleted
                }
                let transfers = realm.objects(Item.self).filter("isTransfer == true")
                for transfer in transfers {
                    if transfer.accountFrom == account {
                        transfer.accountFrom = K.defaultAccountIfDeleted
                    }
                    if transfer.accountTo == account {
                        transfer.accountTo = K.defaultAccountIfDeleted
                    }
                }
                realm.delete(account)
            }
        }
        catch {
            print(error)
        }
        tableView.reloadData()
        if let parent = self.presentingViewController?.childViewControllerForPointerLock as? ItemViewController {
            parent.pagerView.delegate?.pagerView?(parent.pagerView, didSelectItemAt: 1)
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddAccountViewController" {
            let nextVC = segue.destination as! AddAccountViewController
            nextVC.delegate = self
            if let accountToEdit = account {
                currentAccountIsEditing = true
                nextVC.currentAccountIsEditing = currentAccountIsEditing
                nextVC.accountToEdit = accountToEdit
                nextVC.chosenAccountIsGoingToBeEdited = chosenAccountIsGoingToBeEdited
            }
        }
        
        if segue.identifier == "goBackFromAccountViewController" {
            if let previousVC = segue.destination as? AddItemViewController {
                previousVC.chosenAccount = chosenAccount
            }
            if let previousVC = segue.destination as? AddTransferViewController {
                if accountMode == .accountFrom {
                    previousVC.chosenAccountFrom = chosenAccount
                }
                else if accountMode == .accountTo {
                    previousVC.chosenAccountTo = chosenAccount
                }
            }
        }
        
    }

}
