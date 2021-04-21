//
//  ViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 15.01.2021.
//

import UIKit
import RealmSwift
import FSPagerView

protocol ItemViewControllerDelegate {
    func save(item: Item)
    func delete(item: Item)
}

class ItemViewController: UIViewController, ItemViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Variables
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    @IBOutlet weak var addButton: RoundedButton!
    @IBOutlet weak var transferButton: RoundedButton!
    @IBOutlet weak var balanceLabel: UILabel!

    @IBOutlet weak var periodButton: UIButton!
    
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var thisIncomeLabel: UILabel!
    @IBOutlet weak var thisOutcomeLabel: UILabel!
    @IBOutlet weak var transfersView: UIView!
    @IBOutlet weak var thisInTransferLabel: UILabel!
    @IBOutlet weak var thisOutTransferLabel: UILabel!
    
    let realm = try! Realm()
    var item: Item?
    var transfer: Item?
    var items: Results<Item>?
    
    var accountToShow: Account?
    
    var currentItemIsEditing = false
    var currentTransferIsEditing = false
    var transferIsActive = false
//        : Bool! {
//        didSet {
//            transferIsActive = realm.objects(Account.self).count > 2 ? true : false
//            transferButton.setState(isActive: transferIsActive)
//        }
//    }
    
    var appCalculations = AppCalculations()
    
    let currency = " rub"
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    
    
    var balance: Double = 0.0 { didSet { balanceLabel.text = balance.formattedWithSeparator + currency } }
    var periodTypeString: String = "Today" { didSet { periodLabel.text = periodTypeString } }
    var periodIncome: Double = 0.0 { didSet { thisIncomeLabel.text = periodIncome.formattedWithSeparator + currency } }
    var periodOutcome: Double = 0.0 { didSet { thisOutcomeLabel.text = abs(periodOutcome).formattedWithSeparator + currency } }
    
    var periodInTransfer: Double = 0.0 { didSet { thisInTransferLabel.text = abs(periodInTransfer).formattedWithSeparator + currency } }
    var periodOutTransfer: Double = 0.0 { didSet { thisOutTransferLabel.text = abs(periodOutTransfer).formattedWithSeparator + currency } }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.bottom = 40
        // registering TransferCell.xib
        let nib = UINib(nibName: "TransferCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TransferCell")
        // pagerView main settings
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.decelerationDistance = FSPagerView.automaticDistance //!
        // dynamic width and space
        periodLabel.sizeToFit()
        periodButton.frame.size.width = periodLabel.frame.width + 30
        
        loadItems()
        
        transferButton.setState(isActive: (realm.objects(Account.self).count > 2 ? true : false))
        //print(Realm.Configuration.defaultConfiguration.fileURL!.path)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addButton.setState(isActive: true)
    }

    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: RoundedButton) {
        item = nil
        performSegue(withIdentifier: "goToAddItemViewController", sender: self)
    }
    
    @IBAction func addTransferPressed(_ sender: RoundedButton) {
        if realm.objects(Account.self).count > 2 {
            item = nil
            performSegue(withIdentifier: "goToAddTransferViewController", sender: self)
        }
        else {
            let alert = UIAlertController(title: "You can't make transfers with one account.", message: "", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
        // return back
    }
    
    @IBAction func choosePeriodPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let today = UIAlertAction(title: "Today", style: .default) { [self] (action1) in
            periodTypeString = appCalculations.setMode(mode: .today)
            self.viewDidLoad()
        }
        let thisWeek = UIAlertAction(title: "This week", style: .default) { [self] (action2) in
            periodTypeString = appCalculations.setMode(mode: .weekly)
            self.viewDidLoad()
        }
        let thisMonth = UIAlertAction(title: "This month", style: .default) { [self] (action3) in
            periodTypeString = appCalculations.setMode(mode: .monthly)
            self.viewDidLoad()
        }
        let allTime = UIAlertAction(title: "All time", style: .default) { [self] (action4) in
            periodTypeString = appCalculations.setMode(mode: .allTime)
            self.viewDidLoad()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(today)
        alert.addAction(thisWeek)
        alert.addAction(thisMonth)
        alert.addAction(allTime)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dateFormatter.dateFormat = "dd MMMM yyyy"
        if let current = items?[indexPath.row] {
            if !current.isTransfer {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
                var symbol: String {
                    if current.isIncome {
                        cell.moneyFlowLabel.textColor = UIColor(named: "green")
                        return "+ "
                    }
                    else {
                        cell.moneyFlowLabel.textColor = UIColor(named: "red")
                        return "- "
                    }
                }
                cell.categoryLabel.text = current.category?.categoryName
                cell.categoryLabel.textColor = UIColor(named: (current.category?.color)!)
                cell.accountLabel.text = current.account?.accountName
                cell.nameLabel.text = current.name
                cell.moneyFlowLabel.text = symbol + current.moneyFlow.formattedWithSeparator + currency
                cell.dateLabel.text = dateFormatter.string(from: current.dateCreated!)
                
                //dateIsFuture(check: current.dateCreated!, in: cell, now: nowDate)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TransferCell", for: indexPath) as! TransferCell
                cell.dateLabel.text = dateFormatter.string(from: current.dateCreated!)
                if accountToShow == current.accountFrom {
                    cell.moneyFlowLabel.text = "- " + current.moneyFlow.formattedWithSeparator + currency
                    cell.toAccountLabel.textColor = UIColor(named: "medium_gray")
                    cell.fromAccountLabel.textColor = UIColor(named: "dark_gray")
                }
                else if accountToShow == current.accountTo {
                    cell.moneyFlowLabel.text = "+ " + current.moneyFlow.formattedWithSeparator + currency
                    cell.fromAccountLabel.textColor = UIColor(named: "medium_gray")
                    cell.toAccountLabel.textColor = UIColor(named: "dark_gray")
                }
                else {
                    cell.moneyFlowLabel.text = current.moneyFlow.formattedWithSeparator + currency
                    cell.fromAccountLabel.textColor = UIColor(named: "dark_gray")
                    cell.toAccountLabel.textColor = UIColor(named: "dark_gray")
                }
                cell.fromAccountLabel.text = current.accountFrom?.accountName
                cell.toAccountLabel.text = current.accountTo?.accountName
                //dateIsFuture(check: current.dateCreated!, in: cell, now: nowDate)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        item = items?[indexPath.row]
        if !item!.isTransfer {
            performSegue(withIdentifier: "goToAddItemViewController", sender: self)
        }
        else {
            performSegue(withIdentifier: "goToAddTransferViewController", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    // MARK: - REALM METHODS
    func loadItems() {
        if let account = accountToShow {
            //items = realm.objects(Item.self).filter("account.id = %@", account.id).sorted(byKeyPath: "dateCreated", ascending: false)
            items = realm.objects(Item.self).filter(
                "account.id = %@ || accountFrom.id = %@ || accountTo.id = %@",
                account.id, account.id, account.id).sorted(byKeyPath: "dateCreated", ascending: false)
            transfersView.isHidden = false
        }
        else {
            items = realm.objects(Item.self).sorted(byKeyPath: "dateCreated", ascending: false)
            transfersView.isHidden = true
        }
        setValues()
        tableView.reloadData()
    }
    
    
    func save(item: Item) {
        do {
            try realm.write {
                realm.create(Item.self, value: item, update: .modified)
            }
        }
        catch {
            print(error)
        }
        
        setValues()
        tableView.reloadData()
    }
    
    func delete(item: Item) {
        do {
            try realm.write {
                realm.delete(item)
            }
        }
        catch {
            print(error)
        }
        setValues()
        tableView.reloadData()
    }
    
    
    // MARK: - Some logic from AppCalculations.swift
    func setValues() {
        appCalculations.periodValues(for: accountToShow)
        
        balance = appCalculations.getBalance()
        
        switch periodTypeString {
        case appCalculations.setMode(mode: .today):
            periodIncome = appCalculations.getTComes().tIncome
            periodOutcome = appCalculations.getTComes().tOutcome
            periodInTransfer = appCalculations.getTTransfers().tInTransfer
            periodOutTransfer = appCalculations.getTTransfers().tOutTransfer
        case appCalculations.setMode(mode: .weekly):
            periodIncome = appCalculations.getWComes().wIncome
            periodOutcome = appCalculations.getWComes().wOutcome
            periodInTransfer = appCalculations.getWTransfers().wInTransfer
            periodOutTransfer = appCalculations.getWTransfers().wOutTransfer
        case appCalculations.setMode(mode: .monthly):
            periodIncome = appCalculations.getMComes().mIncome
            periodOutcome = appCalculations.getMComes().mOutcome
            periodInTransfer = appCalculations.getMTransfers().mInTransfer
            periodOutTransfer = appCalculations.getMTransfers().mOutTransfer
        case appCalculations.setMode(mode: .allTime):
            periodIncome = appCalculations.getAllComes().allIncome
            periodOutcome = appCalculations.getAllComes().allOutcome
            periodInTransfer = appCalculations.getAllTransfers().allInTransfer
            periodOutTransfer = appCalculations.getAllTransfers().allOutTransfer
        default: break
        }
    }
    
    @objc func dateIsFuture(check date: Date, in cell: UITableViewCell, now: Date) {
        cell.contentView.layer.opacity = (date >= now) ? 0.37 : 1
    }

    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddItemViewController" {
            if let nav = segue.destination as? UINavigationController {
                let nextVC = nav.topViewController as! AddItemViewController
                nextVC.delegate = self
                nextVC.accountPreChosen = accountToShow
                if let itemToEdit = item {
                    currentItemIsEditing = true
                    nextVC.currentItemIsEditing = currentItemIsEditing
                    nextVC.itemToEdit = itemToEdit
                }
            }
        }
        
        if segue.identifier == "goToAddTransferViewController" {
            if let nav = segue.destination as? UINavigationController {
                let nextVC = nav.topViewController as! AddTransferViewController
                nextVC.delegate = self
                nextVC.accountFromPreChosen = accountToShow
                if let transferToEdit = item {
                    currentTransferIsEditing = true
                    nextVC.currentTransferIsEditing = currentTransferIsEditing
                    nextVC.transferToEdit = transferToEdit
                }
            }
        }
    }
    
}

// MARK: - FSPagerViewDelegate, FSPagerViewDataSource
extension ItemViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        let accounts = realm.objects(Account.self).filter("id != %@", K.defaultAccountIfDeleted!.id)
        return accounts.count + 1
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) 
        let accounts = realm.objects(Account.self).filter("id != %@", K.defaultAccountIfDeleted!.id).sorted(byKeyPath: "dateCreated", ascending: true)
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.clipsToBounds = true
    
        if index == 0 {
            cell.imageView!.image = UIImage(named: "cards_image")!
            cell.textLabel!.text = ""
            cell.textLabel?.superview?.backgroundColor = .none
        }
        else {
            cell.imageView!.image = UIImage(named: "card_image")!
            cell.textLabel!.text = accounts[index-1].accountName
            cell.textLabel?.superview?.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.4)
        }
        return cell
    }
    
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        setAccountToShow(index: index)
        self.viewDidLoad()
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        setAccountToShow(index: targetIndex)
    }
    
   func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        self.viewDidLoad()
   }
    
    func setAccountToShow(index: Int) {
        let accounts = realm.objects(Account.self).filter("id != %@", K.defaultAccountIfDeleted!.id).sorted(byKeyPath: "dateCreated", ascending: true)
        if index == 0 {
            accountToShow = nil
        }
        else {
            accountToShow = accounts[index-1]
        }
    }
    
    func setIndexOfAccount(for account: Account?) {
        let numberOfItems = pagerView.dataSource?.numberOfItems(in: pagerView)
        for i in 0..<numberOfItems! {
            let cell = pagerView.cellForItem(at: i)
            if cell?.textLabel?.text == account?.accountName {
                pagerView.delegate?.pagerView?(pagerView, didSelectItemAt: i)
            }
        }
       
    }
    
    
}

