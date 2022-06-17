//
//  MyRecepitTableViewCell.swift
//  TickTok User
//
//  Created by Excelent iMac on 13/12/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

protocol ReceiptInvoiceDelegate {
    func didGetReceipt(customCell:UITableViewCell)
    func didViewReceipt(customCell:UITableViewCell)
    
}

class MyRecepitTableViewCell: UITableViewCell {

    var Delegate:ReceiptInvoiceDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    
    @IBOutlet weak var viewDetails: UIView!
    
    @IBOutlet var lblDriversNames: UILabel!
    @IBOutlet weak var btnGetReceipt: UIButton!
    
    @IBOutlet var lblDropLocationDescription: UILabel!
    @IBOutlet var lblDateAndTime: UILabel!
    @IBOutlet var lblPickUpLocationDescription: UILabel!
    
    @IBOutlet weak var lblVehicleType: UILabel!
    @IBOutlet weak var lblDistanceTravelled: UILabel!
    @IBOutlet weak var lblTolllFee: UILabel!
    
    @IBOutlet weak var lblFareTotal: UILabel!
    @IBOutlet weak var lblDiscountApplied: UILabel!
    @IBOutlet weak var lblChargedCard: UILabel!

    @IBOutlet weak var StackDistance: UIStackView!
    @IBOutlet weak var StackDiscount: UIStackView!
    
    @IBOutlet weak var StackVehicleType: UIStackView!
    
    @IBOutlet weak var StackTollFee: UIStackView!
    
    @IBOutlet weak var StackFareTotal: UIStackView!
    
    
    @IBAction func btnGetReceiptAction(_ sender: Any) {
        self.Delegate.didGetReceipt(customCell: self)
    }
    
    @IBAction func btnViewReceiptAction(_ sender: Any) {
        self.Delegate.didViewReceipt(customCell: self)
    }
    
    
}
