//
//  MyRatingsViewController.swift
//  EZYGO Rider
//
//  Created by EWW-iMac Old on 23/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class MyRatingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var arrFeedbacks:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        webserviewOfGetFeedbackList()
        
        
        // Do any additional setup after loading the view.
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
        return arrFeedbacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let Feedbackcell = tableView.dequeueReusableCell(withIdentifier: "MyRatingTableViewCell") as! MyRatingTableViewCell
        
        Feedbackcell.selectionStyle = .none
        let dictData = self.arrFeedbacks[indexPath.row] as [String:Any]
        
        if let DriverName:String = dictData["DriverName"] as? String {
            Feedbackcell.lblDriverName.text = DriverName
        }
     
        if let DriverRate:Double = Double(dictData["Rating"] as! String) {
            Feedbackcell.RatingView.rating = Float(DriverRate)
        }
        
        if let FromLocation = dictData["PickupLocation"] as? String {
            Feedbackcell.lblFromLocation.text = FromLocation
        }
        
        if let ToLocation = dictData["DropoffLocation"] as? String {
            Feedbackcell.lblToLocation.text = ToLocation
        }
        
        if let Dates = dictData["Date"] as? String {
            let fulldate = Dates.components(separatedBy: " ")
            Feedbackcell.lblRideDate.text = fulldate[0]
        }
        
        if let imgDriver = dictData["DriverImage"] as? String {
            Feedbackcell.imgProfile.sd_setShowActivityIndicatorView(true)
            Feedbackcell.imgProfile.sd_setIndicatorStyle(.gray)
            Feedbackcell.imgProfile.sd_setImage(with: URL(string:"\(WebserviceURLs.kImageBaseURL)/\(imgDriver)"), completed: nil)
        }
        
        return Feedbackcell
    }
    
    
    func webserviewOfGetFeedbackList() {
        webserviceForFeedbackList(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            if (status) {
                print(result)
                self.arrFeedbacks = (result as! [String:Any])["feedback"] as! [[String:Any]]
                self.tableView.reloadData()
            }
            else {
                print(result)
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: "Error", message: res) { (index, title) in
                    }
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.setCustomAlert(title: "Error", message: resDict.object(forKey: "message") as! String) { (index, title) in
                    }
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: "Error", message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                }
            }
        }
    }
    
    

}
