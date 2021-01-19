//
//  ViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 15.01.2021.
//

import UIKit
import RealmSwift

protocol RealmMethodsDelegate {
    func save(item: Item)
}

class MainViewController: UIViewController, RealmMethodsDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    let realm = try! Realm()
    var items: Results<Item>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        loadItems()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddItemViewController" {
            let vc = segue.destination as! AddItemViewController
            vc.delegate = self
        }
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if let currentItem = items?[indexPath.row] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            var symbol: String {
                if currentItem.isIncome {
                    cell.backgroundColor = #colorLiteral(red: 0.5399025535, green: 0.6090398423, blue: 0.4922998214, alpha: 1)
                    return "+"
                }
                else {
                    cell.backgroundColor = #colorLiteral(red: 0.668336181, green: 0.4221193506, blue: 0.51485036, alpha: 1)
                    return "-"
                }
            }
            //cell.categoryLabel.text = currentItem.category
            cell.nameLabel.text = currentItem.name
            cell.moneyFlowLabel.text = symbol + String(currentItem.moneyFlow)
            cell.dateLabel.text = dateFormatter.string(from: currentItem.dateCreated!)
        }
        
        return cell
    }
    // MARK: - REALM METHODS
    func loadItems() {
        items = realm.objects(Item.self).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    func save(item: Item) {
        do {
            try realm.write {
                realm.add(item)
            }
        }
        catch {
            print(error)
        }
        print(item)
        tableView.reloadData()
    }
}

