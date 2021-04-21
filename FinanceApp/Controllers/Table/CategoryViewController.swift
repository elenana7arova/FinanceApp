//
//  CategoryViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 19.01.2021.
//

import UIKit
import RealmSwift

protocol CategoryViewControllerDelegate {
    func save(category: Category)
    func delete(category: Category)
}

class CategoryViewController: UIViewController, CategoryViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let realm = try! Realm()
    var categories: Results<Category>?
    var chosenCategory: Category? // chosen by clicking the row

    var category: Category? // chosen by long pressed to be edit or delete
    
    var categoryToDelete: Category?
    
    var currentCategoryIsEditing = false
    var chosenCategoryIsGoingToBeEdited = false
    var isSource: Bool = true
    var isInvalidated: Bool = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.bottom = 40
        loadCategories()
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
            
            if isSource {
                addButton.tintColor = UIColor(named: "green")
                //chosenCategory = K.defaultSource
            }
            else {
                addButton.tintColor = UIColor(named: "red")
                //chosenCategory = K.defaultCategory
            }
            
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isInvalidated {
            tableView.delegate?.tableView?(tableView, didSelectRowAt: [0,0])
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        category = nil
        performSegue(withIdentifier: "goToAddCategoryViewController", sender: "addButton")
    }
    
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
    }
    
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        let errorGenerator = UINotificationFeedbackGenerator()
        if sender.state == .began {
        let point = sender.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: point) {
                if indexPath == [0,0] {
                    errorGenerator.notificationOccurred(.error)
                    let alert = UIAlertController(title: "You cannot edit or delete it.", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                        chosenCategoryIsGoingToBeEdited = true
                    }
                    category = categories?[indexPath.row]
                    generator.impactOccurred()
                    performSegue(withIdentifier: "goToAddCategoryViewController", sender: self)
                }
            }
        }
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.categoryNameLabel.text = categories?[indexPath.row].categoryName
        cell.categoryNameLabel.textColor = UIColor(named: (categories?[indexPath.row].color)!) 
        
        if let parent = navigationController?.viewControllers.first as? AddItemViewController {
            if parent.chosenCategory == categories?[indexPath.row] {
                cell.accessoryType = .checkmark
            }
            
            if isInvalidated {
                indexPath == [0,0] ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenCategory = categories?[indexPath.row]
        performSegue(withIdentifier: "goBackToAddItemViewController", sender: "tableViewCell")
    }
    
    // MARK: - REALM METHODS
    func loadCategories() {
        if isSource {
            categories = realm.objects(Category.self).filter("isSource == true").sorted(byKeyPath: "dateCreated", ascending: true)
        }
        else {
            categories = realm.objects(Category.self).filter("isSource == false").sorted(byKeyPath: "dateCreated", ascending: true)
        }
        tableView.reloadData()
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.create(Category.self, value: category, update: .modified)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    func delete(category: Category) {
        do {
            try realm.write {
                let items = realm.objects(Item.self).filter("category.id = %@", category.id)
                for item in items {
                    item.isIncome ? (item.category = K.defaultSource) : (item.category = K.defaultCategory)
                }
                realm.delete(category)
            }
        }
        catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddCategoryViewController" {
            let nextVC = segue.destination as! AddCategoryViewController
            nextVC.delegate = self
            nextVC.isSource = isSource
            if let categoryToEdit = category {
                currentCategoryIsEditing = true
                nextVC.currentCategoryIsEditing = currentCategoryIsEditing
                nextVC.categoryToEdit = categoryToEdit
                nextVC.chosenCategoryIsGoingToBeEdited = chosenCategoryIsGoingToBeEdited
            }
        }
        if segue.identifier == "goBackToAddItemViewController" {
            let previousVC = segue.destination as! AddItemViewController
            previousVC.chosenCategory = chosenCategory
        }
    }
    
}



