//
//  ContentTableViewCell.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}





protocol ContactSupportDelegate {
    func OpenTermsOfUse()
    func OpenPrivacyPolicy()
    func OpenContactUs()
}


class ContactTblCell: UITableViewCell {
    
    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var SubMenu: UIView!
    
    
    var Delegate:ContactSupportDelegate!
    
    @IBAction func btnTermAction(_ sender: Any) {
        self.Delegate.OpenTermsOfUse()
        
    }
    
    @IBAction func btnPrivacyPolicyAction(_ sender: Any) {
        self.Delegate.OpenPrivacyPolicy()
        
    }
    
    @IBAction func btnContactUsAction(_ sender: Any) {
        self.Delegate.OpenContactUs()
        
    }
    
    
}
