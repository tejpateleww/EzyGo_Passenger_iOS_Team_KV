//
//  TripDetailsViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 06/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class TripDetailsViewController: ParentViewController {

    var arrData:[[String:Any]] = []
    let dictData = NSMutableDictionary()
    @IBOutlet weak var tblObject : UITableView!
    
    var delegate: CompleterTripInfoDelegate!
    var BookingID = String()
    
    @IBOutlet weak var lblPaymentType: UILabel!
    
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setData()
        
//        self.tblObject.estimatedRowHeight = 100.0;
//        self.tblObject.rowHeight = UITableViewAutomaticDimension;
//        self.tblObject.tableFooterView = UIView()

//        let dict = NSMutableDictionary(dictionary: arrData.object(at: 0) as! NSDictionary) as NSMutableDictionary
//        dictData.setObject(dict.object(forKey: "PickupLocation")!, forKey: "Pickup Location" as NSCopying)
//        dictData.setObject(dict.object(forKey: "DropoffLocation")!, forKey: "Dropoff Location" as NSCopying)
//        dictData.setObject(dict.object(forKey: "NightFare")!, forKey: "Night Fee" as NSCopying)
//        dictData.setObject(dict.object(forKey: "TripFare")!, forKey: "Trip Fee" as NSCopying)
//        dictData.setObject(dict.object(forKey: "WaitingTimeCost")!, forKey: "Waiting Cost" as NSCopying)
//        dictData.setObject(dict.object(forKey: "BookingCharge")!, forKey: "Booking Charge" as NSCopying)
//        dictData.setObject(dict.object(forKey: "Discount")!, forKey: "Discount" as NSCopying)
//        dictData.setObject(dict.object(forKey: "SubTotal")!, forKey: "Sub Total" as NSCopying)
//        dictData.setObject(dict.object(forKey: "Status")!, forKey: "Status" as NSCopying)
//        dictData.setObject(dict.object(forKey: "PickupTime")!, forKey: "PickupTime" as NSCopying)
//        dictData.setObject(dict.object(forKey: "DropTime")!, forKey: "DropoffTime" as NSCopying)
//        dictData.setObject(dict.object(forKey: "Status")!, forKey: "BaseFare" as NSCopying)
//        dictData.setObject(dict.object(forKey: "Status")!, forKey: "MileageCost" as NSCopying)
//        dictData.setObject(dict.object(forKey: "Status")!, forKey: "AirportBackup" as NSCopying)
//        dictData.setObject(dict.object(forKey: "SoilDamageCharge")!, forKey: "SoilingDamage" as NSCopying)
//        dictData.setObject(dict.object(forKey: "CancellationFee")!, forKey: "CancelllationCharge" as NSCopying)
//        dictData.setObject(dict.object(forKey: "Status")!, forKey: "PromoCreditUsed" as NSCopying)
//        dictData.setObject(dict.object(forKey: "GrandTotal")!, forKey: "TotalPaidToDriver" as NSCopying)
//        dictData.setObject(dict.object(forKey: "TripDuration")!, forKey: "TripDuration" as NSCopying)
//        dictData.setObject(dict.object(forKey: "TripDistance")!, forKey: "DistanceTravelled" as NSCopying)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
        
         
          
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    
    @IBOutlet weak var lblPickupLocation: UILabel!
    @IBOutlet weak var lblDropoffLocation: UILabel!
    @IBOutlet weak var lblPickupTime: UILabel!
    @IBOutlet weak var lblDropOffTime: UILabel!
    @IBOutlet weak var lblMileageCost: UILabel!
    
    
    @IBOutlet weak var lblAirportPickup: UILabel!
    @IBOutlet weak var lblAirportDropOff: UILabel!
    
    @IBOutlet weak var lblCancelCharge: UILabel!
    @IBOutlet weak var lblBaseFare: UILabel!
//    @IBOutlet weak var lblDistanceFare: UILabel!
//    @IBOutlet weak var lblNightFare: UILabel!
    @IBOutlet weak var lblWaitingCost: UILabel!
//    @IBOutlet weak var lblTollFee: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblBookingCharge: UILabel!
//    @IBOutlet weak var lblSpecialExtraCharge: UILabel!
////    @IBOutlet weak var lblTax: UILabel!
//    @IBOutlet weak var lblDiscount: UILabel!
    
    @IBOutlet weak var lblTotalPaidToDriver: UILabel!
    
    @IBOutlet weak var lblSoilingDamage: UILabel!
    
    @IBOutlet weak var imgMAp: UIImageView!
    
    
    @IBOutlet weak var lblTripDuration: UILabel!
    
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblNoteTitle: UILabel!
    
    @IBOutlet weak var lblPromoUsed: UILabel!
    @IBOutlet weak var lblDistanceTravelled: UILabel!
    
    @IBOutlet weak var lblDriverName: UILabel!
    
    @IBOutlet weak var lblBookingId: UILabel!
   
    @IBOutlet weak var BookingFareStack: UIStackView!
    @IBOutlet weak var BaseFareStack: UIStackView!
    @IBOutlet weak var MileageFareStack: UIStackView!
    @IBOutlet weak var TimeFareStack: UIStackView!
    @IBOutlet weak var SubTotalFareStack: UIStackView!
    @IBOutlet weak var AirportPickupStack: UIStackView!
    @IBOutlet weak var AirportDropOffStack: UIStackView!
    @IBOutlet weak var DamageChargeStack: UIStackView!
    @IBOutlet weak var OtherChargeStack: UIStackView!
    @IBOutlet weak var CancelChargeStack: UIStackView!
    @IBOutlet weak var PromoUsedStack: UIStackView!
    @IBOutlet weak var TotalPaidStack: UIStackView!
    @IBOutlet weak var PlusChargesStack: UIStackView!
    @IBOutlet weak var LessStack: UIStackView!
    
    
    
//    @IBOutlet weak var stackViewSpecialExtraCharge: UIStackView!
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func setData() {
        if let data = ((arrData[0] as! [String:Any])["Info"] as! [[String:Any]])[0] as? [String:Any]  {
            
            if let Note:String = data["Notes"] as? String {
                if Note != "" {
                    self.lblNote.isHidden = false
                    self.lblNoteTitle.isHidden = false
                    self.lblNote.text = Note
                } else {
                    self.lblNote.isHidden = true
                    self.lblNoteTitle.isHidden = true
                }
            } else {
                self.lblNote.isHidden = true
                self.lblNoteTitle.isHidden = true
            }
            
            if let DriverName:String = data["DriverName"] as? String {
                lblDriverName.text = DriverName
            }
            
            lblBookingId.text = "Booking ID - \(BookingID)"
            
            if let PickupTime:String = data["PickupTime"] as? String {
                lblPickupTime.text = (PickupTime != "") ? UtilityClass.setTimeStampToDate(timeStamp: PickupTime, timeFormate: "dd-MM-yyyy HH:mm:ss") : "-"
//                UtilityClass.setTimeStampToDate(timeStamp: PickupTime, timeFormate: "dd-MM-yyyy HH:mm:ss")
            }
            
            if let DropOffTime:String = data["DropTime"] as? String {
                lblDropOffTime.text = (DropOffTime != "") ? UtilityClass.setTimeStampToDate(timeStamp: DropOffTime, timeFormate: "dd-MM-yyyy HH:mm:ss") : "-"
//                UtilityClass.setTimeStampToDate(timeStamp: DropOffTime, timeFormate: "dd-MM-yyyy HH:mm:ss")
            }
           
            
            if let BookingCharge:String = data["BookingCharge"] as? String {
                lblBookingCharge.text = BookingCharge != "" ? "$ \(String(format: "%.2f", Double(BookingCharge)!))" : "$ 0.00"
            } else {
                lblBookingCharge.text = "$ 0.00"
            }
            self.BookingFareStack.isHidden = ((self.lblBookingCharge.text == "0") || (self.lblBookingCharge.text == "$ 0.00")) ? true : false
            
            
            if let TripFare:String = data["TripFare"] as? String {
                lblBaseFare.text = TripFare != "" ? "$ \(String(format: "%.2f", Double(TripFare)!))" : "$ 0.00"
            } else {
                lblBaseFare.text = "$ 0.00"
            }
            self.BaseFareStack.isHidden = ((self.lblBaseFare.text == "0") || (self.lblBaseFare.text == "$ 0.00")) ? true : false
            
            
            if let DistanceFare:String = data["DistanceFare"] as? String {
                lblMileageCost.text = DistanceFare != "" ? "$ \(String(format: "%.2f", Double(DistanceFare)!))" : "$ 0.00"
            } else {
                lblMileageCost.text = "$ 0.00"
            }
            self.MileageFareStack.isHidden = ((self.lblMileageCost.text == "0") || (self.lblMileageCost.text == "$ 0.00")) ? true : false
            
            
            if let WaitingTimeCost:String = data["WaitingTimeCost"] as? String {
                lblWaitingCost.text = WaitingTimeCost != "" ? "$ \(String(format: "%.2f", Double(WaitingTimeCost)!))" : "$ 0.00"
            } else {
                lblWaitingCost.text = "$ 0.00"
            }
            self.TimeFareStack.isHidden = ((self.lblWaitingCost.text == "0") || (self.lblWaitingCost.text == "$ 0.00")) ? true : false
            
            
            if let SubTotal:String = data["SubTotal"] as? String {
                lblSubTotal.text = SubTotal != "" ? "$ \(String(format: "%.2f", Double(SubTotal)!))" : "$ 0.00"
            } else {
                lblSubTotal.text = "$ 0.00"
            }
            self.SubTotalFareStack.isHidden = ((self.lblSubTotal.text == "0") || (self.lblSubTotal.text == "$ 0.00")) ? true : false
           
            
            if let AirportPickup:String = data["AirportPickUpCharge"] as? String {
                lblAirportPickup.text = AirportPickup != "" ? "$ \(String(format: "%.2f", Double(AirportPickup)!))" : "$ 0.00"
            } else {
                lblAirportPickup.text = "$ 0.00"
            }
            self.AirportPickupStack.isHidden = ((self.lblAirportPickup.text == "0") || (self.lblAirportPickup.text == "$ 0.00")) ? true : false
            
            
            if let AirportDropOff:String = data["AirportDropOffCharge"] as? String {
                lblAirportDropOff.text = AirportDropOff != "" ? "$ \(AirportDropOff)" : "$ 0.00"
            } else {
                lblAirportDropOff.text = "$ 0.00"
            }
            self.AirportDropOffStack.isHidden = ((self.lblAirportDropOff.text == "0") || (self.lblAirportDropOff.text == "$ 0.00")) ? true : false
            
            
            if let imgMap = (arrData[0]["MapUrl"] as? String) {
                self.imgMAp.sd_setShowActivityIndicatorView(true)
                self.imgMAp.sd_setIndicatorStyle(.white)
                self.imgMAp.sd_setImage(with: URL(string: imgMap.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") , placeholderImage: UIImage(named: "ezy_staticmap"), options: [], completed: nil)
//                sd_setImage(with: URL(string: imgMap.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), completed: nil)
            }
            
            
            if let SoilDamageCharge:String = data["SoilDamageCharge"] as? String {
                lblSoilingDamage.text = SoilDamageCharge != "" ? "$ \(String(format: "%.2f", Double(SoilDamageCharge)!))" : "$ 0.00"
            } else {
                lblSoilingDamage.text = "$ 0.00"
            }
            self.DamageChargeStack.isHidden = ((self.lblSoilingDamage.text == "0") || (self.lblSoilingDamage.text == "$ 0.00")) ? true : false
            
            self.PlusChargesStack.isHidden = ((self.AirportPickupStack.isHidden == true) && (self.AirportDropOffStack.isHidden == true) && (self.DamageChargeStack.isHidden == true)) ? true : false
            
            
            if let CancellationFee:String = data["CancellationFee"] as? String {
                lblCancelCharge.text = CancellationFee != "" ? "$ \(String(format: "%.2f", Double(CancellationFee)!))" : "$ 0.00"
            } else {
                lblCancelCharge.text = "$ 0.00"
            }
            self.CancelChargeStack.isHidden = ((self.lblCancelCharge.text == "0") || (self.lblCancelCharge.text == "$ 0.00")) ? true : false
            self.OtherChargeStack.isHidden = self.CancelChargeStack.isHidden
            
            
            if let Discount:String = data["Discount"] as? String {
                lblPromoUsed.text = Discount != "" ? "$ \(String(format: "%.2f", Double(Discount)!))" : "$ 0.00"
            } else {
                lblPromoUsed.text = "$ 0.00"
            }
            self.PromoUsedStack.isHidden = ((self.lblPromoUsed.text == "0") || (self.lblPromoUsed.text == "$ 0.00")) ? true : false
            self.LessStack.isHidden = self.PromoUsedStack.isHidden
            
            
            if let TotalPaid:String = data["GrandTotal"] as? String {
                lblTotalPaidToDriver.text = TotalPaid != "" ? "$ \(String(format: "%.2f", Double(TotalPaid)!))" : "$ 0.00"
            } else {
                lblTotalPaidToDriver.text = "$ 0.00"
            }
            self.TotalPaidStack.isHidden = ((self.lblTotalPaidToDriver.text == "0") || (self.lblTotalPaidToDriver.text == "$ 0.00")) ? true : false
            
            
            if let PaymentType:String = data["PaymentType"] as? String {
                
                self.lblPaymentType.text = "Payment By \(PaymentType) Received With Thanks"
            }
            
            lblPickupLocation.text =  data["PickupLocation"] as? String
            lblDropoffLocation.text = data["DropoffLocation"] as? String
            
            if let tripDuration:String = data["TripDuration"] as? String {
                let time = UtilityClass.secondsToHoursMinutesSeconds(seconds: Int(tripDuration)!)
                if time.0 < 10 {
                     lblTripDuration.text =  String(format: "%02d:%02d:%02d", time.0,time.1,time.2)
                }
            }
            
            if let tripDistance:String = data["TripDistance"] as? String {
                lblDistanceTravelled.text = "\(tripDistance)km"
            }
        }
    }

    @IBAction func btnBackAction(sender: UIButton) {
        
//       NotificationCenter.default.addObserver(self, selector: #selector(YourClassName.methodOfReceivedNotification(notification:)), name: Notification.Name("CallToRating"), object: nil)
        
//        NotificationCenter.default.post(name: Notification.Name("CallToRating"), object: nil)
        
//        self.delegate.didRatingCompleted()
        self.dismiss(animated: true, completion: nil)
    }
    

    
    @IBOutlet weak var btnCall: UIButton!
    @IBAction func btCallClicked(_ sender: UIButton)
    {
        
        let contactNumber = helpLineNumber
        
        if contactNumber == "" {
            
            UtilityClass.setCustomAlert(title: "\(appName)", message: "Contact number is not available") { (index, title) in
            }
        }
        else
        {
            callNumber(phoneNumber: contactNumber)
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate.didRatingCompleted()

    }
    
    
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
 /*
    {
    "Info": [
    {
    "Id": 263,
    "PassengerId": 29,
    "ModelId": 5,
    "DriverId": 42,
    "CreatedDate": "2017-11-25T11:31:59.000Z",
    "TransactionId": "",
    "PaymentStatus": "",
    "PickupTime": "1511589728",
    "DropTime": "",
    "TripDuration": "",
    "TripDistance": "0.001",
    "PickupLocation": "119, Science City Rd, Sola, Ahmedabad, Gujarat 380060, India",
    "DropoffLocation": "Iscon Mega Mall, Ahmedabad, Gujarat, India",
    "NightFareApplicable": 0,
    "NightFare": "0",
    "TripFare": "30",
    "DistanceFare": "0",
    "WaitingTime": "",
    "WaitingTimeCost": "0",
    "TollFee": "0",
    "BookingCharge": "2",
    "Tax": "3.20",
    "PromoCode": "",
    "Discount": "0",
    "SubTotal": "30.00",
    "GrandTotal": "32.00",
    "Status": "completed",
    "Reason": "",
    "PaymentType": "cash",
    "ByDriverAmount": "",
    "AdminAmount": "5.00",
    "CompanyAmount": "27.00",
    "PickupLat": "23.07272",
    "PickupLng": "72.516387",
    "DropOffLat": "23.030513",
    "DropOffLon": "72.5075401",
    "BookingType": "",
    "ByDriverId": 0,
    "PassengerName": "",
    "PassengerContact": "",
    "PassengerEmail": ""
    }
    ]
    }
    
    */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
    
    /*
    //MARK:- Tableview delegate and dataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dictData.allKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:TripDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TripDetailsTableViewCell") as! TripDetailsTableViewCell
        cell.lblTitle.text = dictData.allKeys[indexPath.row] as? String
        cell.lblDescription.text = dictData.allValues[indexPath.row] as? String
        return cell
    }
//
//
//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 100
//    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
*/

