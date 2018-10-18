//
//  SideMenuTableViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

protocol delegateForTiCKPayVerifyStatus {
    
    func didRegisterCompleted()
}

class SideMenuTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, delegateForTiCKPayVerifyStatus {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    
    var ProfileData = NSDictionary()
    
    var arrMenuIcons = [String]()
    var arrMenuTitle = [String]()
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        giveGradientColor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.SetRating), name: NSNotification.Name(rawValue: "rating"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setNewBookingOnArray), name: NotificationForAddNewBooingOnSideMenu, object: nil)
        
        if SingletonClass.sharedInstance.bookingId != "" {
            setNewBookingOnArray()
        }
        
        webserviceOfTickPayStatus()
        
        ProfileData = SingletonClass.sharedInstance.dictProfile
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.SetLayout()
        
        
        arrMenuIcons = ["icon_MyProfile_Unselected","icon_MyBooking_Unselected", "icon_PaymentOption_Unselect", "icon_Wallet_Unselected", "icon_Promocode_Unselect", "icon_Receipts_Unselected", "icon_Rating_Unselected", "icon_Favourite_Unselected", "icon_InviteFriend_Unselected", "icon_CustomerSupport_Unselect", "icon_Setting_Unselected","iconLogOut"]
        
        arrMenuTitle = ["My Profile","My Trips", "Payment Options", "Wallet", "Promo Credits", "My Receipts/Invoices", "My Ratings", "Favourites", "Invite Friends", "Customer Support", "Settings","Logout"]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        giveGradientColor()
        
        //        UIApplication.shared.isStatusBarHidden = true
        //        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
        //
    }
    
    
    @objc func SetRating() {
        self.tableView.reloadData()
    }
    
    @objc func setNewBookingOnArray() {
        
        if SingletonClass.sharedInstance.bookingId == "" {
            if (arrMenuTitle.contains("New Booking")) {
                arrMenuIcons.removeFirst()
                arrMenuTitle.removeFirst()
            }
        }
        
        if !(arrMenuTitle.contains("New Booking")) && SingletonClass.sharedInstance.bookingId != "" {
            arrMenuIcons.insert("iconNewBooking", at: 0)
            arrMenuTitle.insert("New Booking", at: 0)
        }
        
        self.tableView.reloadData()
    }
    
    func giveGradientColor() {
        
        let colorTop =  UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        let colorMiddle =  UIColor(red: 36/255, green: 24/255, blue: 3/255, alpha: 0.5).cgColor
        let colorBottom = UIColor(red: 64/255, green: 43/255, blue: 6/255, alpha: 0.8).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorMiddle, colorBottom]
        gradientLayer.locations = [ 0.0, 0.5, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenuIcons.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (indexPath.row == self.arrMenuIcons.count - 1 )
        {
            let LogoutCell = tableView.dequeueReusableCell(withIdentifier: "LogoutTblCell") as! UITableViewCell
            
            return LogoutCell
        }
        else
        {
            let cellMenu = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell") as! ContentTableViewCell
            
            cellMenu.imgDetail?.image = UIImage.init(named:  "\(arrMenuIcons[indexPath.row])")
            cellMenu.selectionStyle = .none
            
            cellMenu.lblTitle.text = arrMenuTitle[indexPath.row]
            
            return cellMenu
        }
        
        
        // Configure the cell...
        
        //        return cellHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrMenuTitle[indexPath.row] == "My Profile" {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
        else if arrMenuTitle[indexPath.row] == "My Trips" {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "MyBookingViewController") as! MyBookingViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
        else if arrMenuTitle[indexPath.row] == "Payment Options" {
            if SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0 {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
                self.navigationController?.pushViewController(next, animated: true)
            }
            else {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
                self.navigationController?.pushViewController(next, animated: true)
            }
        }
        else if arrMenuTitle[indexPath.row] == "Wallet" {
            
            if (SingletonClass.sharedInstance.isPasscodeON) {
                
                if SingletonClass.sharedInstance.setPasscode == "" {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SetPasscodeViewController") as! SetPasscodeViewController
                    viewController.strStatusToNavigate = "Wallet"
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                else {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
                    viewController.strStatusToNavigate = "Wallet"
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            else {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
                self.navigationController?.pushViewController(next, animated: true)
            }
        }
        else if arrMenuTitle[indexPath.row] == "Promo Credits" {
            
            
        }
        else if arrMenuTitle[indexPath.row] == "My Receipts/Invoices" {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "MyReceiptsViewController") as! MyReceiptsViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
        else if arrMenuTitle[indexPath.row] == "My Ratings" {
            
            
        }
        else if arrMenuTitle[indexPath.row] == "Favourites" {
         
            let next = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
            var homeVC : HomeViewController!
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: CustomSideMenuViewController.self) {
                    homeVC = (controller.childViewControllers[0] as! UINavigationController).childViewControllers[0] as? HomeViewController
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
            next.delegateForFavourite = homeVC.self as? FavouriteLocationDelegate!
            self.navigationController?.pushViewController(next, animated: true)
        }
        else if arrMenuTitle[indexPath.row] == "Invite Friends" {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "InviteDriverViewController") as! InviteDriverViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
        else if arrMenuTitle[indexPath.row] == "Settings" {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "SettingPasscodeVC") as! SettingPasscodeVC
            self.navigationController?.pushViewController(next, animated: true)
        }
        else if (arrMenuTitle[indexPath.row] == "Logout")
        {
            self.performSegue(withIdentifier: "unwindToContainerVC", sender: self)
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            
            UserDefaults.standard.removeObject(forKey: "Passcode")
            SingletonClass.sharedInstance.setPasscode = ""
            
            UserDefaults.standard.removeObject(forKey: "isPasscodeON")
            SingletonClass.sharedInstance.isPasscodeON = false
            
        }
}


func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (indexPath.row == self.arrMenuIcons.count - 1)
    {
        return 80
    }
    else
    {
        return 42
    }
}

func didRegisterCompleted() {
    
    webserviceOfTickPayStatus()
}

//-------------------------------------------------------------
// MARK: - Custom Methods
//-------------------------------------------------------------

func navigateToTiCKPay() {
    //        webserviceOfTickPayStatus()
    
    if self.varifyKey == 0 {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "TickPayRegistrationViewController") as! TickPayRegistrationViewController
        next.delegateForVerifyStatus = self
        self.navigationController?.pushViewController(next, animated: true)
    }
        
    else if self.varifyKey == 1 {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "TiCKPayNeedToVarifyViewController") as! TiCKPayNeedToVarifyViewController
        self.navigationController?.pushViewController(next, animated: true)
    }
        
    else if self.varifyKey == 2 {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "PayViewController") as! PayViewController
        self.navigationController?.pushViewController(next, animated: true)
    }
}


func SetLayout(){
    
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.width / 2
    self.imgProfile.layer.borderWidth = 1.0
    self.imgProfile.layer.borderColor = UIColor.white.cgColor
    self.imgProfile.layer.masksToBounds = true
    
    self.imgProfile.sd_setImage(with: URL(string: ProfileData.object(forKey: "Image") as! String), completed: nil)
    self.lblName.text = ProfileData.object(forKey: "Fullname") as? String
    
    self.lblMobileNumber.text = ProfileData.object(forKey: "Email") as? String
    
}


//-------------------------------------------------------------
// MARK: - Webservice Methods
//-------------------------------------------------------------

var varifyKey = Int()
func webserviceOfTickPayStatus() {
    
    webserviceForTickpayApprovalStatus(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
        
        if (status) {
            print(result)
            
            if let id = (result as! [String:AnyObject])["Verify"] as? String {
                
                //                    SingletonClass.sharedInstance.TiCKPayVarifyKey = Int(id)!
                self.varifyKey = Int(id)!
            }
            else if let id = (result as! [String:AnyObject])["Verify"] as? Int {
                
                //                    SingletonClass.sharedInstance.TiCKPayVarifyKey = id
                self.varifyKey = id
            }
            
        }
        else {
            print(result)
        }
    }
}

}


