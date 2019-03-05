//
//  UpCommingVC.swift
//  TickTok User
//
//  Created by Excellent Webworld on 09/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class UpCommingVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ActionDelegate {
    
    var aryData:[[String:Any]] = []
    
    var strPickupLat = String()
    var strPickupLng = String()
    
    var strDropoffLat = String()
    var strDropoffLng = String()
    let notAvailable: String = "N/A"
    
    var bookinType = String()
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
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        self.tableView.addSubview(self.refreshControl)
        
        // Register to receive notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationCenterName.keyForUpComming), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.webserviceOfBookingHistory), name: NSNotification.Name(rawValue: NotificationCenterName.keyForUpComming), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.webserviceOfBookingHistory()
//        if self.aryData.count > 0 {
//            self.lblNoData.isHidden = true
//        } else {
//            self.lblNoData.isHidden = false
//        }
//        tableView.reloadData()
//        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadDataTableView()
    {
//        self.aryData = SingletonClass.sharedInstance.aryUpComming
        if self.aryData.count > 0 {
            self.lblNoData.isHidden = true
        } else {
            self.lblNoData.isHidden = false
        }
        self.tableView.reloadData()
        //        self.tableView.frame.size = tableView.contentSize
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
            
            if let ArrivedTime:String = currentData[ "ArrivedTime"] as? String {
                
                if ArrivedTime == "0" {
                    cell.btnReceipt.isHidden = false
                    cell.buttonViewHeight.constant = 50.0
                } else {
                    cell.btnReceipt.isHidden = true
                    cell.buttonViewHeight.constant = 15.0
                }
            }
            
            if let name = currentData[ "DriverName"] as? String {
                
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
//
            /*
             //this code is hide to display required fields only in upcomping Screen
             
            if let PickupTime:String = currentData[ "PickupTime"] as? String {
                cell.lblPickUpTime.text = (PickupTime != "") ? UtilityClass.setTimeStampToDate(timeStamp: PickupTime, timeFormate: "dd-MM-yyyy HH:mm:ss") : "-"
            }
            
            if let DropOffTime:String = currentData[ "DropTime"] as? String {
                cell.lblDropOffTime.text = (DropOffTime != "") ? UtilityClass.setTimeStampToDate(timeStamp: DropOffTime, timeFormate: "dd-MM-yyyy HH:mm:ss") : "-"
            }
            
            if let BookingCharge:String = currentData[ "BookingCharge"] as? String {
                cell.lblBookingFee.text = BookingCharge != "" ? "$ \(BookingCharge)" : "$ 0.00"
            } else {
                cell.lblBookingFee.text = "$ 0.00"
            }

            if let TripFare:String = currentData[ "TripFare"] as? String {
                cell.lblBaseFare.text = TripFare != "" ? "$ \(TripFare)" : "$ 0.00"
            } else {
                cell.lblBaseFare.text = "$ 0.00"
            }

            if let DistanceFare:String = currentData[ "DistanceFare"] as? String {
                cell.lblMileageCost.text = DistanceFare != "" ? "$ \(DistanceFare)" : "$ 0.00"
            } else {
                cell.lblMileageCost.text = "$ 0.00"
            }

            if let WaitingTimeCost:String = currentData[ "WaitingTimeCost"] as? String {
                cell.lblTimeCost.text = WaitingTimeCost != "" ? "$ \(WaitingTimeCost)" : "$ 0.00"
            } else {
                cell.lblTimeCost.text = "$ 0.00"
            }

            if let SubTotal:String = currentData[ "SubTotal"] as? String {
                cell.lblSubTotal.text = SubTotal != "" ? "$ \(SubTotal)" : "$ 0.00"
            } else {
                cell.lblSubTotal.text = "$ 0.00"
            }

            if let AirportPickup:String = currentData[ "AirportPickUpCharge"] as? String {
                cell.lblAirportPickUpTime.text = AirportPickup != "" ? "$ \(AirportPickup)" : "$ 0.00"
            } else {
                cell.lblAirportPickUpTime.text = "$ 0.00"
            }

            if let AirportDropOff:String = currentData[ "AirportDropOffCharge"] as? String {
                cell.lblAirportDropOffTime.text = AirportDropOff != "" ? "$ \(AirportDropOff)" : "$ 0.00"
            } else {
                cell.lblAirportDropOffTime.text = "$ 0.00"
            }

            if let SoilDamageCharge:String = currentData[ "SoilDamageCharge"] as? String {
                cell.lblSoiling_Damage.text = SoilDamageCharge != "" ? "$ \(SoilDamageCharge)" : "$ 0.00"
            } else {
                cell.lblSoiling_Damage.text = "$ 0.00"
            }

            if let Discount:String = currentData[ "Discount"] as? String {
                cell.lblPromoCreditUsed.text = Discount != "" ? "$ \(Discount)" : "$ 0.00"
            } else {
                cell.lblPromoCreditUsed.text = "$ 0.00"
            }

            if let TotalPaid:String = currentData[ "GrandTotal"] as? String {
                cell.lblGrandTotal.text = TotalPaid != "" ? "$ \(TotalPaid)" : "$ 0.00"
            } else {
                cell.lblGrandTotal.text = "$ 0.00"
            }
            
            if let imgMap = currentData[ "MapUrl"] as? String {
                cell.MapImage.sd_setShowActivityIndicatorView(true)
                cell.MapImage.sd_setIndicatorStyle(.gray)
                cell.MapImage.sd_setImage(with: URL(string: imgMap.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), completed: nil)
            }
            
            if let PaymentType:String = currentData[ "PaymentType"] as? String {
                cell.lblPaymentDetail.text = "Payment By \(PaymentType) Received With Thanks"
            }
            */
            
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
    
    @objc func CancelRequest(sender: UIButton) {
        let bookingID = sender.tag
        //        let socketData = ((self.navigationController?.childViewControllers[1] as! CustomSideMenuViewController).childViewControllers[0].childViewControllers[0] as! HomeViewController).socket
        let showTopView = ((self.navigationController?.childViewControllers[1] as! CustomSideMenuViewController).childViewControllers[0].childViewControllers[0] as! HomeViewController)
        let socketData = showTopView.socket
        
        if (SingletonClass.sharedInstance.isTripContinue) {
            
            //            if (SingletonClass.sharedInstance.bookingId == String(bookingID)) {
            
            UtilityClass.setCustomAlert(title: "Your trip has started", message: "You cannot cancel this request.") { (index, title) in
            }
            
            //            }
            
        }
        else {
            if bookinType == "Book Now" {
                let myJSON = [SocketDataKeys.kBookingIdNow : bookingID] as [String : Any]
                socketData.emit(SocketData.kCancelTripByPassenger , with: [myJSON])
                
                showTopView.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                
                //                UtilityClass.showAlertWithCompletion("", message: "Your request cancelled successfully", vc: self, completionHandler: { ACTION in
                //                    self.navigationController?.popViewController(animated: true)
                //                })
                
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
                //                }
                
                
                //                UtilityClass.setCustomAlert(title: "\(appName)", message: "Your request cancelled successfully", completionHandler: { (index, title) in
                //                    self.navigationController?.popViewController(animated: true)
                //                })
            }
            else {
                let myJSON = [SocketDataKeys.kBookingIdNow : bookingID] as [String : Any]
                socketData.emit(SocketData.kAdvancedBookingCancelTripByPassenger , with: [myJSON])
                
                //                UtilityClass.showAlertWithCompletion("", message: "Your request cancelled successfully", vc: self, completionHandler: { ACTION in
                //                    self.navigationController?.popViewController(animated: true)
                //                })
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
                //                }
                //                UtilityClass.setCustomAlert(title: "\(appName)", message: "Your request cancelled successfully", completionHandler: { (index, title) in
                //                    self.navigationController?.popViewController(animated: true)
                //                })
            }
        }
    }
    
    func DelegateWithCell(CustomCell: UITableViewCell) {
        
        let SingleIndexPath = self.tableView.indexPath(for: CustomCell)
        let currentData = aryData[SingleIndexPath!.row]
        
        let ConfirmationAlert = UIAlertController(title: "", message: "Are you sure you want to cancel the trip request?", preferredStyle: UIAlertControllerStyle.alert)
        let YesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            if let bookingID = currentData[ "Id"] as? String {
                
                if let showTopView = (self.navigationController?.childViewControllers[0] as? CustomSideMenuViewController) {
                    print(showTopView.childViewControllers)
                    if let NavigationView = (showTopView.childViewControllers[0] as? UINavigationController) {
                        print(NavigationView.childViewControllers)
                        if let HomeView = NavigationView.childViewControllers[0] as? HomeViewController {
                            print(HomeView)
                            
                            let socketData = HomeView.socket
                            
                            if (SingletonClass.sharedInstance.isTripContinue) {
                                
                                UtilityClass.setCustomAlert(title: "Your trip has started", message: "You cannot cancel this request.") { (index, title) in
                                }
                            }
                            else {
                                let BookType = currentData[ "BookingType"] as! String
                                
                                if BookType == "Book Now" {
                                    let myJSON = [SocketDataKeys.kBookingIdNow : bookingID] as [String : Any]
                                    socketData.emit(SocketData.kCancelTripByPassenger , with: [myJSON])
                                    HomeView.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                                    
                                    self.navigationController?.popViewController(animated: true)
                                }
                                else {
                                    let myJSON = [SocketDataKeys.kBookingIdNow : bookingID] as [String : Any]
                                    socketData.emit(SocketData.kAdvancedBookingCancelTripByPassenger , with: [myJSON])
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                            
                        }
                        
                    }
                }
                //            ((self.navigationController?.childViewControllers[2] as! CustomSideMenuViewController).centerViewController as! HomeViewController)
                //            .childViewControllers[0].childViewControllers[0]
            }
           
        }
        
        let NoAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        ConfirmationAlert.addAction(YesAction)
        ConfirmationAlert.addAction(NoAction)
        self.present(ConfirmationAlert, animated: true, completion: nil)
       
    }
    
    
    @objc func webserviceOfBookingHistory()
    {
        if Connectivity.isConnectedToInternet() == false {
            self.refreshControl.endRefreshing()
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        webserviceForUpcomingBookingHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                self.aryData = result["history"] as! [[String:Any]]
                print(self.aryData)
                
                self.reloadDataTableView()
                self.refreshControl.endRefreshing()
                
            }
            else {
                
                print(result)
                
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: alertTitle, message: res) { (index, title) in
                    }
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.setCustomAlert(title: alertTitle, message: resDict[ "message"] as! String) { (index, title) in
                    }
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: alertTitle, message: (resAry.object(at: 0) as! NSDictionary)[ "message"] as! String) { (index, title) in
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
        dateFormatter.dateFormat = "HH:mm dd/MM/yyyy" //Specify your format that you want
        let strDate: String = dateFormatter.string(from: date)
        
        return strDate
    }
    
    func changeDateAndTimeFormate(dateAndTime: String) -> String {
        
        let time = dateAndTime // "22:02:00"
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-mm-dd HH-mm-ss"
        
        var fullDate = dateFormatter.date(from: time)
        
        dateFormatter.dateFormat = "yyyy/mm/dd HH:mm"
        
        var time2 = dateFormatter.string(from: fullDate!)
        
        return time2
    }
    
    
}
