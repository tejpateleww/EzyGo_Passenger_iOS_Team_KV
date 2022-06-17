//
//  FavLocationTableViewCell.swift
//  EZYGO Rider
//
//  Created by EWW-iMac Old on 23/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class PromoCreditTableViewCell: UITableViewCell {
   
    @IBOutlet weak var lblBenefit: UILabel!
    @IBOutlet weak var lblExpiryDate: UILabel!
    @IBOutlet weak var lblPromoCode: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
