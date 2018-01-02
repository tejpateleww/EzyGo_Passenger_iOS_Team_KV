//
//  WalletCardsTableViewCell.swift
//  TiCKTOC-Driver
//
//  Created by Excelent iMac on 28/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class WalletCardsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        viewCards.layer.cornerRadius = 5
//        viewCards.layer.masksToBounds = true
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    // Section 0
    
    @IBOutlet weak var viewCards: UIView!
    
    @IBOutlet weak var imgCardIcon: UIImageView!
    
    @IBOutlet weak var lblBankName: UILabel!
    @IBOutlet weak var lblCardType: UILabel!
    @IBOutlet weak var lblCardNumber: UILabel!
    
    @IBOutlet weak var imgCard: UIImageView!
    
    // Section 1
    
    @IBOutlet weak var lblAddCard: UILabel!
    
    
    
}
