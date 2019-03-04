//
//  FavrouiteTableViewCell.swift
//  EZYGO Rider
//
//  Created by EWW-iMac Old on 18/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

protocol AddFavouriteLocationDelegate {
    func AddFavouriteLocation(CustomCell:UITableViewCell)
}

class FavrouiteTableViewCell: UITableViewCell {

    @IBOutlet weak var imgLogo: UIImageView!
    
    @IBOutlet weak var lblFavName: UILabel!
    
    var Delegate:AddFavouriteLocationDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btnFavourite(_ sender: Any) {
        
        self.Delegate.AddFavouriteLocation(CustomCell: self)
        
    }
    
}
