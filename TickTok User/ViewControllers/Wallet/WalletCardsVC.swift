//
//  WalletCardsVC.swift
//  TiCKTOC-Driver
//
//  Created by Excelent iMac on 23/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

@objc protocol AddCadsDelegate {
    
    func didAddCard(cards: NSArray)
}

class WalletCardsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, AddCadsDelegate, DeleteCardDelegate {

    
    weak var delegateForTopUp: SelectCardDelegate!
    weak var delegateForTransferToBank: SelectBankCardDelegate!
    
    var aryData = [[String:AnyObject]]()
    var isFromHomeVC:Bool = false
    var isNextPageAddCard:Bool = false
    
    @IBOutlet weak var lblNoData: UILabel!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = themeYellowColor
        
        return refreshControl
    }()
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func loadView() {
        super.loadView()
        
        if SingletonClass.sharedInstance.isCardsVCFirstTimeLoad {
//            webserviceOFGetAllCards()
            
            if SingletonClass.sharedInstance.CardsVCHaveAryData.count != 0 {
                aryData = SingletonClass.sharedInstance.CardsVCHaveAryData
            }
            else {
                webserviceOFGetAllCards()
            }
        }
        else {
            
            if self.isNextPageAddCard == true && SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0 {
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
                    self.navigationController?.pushViewController(next, animated: false)
                return
            }
            
            if SingletonClass.sharedInstance.CardsVCHaveAryData.count != 0 {
                aryData = SingletonClass.sharedInstance.CardsVCHaveAryData
            }
            else {
//                let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
//                next.delegateAddCard = self
//                self.navigationController?.pushViewController(next, animated: true)
            }
        }
        
        if self.aryData.count > 0 {
            self.lblNoData.isHidden = true
        } else {
            self.lblNoData.isHidden = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        self.tableView.addSubview(self.refreshControl)

        if(isFromHomeVC)
        {
            self.moveToAddCard()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
   
    func setImageColorOfImage(name: String) -> UIImage {
        
        var imageView = UIImageView()
        let img = UIImage(named: name)
        imageView.image = img?.maskWithColor(color: UIColor.white)
        
        
        return imageView.image!
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var tableView: UITableView!
   
    
    @IBOutlet weak var btnAddCards: UIButton!
    //-------------------------------------------------------------
    // MARK: - TableView Methods
    //-------------------------------------------------------------
    
//    @IBAction func btnAddCards(_ sender: UIButton) {
//        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
//        next.delegateAddCard = self
//        self.navigationController?.pushViewController(next, animated: true)
//
//    }
    
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return aryData.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCardsTableViewCell") as! WalletCardsTableViewCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "AddCard") as! WalletCardsTableViewCell
        
        cell.selectionStyle = .none
        cell2.selectionStyle = .none
        
        if indexPath.section == 0 {
            
            let dictData = aryData[indexPath.row] as [String:AnyObject]
//["Expiry": 02/20,"CardNum2": xxxx xxxx xxxx 4242,"Id": 64,"Type": visa,"Alias":,"CardNum": 4242424242424242]
//            cell.lblCardType.text = "Credit Card"
            
            let expiryDate = (dictData["Expiry"] as! String)
//                .split(separator: "/")
//            let month = expiryDate.first
//            let year = expiryDate.last
//            cell.lblMonthExpiry.text = "\(String(describing: month!))/\(String(describing: year!))"
            cell.lblMonthExpiry.text = expiryDate
//            cell.lblYearExpiry.text = String(describing: year!)
            
            cell.viewCards.layoutIfNeeded()
            cell.viewCards.dropShadowToCardView(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true)
            cell.viewCards.layer.cornerRadius = 5
            cell.viewCards.layer.masksToBounds = true

            
            let type = dictData["Type"] as! String
            
            cell.imgCardIcon.image = UIImage(named: setCreditCardImage(str: type))

//                cell.viewCards.backgroundColor = UIColor.orange
//                cell.lblBankName.text = dictData["Alias"] as? String
                cell.lblCardNumber.text = dictData["CardNum2"] as? String
//                cell.imgCardIcon.image = UIImage(named: "MasterCard")

            if type == "discover" || type == "mastercard" {
                // orange
            }
            else if type == "diners" {
                // gray
            }
//            else {
//                //
//            }
//
//            let colorTop =  UIColor(red: 78/255, green: 202/255, blue:237, alpha: 1.0).cgColor
//            let colorMiddle =  UIColor(red: 187/255, green: 241/255, blue: 239/255, alpha: 0.5).cgColor
////            let colorBottom = UIColor(red: 64/255, green: 43/255, blue: 6/255, alpha: 0.8).cgColor
//
//            let gradientLayer = CAGradientLayer()
//            gradientLayer.colors = [colorTop, colorMiddle]
//            gradientLayer.locations = [ 0.0, 0.5]
//            gradientLayer.frame = self.view.bounds
//            cell.viewCards.layer.insertSublayer(gradientLayer, at: 0)
//
            
         /*
          //   visa , mastercard , amex , diners , discover , jcb , other
             
            if (indexPath.row % 2) == 0 {
                cell.viewCards.backgroundColor = UIColor.orange
                cell.lblCardNumber.text = "**** **** **** 1081"
                cell.imgCardIcon.image = UIImage(named: "MasterCard")
            }
            else {
                cell.viewCards.backgroundColor = UIColor.init(red: 0, green: 145/255, blue: 147/255, alpha: 1.0)
                cell.lblCardNumber.text = "**** **** **** 9964"
                cell.imgCardIcon.image = UIImage(named: "Visa")
                
            }
          */
            cell.Delegate = self
            return cell
        }
        else {
            
//            let img = UIImage(named: "iconArrowGrey")
//            cell2.btnArrow.image = img?.maskWithColor(color: themeYellowColor)
            return cell2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 0 {
         
            let selectedData = aryData[indexPath.row] as [String:AnyObject]
            
            print("selectedData : \(selectedData)")
            
            if SingletonClass.sharedInstance.isFromTopUP {
                delegateForTopUp.didSelectCard(dictData: selectedData)
                SingletonClass.sharedInstance.isFromTopUP = false
                self.navigationController?.popViewController(animated: true)
            }
            else if SingletonClass.sharedInstance.isFromTransferToBank {
                delegateForTransferToBank.didSelectBankCard(dictData: selectedData)
                SingletonClass.sharedInstance.isFromTransferToBank = false
                self.navigationController?.popViewController(animated: true)
            }
            
        }
//        else if indexPath.section == 1 {
//
//            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
//            next.delegateAddCard = self
//            self.navigationController?.pushViewController(next, animated: true)
//        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 164
        }
        else {
            return 75
        }
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        let selectedData = aryData[indexPath.row] as [String:AnyObject]
//
//        if editingStyle == .delete {
//
//            let selectedID = selectedData["Id"] as? String
//
//            tableView.beginUpdates()
//            aryData.remove(at: indexPath.row)
//            webserviceForRemoveCardFromWallet(cardId : selectedID!)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            tableView.endUpdates()
//        }
//
//    }
   
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnBack(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }

    @IBAction func btnAddCards(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
        
        next.delegateAddCard = self
        self.navigationController?.pushViewController(next, animated: true)
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        webserviceOFGetAllCards()
        
        if self.aryData.count > 0 {
            self.lblNoData.isHidden = true
        } else {
            self.lblNoData.isHidden = false
        }
        
        tableView.reloadData()
    }
    
    func setCreditCardImage(str: String) -> String {
        
        //   visa , mastercard , amex , diners , discover , jcb , other
        
        var strType = String()
        
        if str == "visa" {
            strType = "c_visa"
        }
        else if str == "mastercard" {
            strType = "c_master"
        }
        else if str == "amex" {
            strType = "Amex"
        }
        else if str == "diners" {
            strType = "Diners Club"
        }
        else if str == "discover" {
            strType = "c_discover"
        }
        else if str == "jcb" {
            strType = "JCB"
        }
        else {
            strType = "iconDummyCard"
        }
        
        return strType
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Add Cads Delegate Methods
    //-------------------------------------------------------------
    
    func didAddCard(cards: NSArray) {
        
        aryData = cards as! [[String:AnyObject]]
        
        if self.aryData.count > 0 {
            self.lblNoData.isHidden = true
        } else {
            self.lblNoData.isHidden = false
        }
        
        tableView.reloadData()
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
    
    //-------------------------------------------------------------
    // MARK: - Delete Cards Delegate Methods
    //-------------------------------------------------------------

    func DeleteCard(CustomCell: UITableViewCell) {
        
        let ConfirmationAlert = UIAlertController(title: "", message: "Are you sure you want to delete this card?", preferredStyle: UIAlertControllerStyle.alert)
        let YesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            if let CardIndexpath:IndexPath = self.tableView.indexPath(for: CustomCell) {
                
                let selectedCard = self.aryData[CardIndexpath.row]
                let selectedID = selectedCard["Id"] as? String
                
                //            tableView.beginUpdates()
                //            aryData.remove(at: indexPath.row)
                self.webserviceForRemoveCardFromWallet(cardId : selectedID!,selectedCardIndex: CardIndexpath.row)
                //            tableView.deleteRows(at: [CardIndexpath], with: .fade)
                //            tableView.endUpdates()
                
            }
        }
        
        let NoAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        ConfirmationAlert.addAction(YesAction)
        ConfirmationAlert.addAction(NoAction)
        self.present(ConfirmationAlert, animated: true, completion: nil)
        
    }
    
   
    //-------------------------------------------------------------
    // MARK: - Webservice Methods For All Cards
    //-------------------------------------------------------------
    
    func webserviceOFGetAllCards() {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        webserviceForCardList(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
        
       
            if (status) {
                print(result)
                
                self.aryData = (result as! NSDictionary).object(forKey: "cards") as! [[String:AnyObject]]
                
                SingletonClass.sharedInstance.CardsVCHaveAryData = self.aryData
                
                SingletonClass.sharedInstance.isCardsVCFirstTimeLoad = false
                
                if self.aryData.count > 0 {
                    self.lblNoData.isHidden = true
                } else {
                    self.lblNoData.isHidden = false
                }
                
                self.tableView.reloadData()
                

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


    func moveToAddCard()
    {
        if SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0 {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
            next.delegateAddCard = self
            self.navigationController?.pushViewController(next, animated: false)
        }

    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods Remove Cards
    //-------------------------------------------------------------
    
    
    
    func webserviceForRemoveCardFromWallet(cardId : String, selectedCardIndex:Int) {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        var params = String()
        params = "\(SingletonClass.sharedInstance.strPassengerID)/\(cardId)"

        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        webserviceForRemoveCard(params as AnyObject) { (result, status) in
        
            if (status) {
                
                print(result)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self.aryData = (result as! NSDictionary).object(forKey: "cards") as! [[String:AnyObject]]
                
                SingletonClass.sharedInstance.CardsVCHaveAryData = self.aryData
                
                SingletonClass.sharedInstance.isCardsVCFirstTimeLoad = false
                
                // Post notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CardListReload"), object: nil)
                
//                if SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0 {
//
//                    self.navigationController?.popViewController(animated: true)
//                }
                
                if self.aryData.count > 0 {
                    self.lblNoData.isHidden = true
                } else {
                    self.lblNoData.isHidden = false
                }
                
                self.tableView.reloadData()
                
                UtilityClass.setCustomAlert(title: "Removed", message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                }
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

extension UIView {
    
    func dropShadowToCardView(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

