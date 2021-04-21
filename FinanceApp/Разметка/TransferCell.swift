//
//  TransferCell.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 31.03.2021.
//

import UIKit

class TransferCell: UITableViewCell {
    @IBOutlet weak var fromAccountLabel: UILabel!
    @IBOutlet weak var toAccountLabel: UILabel!
    @IBOutlet weak var moneyFlowLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
