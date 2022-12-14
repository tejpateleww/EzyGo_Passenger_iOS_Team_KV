//
//  PromoCreditViewController.swift
//  EZYGO Rider
//
//  Created by EWW-iMac Old on 23/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class PromoCreditViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblCurrentBalance: UILabel!
    
    var arrPromoCodes:[[String:Any]] = []
    var counts = Int()
    var messages = String()
    @IBOutlet weak var lblOfferTitle: UILabel!
    
    @IBOutlet weak var lblNoDataFound: UILabel!
    
    
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
        
        self.lblOfferTitle.isHidden = true
        self.lblNoDataFound.isHidden = true
        
//        self.lblCurrentBalance.text = "\(currencySign)\(String(format: "%.2f", SingletonClass.sharedInstance.strCurrentBalance))"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        webserviewOfGetPromocodeList()
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.tableView.addSubview(self.refreshControl)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        webserviewOfGetPromocodeList()
        
        tableView.reloadData()
        refreshControl.endRefreshing()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Navigation Bar Button Action
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnCallAction(_ sender: UIButton) {
        
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
    
    
    //-------------------------------------------------------------
    // MARK: - TableView Methods
    //-------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPromoCodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let Promocodecell = tableView.dequeueReusableCell(withIdentifier: "PromoCreditTableViewCell") as! PromoCreditTableViewCell
        
        Promocodecell.selectionStyle = .none
        let dictData = self.arrPromoCodes[indexPath.row] as [String:Any]
        let type = dictData["DiscountType"] as! String
        switch type {
        case "flat":
            if let FlatValue:String = dictData["DiscountValue"] as? String {
                Promocodecell.lblBenefit.text = " $\(FlatValue) OFF "
            }
        case "percent":
            if let PercentValue:String = dictData["DiscountValue"] as? String {
                Promocodecell.lblBenefit.text = " \(PercentValue)% OFF "
            }
        default:
            break
        }
        
        if let PromoCodeValue:String = dictData["PromoCode"] as? String {
            Promocodecell.lblPromoCode.text = PromoCodeValue
        }
        
        if let ExpiryDateValue:String = dictData["EndDate"] as? String {
            Promocodecell.lblExpiryDate.text = "Expiry Date:-\(ExpiryDateValue)"
        }
        
        if let DescriptionValue:String = dictData["Description"] as? String {
            Promocodecell.lblDescription.text = DescriptionValue
        }
        
        return Promocodecell
    }
    
    
    func webserviewOfGetPromocodeList() {
        if Connectivity.isConnectedToInternet() == false {
            self.lblNoDataFound.isHidden = false
            self.lblOfferTitle.isHidden = true
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        webserviceForPromoCodeList { (result, status) in
            if (status) {
                print(result)
                if let promocode = (result as! [String:Any])["promocode_list"] as? [[String:Any]] {
                self.arrPromoCodes = promocode
                }
               
                if self.arrPromoCodes.count == 0 {
                    self.lblNoDataFound.isHidden = false
                    self.lblOfferTitle.isHidden = true
                } else {
                    self.lblNoDataFound.isHidden = true
                    self.lblOfferTitle.isHidden = false
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
    
    
}
