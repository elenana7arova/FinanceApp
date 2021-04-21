//
//  TabBarController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 25.02.2021.
//

import UIKit

class TabBarController: UITabBarController {
    
    @IBOutlet weak var uiTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(
            roundedRect: CGRect(
                x: 23,
                y: self.tabBar.bounds.minY - 20,
                width: self.tabBar.bounds.width - 45,
                height: self.tabBar.bounds.height + 30
            ),
            cornerRadius: (self.tabBar.frame.width / 2)
        ).cgPath
        
        // shadow
        layer.shadowColor = UIColor(named: "medium_gray")!.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.8
        
        // other
        layer.borderWidth = 1.0
        layer.opacity = 1.0
        layer.isHidden = false
        layer.masksToBounds = false
        layer.fillColor = UIColor(named: "light_gray")!.cgColor
        
        self.tabBar.layer.insertSublayer(layer, at: 0)
        
        if let items = self.tabBar.items {
            items.forEach { item in item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -15, right: 0) }
        }

        self.tabBar.itemWidth = 30.0
        //self.tabBar.itemPositioning = .centered
        
        self.selectedIndex = 1 // 5th tab
    }
    
}

