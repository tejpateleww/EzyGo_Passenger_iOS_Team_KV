//
//  OnGoingVC.swift
//  TickTok User
//
//  Created by Excellent Webworld on 09/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import SDWebImage

class OnGoingVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ActionDelegate {

    @IBOutlet weak var lblNoData: UILabel!
    var aryData:[[String:Any]] = []
    
    var strPickupLat = String()
    var strPickupLng = String()
    
    var strDropoffLat = String()
    var strDropoffLng = String()
    
    var PickupAddress = String()
    var DropoffAddress = String()
    
    
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
   
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        self.tableView.addSubview(self.refreshControl)
        
        // Register to receive notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationCenterName.keyForOnGoing), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.webserviceOfBookingHistory), name: NSNotification.Name(rawValue: NotificationCenterName.keyForOnGoing), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadDataOfTableView() {
        
//        self.aryData = SingletonClass.sharedInstance.aryOnGoing
        if self.aryData.count > 0 {
            self.lblNoData.isHidden = true
        } else {
            self.lblNoData.isHidden = false
        }
        
        self.tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
       self.webserviceOfBookingHistory()
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
            if let name = currentData["DriverName"] as? String {
                
                if name == "" {
                    cell.lblDriverName.text = "Driver Name:- no driver"
                }
                else {
                    cell.lblDriverName.text = "Driver Name:- \(name)"
                }
            }
            
            if let BookingID:String = currentData["Id"] as? String {
                cell.lblBookingID.text = "Booking ID - \(BookingID)"
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
            
            if let BookingCharge:String = currentData[ "BookingCharge"] as? String {
                cell.lblBookingFee.text = BookingCharge != "" ? "$ \(String(format: "%.2f", Double(BookingCharge)!))" : "$ 0.00"
            } else {
                cell.lblBookingFee.text = "$ 0.00"
            }
            
            if let imgMap = currentData[ "MapUrl"] as? String {
                cell.MapImage.sd_setShowActivityIndicatorView(true)
                cell.MapImage.sd_setIndicatorStyle(.gray)
                cell.MapImage.sd_setImage(with: URL(string: imgMap.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), completed: nil)
            }
            
            if let TripFare:String = currentData[ "TripFare"] as? String {
                cell.lblBaseFare.text = TripFare != "" ? "$ \(String(format: "%.2f", Double(TripFare)!))" : "$ 0.00"
            } else {
                cell.lblBaseFare.text = "$ 0.00"
            }
            
            if let DistanceFare:String = currentData[ "DistanceFare"] as? String {
                cell.lblMileageCost.text = DistanceFare != "" ? "$ \(String(format: "%.2f", Double(DistanceFare)!))" : "$ 0.00"
            } else {
                cell.lblMileageCost.text = "$ 0.00"
            }
            
            if let WaitingTimeCost:String = currentData[ "WaitingTimeCost"] as? String {
                cell.lblTimeCost.text = WaitingTimeCost != "" ? "$ \(String(format: "%.2f", Double(WaitingTimeCost)!))" : "$ 0.00"
            } else {
                cell.lblTimeCost.text = "$ 0.00"
            }
            
            if let SubTotal:String = currentData[ "SubTotal"] as? String {
                cell.lblSubTotal.text = SubTotal != "" ? "$ \(String(format: "%.2f", Double(SubTotal)!))" : "$ 0.00"
            } else {
                cell.lblSubTotal.text = "$ 0.00"
            }
            
            if let AirportPickup:String = currentData[ "AirportPickUpCharge"] as? String {
                cell.lblAirportPickUpTime.text = AirportPickup != "" ? "$ \(String(format: "%.2f", Double(AirportPickup)!))" : "$ 0.00"
            } else {
                cell.lblAirportPickUpTime.text = "$ 0.00"
            }
            
            if let AirportDropOff:String = currentData[ "AirportDropOffCharge"] as? String {
                cell.lblAirportDropOffTime.text = AirportDropOff != "" ? "$ \(String(format: "%.2f", Double(AirportDropOff)!))" : "$ 0.00"
            } else {
                cell.lblAirportDropOffTime.text = "$ 0.00"
            }
            
            if let SoilDamageCharge:String = currentData[ "SoilDamageCharge"] as? String {
                cell.lblSoiling_Damage.text = SoilDamageCharge != "" ? "$ \(String(format: "%.2f", Double(SoilDamageCharge)!))" : "$ 0.00"
            } else {
                cell.lblSoiling_Damage.text = ""
            }
            
            if let Discount:String = currentData[ "Discount"] as? String {
                cell.lblPromoCreditUsed.text = Discount != "" ? "$ \(String(format: "%.2f", Double(Discount)!))" : "$ 0.00"
            } else {
                cell.lblPromoCreditUsed.text = "$ 0.00"
            }
            
            if let TotalPaid:String = currentData[ "GrandTotal"] as? String {
                cell.lblGrandTotal.text = TotalPaid != "" ? "$ \(String(format: "%.2f", Double(TotalPaid)!))" : "$ 0.00"
            } else {
                cell.lblGrandTotal.text = "$ 0.00"
            }
            
            if let PaymentType:String = currentData[ "PaymentType"] as? String {
                cell.lblPaymentDetail.text = "Payment By \(PaymentType) Received With Thanks"
            }
            
            if let PickupDateTime:String = currentData[ "PickupDateTime"] as? String {
                if PickupDateTime != "" {
                    //                    cell.stackViewPickupTime.isHidden = false
                    cell.lblPickUpTime.text = PickupDateTime
                } else {
                    //                    cell.stackViewPickupTime.isHidden = true
                }
            } else {
                //                cell.stackViewPickupTime.isHidden = true
            }
            //
            if let Note:String = currentData[ "Notes"] as? String {
                if Note != "" {
                    cell.stackViewNote.isHidden = false
                    cell.lblNote.text = Note
                } else {
                    cell.stackViewNote.isHidden = true
                }
            } else {
                cell.stackViewNote.isHidden = true
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
            
            cell.viewDetails.isHidden = !expandedCellPaths.contains(indexPath)
            
            cell.Delegate = self
        }
        

 
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? PastBooingTableViewCell {
            cell.viewDetails.isHidden = !cell.viewDetails.isHidden
            if cell.viewDetails.isHidden {
                expandedCellPaths.remove(indexPath)
            } else {
                expandedCellPaths.insert(indexPath)
            }
            tableView.beginUpdates()
            tableView.endUpdates()
            
        }
    }
    
    
    @objc func CancelRequest() {
        
    }
   
    @objc func trackYourTrip(sender: UIButton) {
        
        let currentData = aryData[sender.tag]
        
        let id:String = currentData["Id"] as! String
        
        RunningTripTrack(param: id)
        
    }
    
    
    func RunningTripTrack(param: String) {
        if Connectivity.isConnectedToInternet() == false {
            self.refreshControl.endRefreshing()
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        
        webserviceForTrackRunningTrip(param as AnyObject) { (result, status) in
            
            if (status) {
                 print(result)
                SingletonClass.sharedInstance.bookingId = param
                
//                 Post notification
                NotificationCenter.default.post(name: NotificationTrackRunningTrip, object: nil)
                
                self.navigationController?.popViewController(animated: true)
                
            }
            else {
                SingletonClass.sharedInstance.bookingId = ""
                NotificationCenter.default.post(name: NotificationForAddNewBooingOnSideMenu, object: nil)
                var msg = String()
                if let res = result as? String {
                    msg = res
                }
                else if let resDict = result as? NSDictionary {
                    msg = resDict.object(forKey: "message") as! String
                }
                else if let resAry = result as? NSArray {
                    msg = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                }
                
                let alert = UIAlertController(title: "Ezygo", message: msg, preferredStyle: .alert)
                let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OK)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func DelegateWithCell(CustomCell: UITableViewCell) {
        let SingleIndexPath = self.tableView.indexPath(for: CustomCell)
        let currentData = aryData[SingleIndexPath!.row]
        
        let id:String = currentData ["Id"] as! String
        
        RunningTripTrack(param: id)
        
    }
    
    @objc func webserviceOfBookingHistory()
    {
        //        let activityData = ActivityData()
        //        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        //
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        webserviceForOngoingBookingHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                self.aryData = (result as! [String:Any])["history"] as! [[String:Any]]
                print(self.aryData)
              
                self.reloadDataOfTableView()
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
    
/*
    func setMarkersOnMap(PickupLatitude: Double, PickupLongitude: Double, DropoffLatitude: Double, DropoffLongitude: Double, PickupLocation: String, DropoffLocation: String) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
    
        SingletonClass.sharedInstance.boolIsFromPrevious = true
        
        
        let dictData = NSMutableDictionary()
        
        dictData.setValue(Double(strPickupLat)!, forKey: "PickupLat")
        dictData.setValue(Double(strPickupLng)!, forKey: "PickupLng")
        
        dictData.setValue(Double(strDropoffLat)!, forKey: "DropOffLat")
        dictData.setValue(Double(strDropoffLng)!, forKey: "DropOffLon")
        
        dictData.setValue(PickupAddress, forKey: "PickupLocation")
        dictData.setValue(DropoffAddress, forKey: "DropoffLocation")
        
        
        SingletonClass.sharedInstance.dictIsFromPrevious = dictData
     
        
//        next.zPickupLat = Double(strPickupLat)!
//        next.zPickupLng = Double(strPickupLng)!
//
//        next.zDropoffLat = Double(strDropoffLat)!
//        next.zDropoffLng = Double(strDropoffLng)!
//
//        next.zPickupLocation = PickupAddress
//        next.zDropoffLocation = DropoffAddress
        
//        self.navigationController?.popViewController(animated: true)
//        self.navigationController?.pushViewController(next, animated: true)
        
        self.navigationController?.present(next, animated: true, completion: nil)
    }
*/
    
}
