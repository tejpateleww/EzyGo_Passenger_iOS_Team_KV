//
//  PastBooingTableViewCell.swift
//  TickTok User
//
//  Created by Excellent Webworld on 09/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//



import UIKit

protocol ActionDelegate {
    func DelegateWithCell(CustomCell:UITableViewCell)
}

class PastBooingTableViewCell: UITableViewCell {

    var Delegate:ActionDelegate!

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
    
  
//    @IBOutlet weak var lblDriverName: UILabel!
//    @IBOutlet weak var lblBookingID: UILabel!
//
//
//    @IBOutlet weak var lblDropoffAddress: UILabel!  // DropOff Address is PickupAddress
//
//
//    @IBOutlet weak var lblDateAndTime: UILabel!
//
//
//    @IBOutlet weak var lblPickupAddress: UILabel! // Pickup Address is PickupAddress
    
    @IBOutlet weak var stackViewNote: UIStackView!
    
    @IBOutlet weak var stackViewPickupTime: UIStackView!
    
    @IBOutlet weak var stackViewCancellation: UIStackView!
    
    @IBOutlet weak var stackViewTotal: UIStackView!
    
    @IBOutlet weak var stackViewPayment: UIStackView!
    @IBOutlet weak var stackViewNoteInCancel: UIStackView!
    
    @IBOutlet weak var BookingFareStack: UIStackView!
    @IBOutlet weak var BaseFareStack: UIStackView!
    @IBOutlet weak var MileageFareStack: UIStackView!
    @IBOutlet weak var TimeFareStack: UIStackView!
    @IBOutlet weak var SubTotalFareStack: UIStackView!
    @IBOutlet weak var AirportPickupStack: UIStackView!
    @IBOutlet weak var AirportDropOffStack: UIStackView!
    @IBOutlet weak var DamageChargeStack: UIStackView!
    @IBOutlet weak var PromoUsedStack: UIStackView!
    @IBOutlet weak var TotalPaidStack: UIStackView!
    @IBOutlet weak var PlusChargesStack: UIStackView!
    @IBOutlet weak var LessStack: UIStackView!
    
    @IBOutlet weak var PaymentStatusStack: UIStackView!
    
//    @IBOutlet weak var lblPickupTime: UILabel!
//
//    @IBOutlet weak var stackViewDropoffTime: UIStackView!
//    @IBOutlet weak var lblDropoffTime: UILabel!
//
//    @IBOutlet weak var stackViewVehicleType: UIStackView!
//    @IBOutlet weak var lblVehicleType: UILabel!
    
//    @IBOutlet weak var stackViewDistanceTravelled: UIStackView!
//    @IBOutlet weak var lblDistanceTravelled: UILabel!
//
//    @IBOutlet weak var stackViewTripFare: UIStackView!
//    @IBOutlet weak var lblTripFare: UILabel!
//
//    @IBOutlet weak var stackViewNightFare: UIStackView!
//    @IBOutlet weak var lblNightFare: UILabel!
//
//    @IBOutlet weak var stackViewTollFee: UIStackView!
//    @IBOutlet weak var lblTollFee: UILabel!
//
//    @IBOutlet weak var stackViewWaitingCost: UIStackView!
//    @IBOutlet weak var lblWaitingCost: UILabel!
//
//    @IBOutlet weak var stackViewBookingCharge: UIStackView!
//    @IBOutlet weak var lblBookingCharge: UILabel!
//
//    @IBOutlet weak var stackViewTax: UIStackView!
//    @IBOutlet weak var lblTax: UILabel!
//
//    @IBOutlet weak var stackViewDiscount: UIStackView!
//    @IBOutlet weak var lblDiscount: UILabel!
//
//    @IBOutlet weak var stackViewPaymentType: UIStackView!
//    @IBOutlet weak var lblPaymentType: UILabel!
//
//    @IBOutlet weak var stackViewTotalCost: UIStackView!
//    @IBOutlet weak var lblTotalCost: UILabel!
//
//    @IBOutlet weak var lblWaitingTime: UILabel!
    
    
    @IBOutlet weak var lblDriverName: UILabel!
    
    @IBOutlet weak var lblTripDate: UILabel!
    
    @IBOutlet weak var lblBookingID: UILabel!
    
    @IBOutlet weak var lblPickUpLocation: UILabel!
    @IBOutlet weak var lblDropLocation: UILabel!
    @IBOutlet weak var lblPickUpTime: UILabel!
    
    
    @IBOutlet weak var lblDropOffTime: UILabel!
    
    @IBOutlet weak var lblBookingFee: UILabel!
    
    @IBOutlet weak var lblBaseFare: UILabel!

    @IBOutlet weak var lblMileageCost: UILabel!
    @IBOutlet weak var lblTimeCost: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblAirportPickUpTime: UILabel!
    @IBOutlet weak var lblAirportDropOffTime: UILabel!
    
    @IBOutlet weak var lblSoiling_Damage: UILabel!
    @IBOutlet weak var lblExtraSubTotal: UILabel!
    
    @IBOutlet weak var lblCancelCharge: UILabel!
   
    @IBOutlet weak var lblPromoCreditUsed: UILabel!
    
    @IBOutlet weak var lblGrandTotal: UILabel!
    
    @IBOutlet weak var lblPaymentDetail: UILabel!
  
    @IBOutlet weak var lblTripDuration: UILabel!
    
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var btnReceipt: UIButton!
    
    @IBOutlet weak var buttonViewHeight: NSLayoutConstraint!
    @IBOutlet weak var MapImage: UIImageView!
    
    @IBOutlet weak var lblNote: UILabel!
    
    @IBOutlet weak var lblChargeinCancel: UILabel!
    @IBOutlet weak var lblTotalinCancel: UILabel!
    
    @IBOutlet weak var lblPaymentinCancel: UILabel!
    
    @IBOutlet weak var lblPaymentStatusTitle: UILabel!
    @IBOutlet weak var lblPaymentStatusValue: UILabel!
    
    @IBAction func btnAction(_ sender: UIButton) {
        self.Delegate.DelegateWithCell(CustomCell: self)
    }
    
    
}
