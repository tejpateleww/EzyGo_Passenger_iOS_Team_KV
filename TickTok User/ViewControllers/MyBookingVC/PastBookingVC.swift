//
//  PastBookingVC.swift
//  TickTok User
//
//  Created by Excellent Webworld on 09/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class PastBookingVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ActionDelegate {
    
    
    var aryData:[[String:Any]] = []
    
    var strPickupLat = String()
    var strPickupLng = String()
    
    var strDropoffLat = String()
    var strDropoffLng = String()
    var PageLimit:Int = 10
    var NeedToReload:Bool = false
    var PageNumber:Int = 1
    
    var strNotAvailable: String = "N/A"
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var LoaderBackView: UIView!
    
    
    @IBOutlet weak var lblNoData: UILabel!
    
    var expandedCellPaths = Set<IndexPath>()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = themeYellowColor
        
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.LoaderBackView.isHidden = true
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        self.tableView.addSubview(self.refreshControl)
        
        // Register to receive notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationCenterName.keyForPastBooking), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.ReloadNewData), name: NSNotification.Name(rawValue: NotificationCenterName.keyForPastBooking), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadTableView()
    {
//        self.aryData = SingletonClass.sharedInstance.aryPastBooking
        if self.aryData.count > 0 {
            self.lblNoData.isHidden = true
        } else {
            self.lblNoData.isHidden = false
        }
        self.tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.ReloadNewData()
    }
    
    @objc func ReloadNewData(){
        self.PageNumber = 1
        self.NeedToReload = false
        self.aryData.removeAll()
        self.tableView.reloadData()
        self.getPastBookingHistory()
    }
    
    func reloadMoreHistory() {
        self.PageNumber += 1
        self.LoaderBackView.isHidden = false
        self.ActivityIndicator.startAnimating()
        self.getPastBookingHistory()
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //-------------------------------------------------------------
    // MARK: - Table View Methods
    //-------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastBooingTableViewCell") as! PastBooingTableViewCell
        
        if aryData.count > 0 {
            
            cell.selectionStyle = .none
            let currentData = aryData[indexPath.row]
//                (aryData.object(at: indexPath.row) as! NSDictionary)
            if let name = currentData["DriverName"] as? String {
                
                if name == "" {
                    cell.lblDriverName.text = "Driver Name:- no driver"
                }
                else {
                    cell.lblDriverName.text = "Driver Name:- \(name)"
                }
            }
            
            if let BookingId:String = currentData["Id"] as? String {
                cell.lblBookingID.text = "Booking ID - \(BookingId)"
            }
            
            if let DateandTime:String = currentData[ "CreatedDate"] as? String {
//                let createdDate = DateandTime.components(separatedBy: " ")
                cell.lblTripDate.text = DateandTime
//                    createdDate[0]
            }
            
            if let PickupLocation:String = currentData[ "PickupLocation"] as? String {
                cell.lblPickUpLocation.text = PickupLocation
            }
            
            if let DropOffLocation:String = currentData[ "DropoffLocation"] as? String {
                cell.lblDropLocation.text = DropOffLocation
            }
            
            if let PickupTime:String = currentData[ "PickupTime"] as? String {
                cell.lblPickUpTime.text = (PickupTime != "") ? UtilityClass.setTimeStampToDate(timeStamp: PickupTime, timeFormate: "dd-MM-yyyy HH:mm:ss") : "-"
            }
            
            if let DropOffTime:String = currentData[ "DropTime"] as? String {
                cell.lblDropOffTime.text = (DropOffTime != "") ? UtilityClass.setTimeStampToDate(timeStamp: DropOffTime, timeFormate: "dd-MM-yyyy HH:mm:ss") : "-"
            }
            
            if let imgMap = currentData[ "MapUrl"] as? String {
                cell.MapImage.sd_setShowActivityIndicatorView(true)
                cell.MapImage.sd_setIndicatorStyle(.white)
                cell.MapImage.sd_setImage(with: URL(string: imgMap.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: UIImage(named: "ezy_staticmap"), options: [] , completed: nil)
//                sd_setImage(with: URL(string: imgMap.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), completed: nil)
            }
            
            if let BookingCharge:String = currentData[ "BookingCharge"] as? String {
                cell.lblBookingFee.text = BookingCharge != "" ? "$ \(String(format: "%.2f", Double(BookingCharge)!))" : "$ 0.00"
            } else {
                cell.lblBookingFee.text = "$ 0.00"
            }
            cell.BookingFareStack.isHidden = ((cell.lblBookingFee.text == "0") || (cell.lblBookingFee.text == "$ 0.00")) ? true : false
            
            if let TripFare:String = currentData[ "TripFare"] as? String {
                cell.lblBaseFare.text = TripFare != "" ? "$ \(String(format: "%.2f", Double(TripFare)!))" : "$ 0.00"
            } else {
                cell.lblBaseFare.text = "$ 0.00"
            }
            cell.BaseFareStack.isHidden = ((cell.lblBaseFare.text == "0") || (cell.lblBaseFare.text == "$ 0.00")) ? true : false
            
            if let DistanceFare:String = currentData[ "DistanceFare"] as? String {
                cell.lblMileageCost.text = DistanceFare != "" ? "$ \(String(format: "%.2f", Double(DistanceFare)!))" : "$ 0.00"
            } else {
                cell.lblMileageCost.text = "$ 0.00"
            }
            cell.MileageFareStack.isHidden = ((cell.lblMileageCost.text == "0") || (cell.lblMileageCost.text == "$ 0.00")) ? true : false
            
            if let WaitingTimeCost:String = currentData[ "WaitingTimeCost"] as? String {
                cell.lblTimeCost.text = WaitingTimeCost != "" ? "$ \(String(format: "%.2f", Double(WaitingTimeCost)!))" : "$ 0.00"
            } else {
                cell.lblTimeCost.text = "$ 0.00"
            }
            cell.TimeFareStack.isHidden = ((cell.lblTimeCost.text == "0") || (cell.lblTimeCost.text == "$ 0.00")) ? true : false
            
            if let SubTotal:String = currentData[ "SubTotal"] as? String {
                cell.lblSubTotal.text = SubTotal != "" ? "$ \(String(format: "%.2f", Double(SubTotal)!))" : "$ 0.00"
                //                cell.lblExtraSubTotal.text = SubTotal != "" ? "$ \(SubTotal)" : "$ 0.00"
            } else {
                cell.lblSubTotal.text = "$ 0.00"
                //                 cell.lblExtraSubTotal.text = "$ 0.00"
                
            }
            cell.SubTotalFareStack.isHidden = ((cell.lblSubTotal.text == "0") || (cell.lblSubTotal.text == "$ 0.00")) ? true : false
            
            if let AirportPickup:String = currentData[ "AirportPickUpCharge"] as? String {
                cell.lblAirportPickUpTime.text = AirportPickup != "" ? "$ \(String(format: "%.2f", Double(AirportPickup)!))" : "$ 0.00"
            } else {
                cell.lblAirportPickUpTime.text = "$ 0.00"
            }
            cell.AirportPickupStack.isHidden = ((cell.lblAirportPickUpTime.text == "0") || (cell.lblAirportPickUpTime.text == "$ 0.00")) ? true : false
            
            if let AirportDropOff:String = currentData[ "AirportDropOffCharge"] as? String {
                cell.lblAirportDropOffTime.text = AirportDropOff != "" ? "$ \(String(format: "%.2f", Double(AirportDropOff)!))" : "$ 0.00"
            } else {
                cell.lblAirportDropOffTime.text = "$ 0.00"
            }
            cell.AirportDropOffStack.isHidden = ((cell.lblAirportDropOffTime.text == "0") || (cell.lblAirportDropOffTime.text == "$ 0.00")) ? true : false
            
            if let SoilDamageCharge:String = currentData[ "SoilDamageCharge"] as? String {
                cell.lblSoiling_Damage.text = SoilDamageCharge != "" ? "$ \(String(format: "%.2f", Double(SoilDamageCharge)!))" : "$ 0.00"
            } else {
                cell.lblSoiling_Damage.text = "$ 0.00"
            }
            cell.DamageChargeStack.isHidden = ((cell.lblSoiling_Damage.text == "0") || (cell.lblSoiling_Damage.text == "$ 0.00")) ? true : false
            
            cell.PlusChargesStack.isHidden = ((cell.AirportPickupStack.isHidden == true) && (cell.AirportDropOffStack.isHidden == true) && (cell.DamageChargeStack.isHidden == true)) ? true : false
            
            if let Discount:String = currentData[ "Discount"] as? String {
                cell.lblPromoCreditUsed.text = Discount != "" ? "$ \(String(format: "%.2f", Double(Discount)!))" : "$ 0.00"
            } else {
                cell.lblPromoCreditUsed.text = "$ 0.00"
            }
            cell.PromoUsedStack.isHidden = ((cell.lblPromoCreditUsed.text == "0") || (cell.lblPromoCreditUsed.text == "$ 0.00")) ? true : false
            cell.LessStack.isHidden = cell.PromoUsedStack.isHidden
            
            if let TotalPaid:String = currentData[ "GrandTotal"] as? String {
                cell.lblGrandTotal.text = TotalPaid != "" ? "$ \(String(format: "%.2f", Double(TotalPaid)!))" : "$ 0.00"
            } else {
                cell.lblGrandTotal.text = "$ 0.00"
            }
            
            
            if let PaymentType:String = currentData[ "PaymentType"] as? String {
                cell.lblPaymentDetail.text = (PaymentType == "card") ? "Payment By Credit Card" : "Payment By \(PaymentType)"
            
                if let PaymentStatus:String = currentData["UnpaidDriverStatus"] as? String {
                    if PaymentStatus == "0" {
                        cell.PaymentStatusStack.isHidden     = false
                        cell.lblPaymentDetail.isHidden   = true
                        cell.lblPaymentStatusValue.text = "Pending"
                        
                    } else if PaymentStatus == "1" {
                        cell.PaymentStatusStack.isHidden     = true
                        cell.lblPaymentDetail.isHidden   = false
                    }
                }
            }
            
            if let tripDuration:String = currentData[ "TripDuration"] as? String {
                if tripDuration != "" {
                    let time = UtilityClass.secondsToHoursMinutesSeconds(seconds: Int(tripDuration)!)
                    cell.lblTripDuration.text =  String(format: "%02d:%02d:%02d", time.0,time.1,time.2)
                } else {
                    cell.lblTripDuration.text = "-"
                }
            }
            
            if let tripDistance:String = currentData[ "TripDistance"] as? String {
                cell.lblDistance.text = "\(tripDistance)km"
            }
            
            
            if expandedCellPaths.contains(indexPath) == true {
                
                if let TripStatus:String = currentData[ "Status"] as? String {
                    
                    if TripStatus == "completed" {
                        cell.stackViewNoteInCancel.isHidden = true
                        cell.stackViewTotal.isHidden = true
                        cell.stackViewPayment.isHidden = true
                        cell.stackViewCancellation.isHidden = true
                        
                        cell.viewDetails.isHidden = false
                        if let Note:String = currentData[ "Notes"] as? String {
                            if Note != "" {
                            cell.lblNote.text = Note
                            cell.stackViewNoteInCancel.isHidden = false
                            }
                        }
                        
                        cell.btnReceipt.isHidden = false
//                        cell.lblPaymentDetail.isHidden = false
                        
                        if let PaymentStatus:String = currentData["UnpaidDriverStatus"] as? String {
                            if PaymentStatus == "0" {
                                cell.lblPaymentDetail.isHidden   = true
                            } else if PaymentStatus == "1" {
                                cell.lblPaymentDetail.isHidden   = false
                            }
                        }
                        
                        cell.buttonViewHeight.constant = 50.0
                        
                    } else {
                        cell.viewDetails.isHidden = true
                        
                        cell.stackViewNoteInCancel.isHidden = false
                        cell.stackViewTotal.isHidden = false
                        cell.stackViewPayment.isHidden = false
                        cell.stackViewCancellation.isHidden = false
   
                        if let Note:String = currentData[ "Notes"] as? String {
                            cell.lblNote.text = Note
                        }
                        cell.stackViewNoteInCancel.isHidden = (cell.lblNote.text == "") ? true : false

                        if let CancelCharge:String = currentData[ "CancellationFee"] as? String {
                            cell.lblChargeinCancel.text = CancelCharge != "" ? "$ \(String(format: "%.2f", Double(CancelCharge)!))" : "$ 0.00"
                        } else {
                            cell.lblChargeinCancel.text = "$ 0.00"
                        }
                        cell.stackViewCancellation.isHidden = ((cell.lblChargeinCancel.text == "0") || (cell.lblChargeinCancel.text == "$ 0.00")) ? true : false
                        
                        if let TotalPaid:String = currentData[ "GrandTotal"] as? String {
                            cell.lblTotalinCancel.text = TotalPaid != "" ? "$ \(String(format: "%.2f", Double(TotalPaid)!))" : "$ 0.00"
                        } else {
                            cell.lblTotalinCancel.text = "$ 0.00"
                        }
                        cell.stackViewTotal.isHidden = ((cell.lblTotalinCancel.text == "0") || (cell.lblTotalinCancel.text == "$ 0.00")) ? true : false
//                        cell.stackViewPayment.isHidden = cell.PromoUsedStack.isHidden
                        
//                        if let PaymentType:String = currentData[ "PaymentType"] as? String {
//                            cell.lblPaymentinCancel.text = "Payment By \(PaymentType) Received With Thanks"
//                        }
                        
                        if let CancelBy:String = currentData[ "CancelBy"] as? String {
                            cell.lblPaymentinCancel.text = "Trip Cancelled By \(CancelBy)"
                        }
                        
                         cell.stackViewPayment.isHidden = (cell.lblPaymentinCancel.text == "Trip Cancelled By ") ? true : false
                        
                        cell.btnReceipt.isHidden = true
                        cell.lblPaymentDetail.isHidden = true
                        cell.buttonViewHeight.constant = 15.0
                    }
                }
                
            } else {
                cell.viewDetails.isHidden = true
                cell.stackViewNoteInCancel.isHidden = true
                cell.stackViewTotal.isHidden = true
                cell.stackViewPayment.isHidden = true
                cell.stackViewCancellation.isHidden = true
                
                if let TripStatus:String = currentData[ "Status"] as? String {
                    
                    if TripStatus == "completed" {
                        cell.btnReceipt.isHidden = false
//                        cell.lblPaymentDetail.isHidden = false
                        if let PaymentStatus:String = currentData["UnpaidDriverStatus"] as? String {
                            if PaymentStatus == "0" {
                                cell.lblPaymentDetail.isHidden   = true
                            } else if PaymentStatus == "1" {
                                cell.lblPaymentDetail.isHidden   = false
                            }
                        }
                        cell.buttonViewHeight.constant = 50.0
                    } else {
                        cell.btnReceipt.isHidden = true
                        cell.lblPaymentDetail.isHidden = true
                        cell.buttonViewHeight.constant = 15.0
                    }
                }
            }
            
            cell.Delegate = self
            
        }
        
        if self.NeedToReload == true && indexPath.row == self.aryData.count - 1  {
                self.reloadMoreHistory()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedCellPaths.contains(indexPath) {
            expandedCellPaths.remove(indexPath)
        } else {
            expandedCellPaths.insert(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        //        if let cell = tableView.cellForRow(at: indexPath) as? PastBooingTableViewCell {
        
        
        //            tableView.reloadData()
        
        //            let currentData = (aryData.object(at: indexPath.row) as! NSDictionary)
        //            if let TripStatus:String = currentData[ "Status") as? String {
        //                if TripStatus == "completed" {
        //                    cell.viewDetails.isHidden = !cell.viewDetails.isHidden
        //                    if cell.viewDetails.isHidden {
        //                        expandedCellPaths.remove(indexPath)
        //                    } else {
        //                        expandedCellPaths.insert(indexPath)
        //                    }
        //                } else {
        //
        //                }
        //            }
        //            tableView.beginUpdates()
        //            tableView.endUpdates()
        //
        //        }
    }
    
    //-------------------------------------------------------------
    // MARK: - WebService Call
    //-------------------------------------------------------------
    
    @objc func getPastBookingHistory(){
        if Connectivity.isConnectedToInternet() == false {
                  self.refreshControl.endRefreshing()
            UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        
        webserviceForPastBookingHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject, Page: PageNumber) { (result, status) in
            
            if (status) {
                let arrHistory = (result as! [String:Any])["history"] as! [[String:Any]]
               
                if arrHistory.count == 10 {
                    self.NeedToReload = true
                } else {
                    self.NeedToReload = false
                }
                
                if self.aryData.count == 0 {
                    self.aryData = arrHistory
                } else {
                    self.aryData.append(contentsOf: arrHistory)
                }
                
                self.reloadTableView()
                
                if self.LoaderBackView.isHidden == false {
                    self.ActivityIndicator.stopAnimating()
                    self.LoaderBackView.isHidden = true
                }
                
                self.refreshControl.endRefreshing()
                
            }
            else {
                
                print(result)
                
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: alertTitle, message: res) { (index, title) in
                    }
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.setCustomAlert(title: alertTitle, message: resDict.object(forKey: "message") as! String) { (index, title) in
                    }
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: alertTitle, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                }
            }
        }
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func setTimeStampToDate(timeStamp: String) -> String {
        
        let unixTimestamp = Double(timeStamp)
        //        let date = Date(timeIntervalSince1970: unixTimestamp)
        
        let date = Date(timeIntervalSince1970: unixTimestamp!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm yyyy/MM/dd" //Specify your format that you want
        let strDate: String = dateFormatter.string(from: date)
        
        return strDate
    }
    
    func DelegateWithCell(CustomCell: UITableViewCell) {
        
        let SingleIndexPath = self.tableView.indexPath(for: CustomCell)
        let currentData = (aryData[SingleIndexPath!.row] as NSDictionary)
        
        if let ShareURL:String = currentData[ "ShareUrl"] as? String {
            
            let items = ["\n Please download Receipt/Invoice from link below\n \n \(ShareURL) "]
            
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(ac, animated: true)
        }
        
    }
}


extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, _ fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont(name: "AvenirNext-Medium", size: fontSize)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}
