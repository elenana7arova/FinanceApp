//
//  CustomButton.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 20.04.2021.
//

import UIKit

class RoundedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height/2
        self.tintColor = UIColor(named: "light_gray")
    }
    
    func setState(isActive: Bool) {
        if isActive {
            self.layer.shadowColor = UIColor(named: "medium_gray")!.cgColor
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
            self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
            self.layer.shadowOpacity = 0.55
            self.layer.shadowRadius = 4.5
            
            self.tintColor = UIColor(named: "dark_gray")
        }
        else {
            self.layer.shadowColor = UIColor.clear.cgColor
            
            self.tintColor = UIColor(named: "light_gray")
        }
    }
}



