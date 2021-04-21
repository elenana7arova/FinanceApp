//
//  AddCategoryViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 19.01.2021.
//

import UIKit
import RealmSwift
import ColorPickTip

class AddCategoryViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var categoryNameTextfield: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var colorButton: UIButton!
    
    let realm = try! Realm()
    var categoryToEdit: Category?
    var categoryToDelete: Category?
    var delegate: CategoryViewControllerDelegate?
    
    let colorPickTipVC = ColorPickTipController(palette: K.categoryColors, options: nil)
    var chosenColor: String?
    
    var isSource: Bool = true
    var currentCategoryIsEditing: Bool = false
    var chosenCategoryIsGoingToBeEdited: Bool = false
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentCategoryIsEditing {
            deleteButton.isHidden = false
            addButton.setTitle("Edit", for: .normal)
            categoryNameTextfield.text = categoryToEdit?.categoryName
        }
        else {
            deleteButton.isHidden = true
            addButton.setTitle("Add", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        if isSource {
            addButton.backgroundColor = UIColor(named: "green")
        }
        else {
            addButton.backgroundColor = UIColor(named: "red")
        }
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let newCategory = Category()
        newCategory.categoryName = categoryNameTextfield.text!
        newCategory.dateCreated = Date()
        newCategory.isSource = isSource
        newCategory.color = chosenColor ?? "dark_gray"
        
        if currentCategoryIsEditing, let category = categoryToEdit {
            newCategory.id = category.id
            newCategory.dateCreated = category.dateCreated
        }
        delegate?.save(category: newCategory)
        performSegue(withIdentifier: "goBackToCategoryViewController", sender: "addButton")
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.delete(category: categoryToEdit!)
        performSegue(withIdentifier: "goBackToCategoryViewController", sender: "deleteButton")
    }
    
    @IBAction func chooseColorPressed(_ sender: UIButton) {
        colorPickTipVC.popoverPresentationController?.delegate = colorPickTipVC
        colorPickTipVC.popoverPresentationController?.sourceView = sender  // some UIButton
        colorPickTipVC.popoverPresentationController?.sourceRect = sender.bounds
        self.present(colorPickTipVC, animated: true, completion: nil)
        colorPickTipVC.selected = {
            color, index in
            self.chosenColor = color?.name
            guard color != nil else {return}
            self.colorButton.backgroundColor = color
        }
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
                self.performSegue(withIdentifier: "goBackToCategoryViewController", sender: "tableViewRow")
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
        // cancel
    }

    // MARK: - Seques
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackToCategoryViewController" {
            let previousVC = segue.destination as! CategoryViewController
            if sender as! String == "deleteButton" && chosenCategoryIsGoingToBeEdited {
                previousVC.isInvalidated = true
            }
            
        }
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
