//
//  MyRatingTableViewCell.swift
//  EZYGO Rider
//
//  Created by EWW-iMac Old on 24/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class MyRatingTableViewCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblRideDate: UILabel!
    @IBOutlet weak var RatingView: FloatRatingView!
    @IBOutlet weak var lblFromLocation: UILabel!
    @IBOutlet weak var lblToLocation: UILabel!
    @IBOutlet weak var lblCommentTitle: UILabel!
    @IBOutlet weak var lblCommentDetail: UILabel!
    @IBOutlet weak var lblBookingID: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
