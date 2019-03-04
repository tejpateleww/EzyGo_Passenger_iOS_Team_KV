//
//  MyReceiptsViewController.swift
//  TickTok User
//
//  Created by Excelent iMac on 13/12/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import MessageUI

class MyReceiptsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, FilterReceiptDelegate,ReceiptInvoiceDelegate {
    
    
    var aryData:[[String:Any]] = []
    var urlForMail = String()
    var messages = String()
    var expandedCellPaths = Set<IndexPath>()
    
    var labelNoData = UILabel()
    
    var PageLimit:Int = 10
    var NeedToReload:Bool = false
    var PageNumber:Int = 1
    
    var ReceiptID:String = ""
    var startDate:String = ""
    var endDate:String = ""
    
    @IBOutlet weak var lblNoDatafound: UILabel!
    
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        self.lblNoDatafound.isHidden = true
        //        labelNoData = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        //        self.labelNoData.text = "Loading..."
        //        labelNoData.textAlignment = .center
        //        self.view.addSubview(labelNoData)
        //        self.tableView.isHidden = true
        
        //       webserviewOfMyReceipt()
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.tableView.addSubview(self.refreshControl)
        self.ReloadNewData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.startDate = ""
        self.endDate = ""
        self.ReceiptID = ""
        self.ReloadNewData()
        //        webserviewOfMyReceipt()
        //
        //        tableView.reloadData()
        //        refreshControl.endRefreshing()
        
    }
    
    @objc func ReloadNewData(){
        self.PageNumber = 1
        self.NeedToReload = false
        self.aryData.removeAll()
        self.tableView.reloadData()
        self.webserviewOfMyReceipt()
    }
    
    func reloadMoreHistory() {
        self.PageNumber += 1
        self.webserviewOfMyReceipt()
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func btnCall(_ sender: Any) {
        
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
    
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func btnFilter(_ sender: Any) {
        if self.arrFilteredData.count == 0 {
            UtilityClass.setCustomAlert(title: "", message: "There is no data available to filter.") { (index, title) in
            }
            return
        }
        let TripViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReceiptFilterViewController") as! ReceiptFilterViewController
        TripViewController.FilterDelegate = self
        self.present(TripViewController, animated: true, completion: nil)
        //        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(TripViewController, animated: true, completion: nil)
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet var tableView: UITableView!
    
    
    //-------------------------------------------------------------
    // MARK: - Table View Methods
    //-------------------------------------------------------------
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrFilteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRecepitTableViewCell") as! MyRecepitTableViewCell
        cell.selectionStyle = .none
        cell.Delegate = self
        let dictData = self.arrFilteredData[indexPath.row]
        
        
        //        if dictData["HistoryType"] as! String == "Past" {
        //
        //            if dictData["Status"] as! String == "completed" {
        
        cell.btnGetReceipt.layer.cornerRadius = 5
        cell.btnGetReceipt.layer.masksToBounds = true
        
        cell.lblDriversNames.text = dictData["DriverName"] as? String
        
        cell.lblDropLocationDescription.text = dictData["DropoffLocation"] as? String
        cell.lblDateAndTime.text = dictData["CreatedDate"] as? String
        
        cell.lblPickUpLocationDescription.text = dictData["PickupLocation"] as? String
        //                if let Model = dictData["Model"] as? String {
        //                    cell.lblVehicleType.text =  Model
        //                }
        cell.StackVehicleType.isHidden = true
        
        if let Distance = dictData["TripDistance"] as? String {
            if Distance != "" && String(format: "%.2f", Double(Distance)!) != "0.00" {
                cell.StackDistance.isHidden = false
                cell.lblDistanceTravelled.text = ": \(String(format: "%.2f", Double(Distance)!))km"
            } else {
                cell.StackDistance.isHidden = true
            }
        } else {
            cell.StackDistance.isHidden = true
        }
        
        if let TollFee = dictData["TollFee"] as? String {
            if TollFee != "" && String(format: "%.2f", Double(TollFee)!) != "0.00" {
                cell.StackTollFee.isHidden = false
                cell.lblTolllFee.text = ": \(currencySign)\(String(format: "%.2f", Double(TollFee)!))"
            } else {
                cell.StackTollFee.isHidden = true
            }
        } else {
            cell.StackTollFee.isHidden = true
        }
        
        if let GrandTotal = dictData["GrandTotal"] as? String {
            if GrandTotal != ""  {
                cell.lblFareTotal.text = ": \(currencySign)\(String(format: "%.2f", Double(GrandTotal)!))"
            }
        }
        
        if let Discount = dictData["Discount"] as? String {
            if Discount != "" && String(format: "%.2f", Double(Discount)!) != "0.00" {
                cell.StackDiscount.isHidden = false
                cell.lblDiscountApplied.text = ": \(currencySign)\(String(format: "%.2f", Double(dictData["Discount"] as! String)!))"
            } else {
                cell.StackDiscount.isHidden = true
            }
        } else {
            cell.StackDiscount.isHidden = true
        }
        
        cell.lblChargedCard.text = ": \(dictData["PaymentType"] as! String)"
        //                if let GrandTotal = dictData["GrandTotal"] as? String {
        //                    if GrandTotal != "" {
        //                        self.urlForMail = GrandTotal
        //                    }
        //                }
        
        //                cell.btnGetReceipt.addTarget(self, action: #selector(self.getReceipt(sender:)), for: .touchUpInside)
        cell.viewDetails.isHidden = !self.expandedCellPaths.contains(indexPath)
        
        if self.NeedToReload == true && indexPath.row == self.aryData.count - 1  {
            self.reloadMoreHistory()
        }
        
        return cell
        //            }
        //            else {
        //                return UITableViewCell()
        //            }
        //        }
        //        else {
        //            return UITableViewCell()
        //        }
        
        
        //        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let cell = tableView.cellForRow(at: indexPath) as? MyRecepitTableViewCell {
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
    
    func didGetReceipt(customCell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: customCell)!
        let dictData = self.arrFilteredData[indexPath.row]
        if let ShareUrl = dictData["ShareUrl"] as? String {
            
            let messageBody = "\nHi there,\n\nYour Receipt/Invoice can be downloaded from the link below. \n \n \(ShareUrl)\n\nRegards\nEzygo Team"
            let activityViewController = UIActivityViewController(activityItems: [messageBody], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
            
            
        }
        
    }
    
    func didViewReceipt(customCell: UITableViewCell) {
        
        let indexPath = self.tableView.indexPath(for: customCell)!
        let dictData = self.arrFilteredData[indexPath.row]
        if let ShareUrl = dictData["ShareUrl"] as? String {
            
            
            let next = self.storyboard?.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            next.HeaderTitle = "My Receipts/Invoices"
            next.URLString = ShareUrl
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func nevigateToBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //    @objc func getReceipt(sender: UIButton) {
    //
    ////      let messageBody = "\n Please download Receipt/Invoice from link below\n \n \(urlForMail)"
    //
    //        let messageBody = "\nHi there,\n\nYour Receipt/Invoice can be downloaded from the link below. \n \n \(urlForMail)\n\nRegards\nEzygo Team"
    //        let activityViewController = UIActivityViewController(activityItems: [messageBody], applicationActivities: nil)
    //        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
    //
    //        // exclude some activity types from the list (optional)
    //        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
    //
    //        // present the view controller
    //        self.present(activityViewController, animated: true, completion: nil)
    //
    //
    //        //bianl
    ////        let emailTitle = ""
    ////        let messageBody = urlForMail
    ////        let toRecipents = [""]
    ////
    ////
    ////        if MFMailComposeViewController.canSendMail() {
    ////            let mail = MFMailComposeViewController()
    ////            mail.mailComposeDelegate = self
    ////            mail.setToRecipients(toRecipents)
    ////            mail.setMessageBody(messageBody, isHTML: true)
    ////
    ////            present(mail, animated: true)
    ////        } else {
    ////            UtilityClass.setCustomAlert(title: "Missing", message: "Please login into setting with emaild id") { (index, title) in
    ////            }
    ////        }
    ////
    //
    //    }
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
            messages = "Mail cancelled"
            //            UtilityClass.setCustomAlert(title: alertTitle, message: "Mail cancelled") { (index, title) in
        //            }
        case MFMailComposeResult.saved:
            print("Mail saved")
            messages = "Mail saved"
            //            UtilityClass.setCustomAlert(title: "Done", message: "Mail saved") { (index, title) in
        //            }
        case MFMailComposeResult.sent:
            print("Mail sent")
            messages = "Mail sent"
            //            UtilityClass.setCustomAlert(title: "Done", message: "Mail sent") { (index, title) in
        //            }
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
            messages = "Mail sent failure: \(String(describing: error?.localizedDescription))"
            //            UtilityClass.setCustomAlert(title: alertTitle, message: "Mail sent failure: \(String(describing: error?.localizedDescription))") { (index, title) in
        //      }
        default:
            messages = "Something went wrong"
            //            UtilityClass.setCustomAlert(title: alertTitle, message: "Something went wrong") { (index, title) in
            //            }
            break
        }
        
        controller.dismiss(animated: true) {
            self.mailAlert(strMsg: self.messages)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        switch result {
        case MessageComposeResult.cancelled:
            print("Mail cancelled")
            
            //            UtilityClass.setCustomAlert(title: alertTitle, message: "Mail cancelled") { (index, title) in
            //            }
            messages = "Mail cancelled"
        case MessageComposeResult.sent:
            print("Mail sent")
            
            //            UtilityClass.setCustomAlert(title: "Done", message: "Mail sent") { (index, title) in
            //            }
            messages = "Mail sent"
        case MessageComposeResult.failed:
            print("Mail sent failure")
            messages = "Mail sent failure"
        //            UtilityClass.showAlert("", message: "Mail sent failure: \(String(describing: error?.localizedDescription))", vc: self)
        default:
            //            UtilityClass.showAlert("", message: "Something went wrong", vc: self)
            //            UtilityClass.setCustomAlert(title: alertTitle, message: "Something went wrong") { (index, title) in
            //            }
            messages = "Something went wrong"
            break
        }
        controller.dismiss(animated: true) {
            self.mailAlert(strMsg: self.messages)
        }
    }
    
    
    func mailAlert(strMsg: String) {
        
        UtilityClass.setCustomAlert(title: appName, message: strMsg) { (index, title) in
        }
    }
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    var newAryData:[[String:Any]] = []
    var arrFilteredData:[[String:Any]] = []
    
    func webserviewOfMyReceipt() {
        
        if Connectivity.isConnectedToInternet() == false {
            self.lblNoDatafound.isHidden = false
            self.refreshControl.endRefreshing()
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        
        let dictParams = NSMutableDictionary()
        dictParams.setObject(SingletonClass.sharedInstance.strPassengerID, forKey: "PassengerId" as NSCopying)
        if PageNumber != 0 {
            dictParams.setObject(PageNumber, forKey: "Page" as NSCopying)
        }
        
        if startDate != "" {
            dictParams.setObject(startDate, forKey: "StartBookingDate" as NSCopying)
        }
        
        if endDate != "" {
            dictParams.setObject(endDate, forKey: "EndBookingDate" as NSCopying)
        }
        
        if ReceiptID != "" {
            dictParams.setObject(ReceiptID, forKey: "BookingId" as NSCopying)
        }
        
        if PageNumber == 1 {
            self.aryData.removeAll()
            self.arrFilteredData = self.aryData
            self.tableView.reloadData()
        }
        
        webserviceForBookingHistory(dictParams as AnyObject) { (result, status) in
            
            if (status) {
                //                self.aryData = (result as! [String:Any])["history"] as! [[String:Any]]
                //                self.newAryData = []
                
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
                
                self.refreshControl.endRefreshing()
                //                let DatePredicate = NSPredicate(format: "%K == %@ AND %K == %@", "HistoryType", "Past", "Status", "completed")
                //                self.newAryData = self.aryData.filter({ return DatePredicate.evaluate(with: $0)})
                
                
                //                for i in 0..<self.aryData.count {
                //
                //                    let dictData = self.aryData[i]
                //
                //                    if dictData["HistoryType"] as! String == "Past" {
                //
                //                        if dictData["Status"] as! String == "completed" {
                //                            self.counts += 1
                //                            self.newAryData.add(self.aryData[ i] as! NSDictionary)
                //                        }
                //                    }
                //                }
                self.arrFilteredData = self.aryData
                if self.arrFilteredData.count != 0 {
                    self.lblNoDatafound.isHidden = true
                } else {
                    self.lblNoDatafound.isHidden = false
                }
                
                self.tableView.reloadData()
                
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
    
    //    @IBAction func btnViewReceiptInventory(_ sender: UIButton) {
    //        let next = self.storyboard?.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
    //        next.HeaderTitle = "My Receipts/Invoices"
    //        next.URLString = urlForMail
    //        self.navigationController?.pushViewController(next, animated: true)
    ////        let messageBody = "\n Please download from below link \n \n \(urlForMail)"
    ////
    ////
    ////        let activityViewController = UIActivityViewController(activityItems: [messageBody], applicationActivities: nil)
    ////        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
    ////
    ////        // exclude some activity types from the list (optional)
    ////        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
    ////
    ////        // present the view controller
    ////        self.present(activityViewController, animated: true, completion: nil)
    //
    //
    //    }
    
    
    // Filter Delegate Methods
    
    func filterByBookId(BookingId: String) {
        self.startDate = ""
        self.endDate = ""
        self.PageNumber = 1
        self.ReceiptID = BookingId
        self.webserviewOfMyReceipt()
        
        //        let DatePredicate = NSPredicate(format: "%K == %@", "Id", BookingId)
        //        let tempArr = self.newAryData.filter({ return DatePredicate.evaluate(with: $0)})
        //        self.arrFilteredData = tempArr
        //        self.tableView.reloadData()
    }
    
    func filterByDate(FromDate: Date, ToDate: Date) {
        //    func filterByDate(FromDate: String, ToDate: String) {
        self.startDate = ""
        self.endDate = ""
        self.ReceiptID = ""
        self.PageNumber = 1
        //        self.webserviewOfMyReceipt()
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "dd-MM-yyyy"
        //
        myDateFormatter.locale = Locale(identifier: Locale.current.identifier)
        
        self.startDate = "\(myDateFormatter.string(from: FromDate))"
        self.endDate = "\(myDateFormatter.string(from: ToDate))"
        self.webserviewOfMyReceipt()
        //
        //
        //        let FilterDateFormatter: DateFormatter = DateFormatter()
        //        FilterDateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        //        FilterDateFormatter.locale = Locale(identifier: Locale.current.identifier)
        //        let startDate = FilterDateFormatter.date(from: FromDateString)
        //        let endDate = FilterDateFormatter.date(from: ToDateString)
        //
        //        var FinalArr:[[String:Any]] = []
        //        for SingleReceipt in self.newAryData {
        //            if let ReceiptDate:String = SingleReceipt["CreatedDate"] as? String {
        //                let receiptDate = FilterDateFormatter.date(from: ReceiptDate)
        //                if receiptDate?.compare(startDate!) == .orderedDescending && receiptDate?.compare(endDate!) == .orderedAscending {
        //                    FinalArr.append(SingleReceipt)
        //                }
        //            }
        //        }
        
        //        let FilterDateFormatter: DateFormatter = DateFormatter()
        //        FilterDateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        //
        ////        let startDate = FilterDateFormatter.date(from: FromDateString)
        ////        let endDate = FilterDateFormatter.date(from: ToDateString)
        //
        //        var FinalArr:[[String:Any]] = []
        //        for SingleReceipt in self.newAryData {
        //            if let ReceiptDate:String = SingleReceipt["CreatedDate"] as? String {
        ////                let receiptDate = FilterDateFormatter.date(from: ReceiptDate)
        //                if ReceiptDate >= FromDateString && ReceiptDate <= ToDateString {
        //                    FinalArr.append(SingleReceipt)
        //                }
        //            }
        //        }
        //
        
        
        /*
         let DatePredicate = NSPredicate(format: "(CreatedDate >= %@) AND (CreatedDate <= %@)", argumentArray: [FromDate,ToDate])
         //            NSPredicate(format: "CreatedDate >= %@ AND CreatedDate <= %@",FromDateString, ToDateString)
         //        let GreaterDatePredicate = NSPredicate(format: "%K >= %@", "CreatedDate", FromDateString)
         //        let LessDatePredicate = NSPredicate(format: "%K <= %@", "CreatedDate", ToDateString)
         //        let tempArr = self.newAryData.filter { ($0["CreatedDate"] ?? "") > nowString }
         //            self.newAryData.filter({ return GreaterDatePredicate.evaluate(with: $0)})
         let FinalArr = self.newAryData.filter{ DatePredicate.evaluate(with: $0) }
         //            tempArr.filter({ return LessDatePredicate.evaluate(with: $0)})
         */
        //        self.arrFilteredData = FinalArr
        //        self.tableView.reloadData()
        
    }
    
}

