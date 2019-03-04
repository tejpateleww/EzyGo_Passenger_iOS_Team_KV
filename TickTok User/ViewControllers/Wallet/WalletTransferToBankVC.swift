//
//  WalletTransferToBankVC.swift
//  TiCKTOC-Driver
//
//  Created by Excelent iMac on 23/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift

@objc protocol SelectBankCardDelegate {
    
    func didSelectBankCard(dictData: [String: AnyObject])
}


protocol WalletTransferDelegate {
    func GotoHistory()
}


class WalletTransferToBankVC: ParentViewController, SelectBankCardDelegate {

    
    
    var strCardId = String()
    var strAmt = String()
    var Delegate:WalletTransferDelegate!
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setData()

        
        headerView?.btnBack.addTarget(self, action: #selector(self.btnBackAction), for: .touchUpInside)
        
        viewMain.layer.cornerRadius = 5
        viewMain.layer.masksToBounds = true
        
//        btnWithdrawFunds.layer.cornerRadius = 5
//        btnWithdrawFunds.layer.masksToBounds = true
      
//        lblCurrentBalanceTitle.text = "\(currencySign)\(String(format: "%.2f", SingletonClass.sharedInstance.strCurrentBalance))"
        
        var BalanceString = String(format: "%.2f", SingletonClass.sharedInstance.strCurrentBalance)
        if (SingletonClass.sharedInstance.strCurrentBalance < 0) {
            BalanceString.remove(at: BalanceString.startIndex)
        }
        self.lblCurrentBalanceTitle.text =  (SingletonClass.sharedInstance.strCurrentBalance < 0) ? "-\(currencySign)\(BalanceString)" : "\(currencySign)\(BalanceString)"
        
//        "\(currencySign)\(SingletonClass.sharedInstance.strCurrentBalance)"
        
        
        txtAmount.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
         
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.txtAmount.setCurrencyLeftView()
//        txtAccountHolderName.lineColor = .black
//        txtABN.lineColor = .black
//        txtBankName.lineColor = .black
//        txtBankAccountNo.lineColor = .black
//        txtBSB.lineColor = .black
    }
    
    @objc func btnBackAction() {
        
        if isModal() {
            self.dismiss(animated: true, completion: {
                
            })
            
        }
        else {
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    override func isModal() -> Bool {
        if (presentingViewController != nil) {
            return true
        }
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        if (tabBarController?.presentingViewController is UITabBarController) {
            return true
        }
        return false
    }
    
    func clearTextFields() {
        txtAccountHolderName.text = ""
//        txtABN.text = ""
        txtBankName.text = ""
        txtBankAccountNo.text = ""
        txtBSB.text = ""
        strAmt = ""
    }

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var lblCardTitle: UILabel!
    @IBOutlet weak var lblCurrentBalanceTitle: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var btnWithdrawFunds: UIButton!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnCardTitle: UIButton!
    @IBOutlet weak var txtAccountHolderName: ACFloatingTextfield!
    @IBOutlet weak var txtABN: ACFloatingTextfield!
    @IBOutlet weak var txtBankName: ACFloatingTextfield!
    @IBOutlet weak var txtBankAccountNo: ACFloatingTextfield!
    @IBOutlet weak var txtBSB: ACFloatingTextfield!
    
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnCardTitle(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
        SingletonClass.sharedInstance.isFromTransferToBank = true
        next.delegateForTransferToBank = self
        self.navigationController?.pushViewController(next, animated: true)
        
    }
    
    @IBAction func btnWithdrawFunds(_ sender: UIButton) {
        
        if (validationOfTransferToBank()) {
        
            webserviceOfTransferToBank()
        }
    }
    
    func setData() {
        
        let profileData = SingletonClass.sharedInstance.dictProfile
//        txtNote.text = profileData.object(forKey: "Description") as? String
//        txtABN.text = profileData.object(forKey: "ABN") as? String
        txtBSB.text = profileData.object(forKey: "BSB") as? String
        txtBankName.text = profileData.object(forKey: "BankName") as? String
        txtBankAccountNo.text = profileData.object(forKey: "BankAccountNo") as? String
        txtAccountHolderName.text = profileData.object(forKey: "CompanyName") as? String
     
    }
    
    //-------------------------------------------------------------
    // MARK: - Select Card Delegate Methods
    //-------------------------------------------------------------
    
    func didSelectBankCard(dictData: [String : AnyObject]) {
        
        print(dictData)
        
        lblCardTitle.text = "\(dictData["Type"] as! String) \(dictData["CardNum2"] as! String)"
        strCardId = dictData["Id"] as! String
        
//        lblCurrentBalanceTitle = dictData["Type"] as? AnyObject
        
        //        dictData1["PassengerId"] = "1" as AnyObject
        //        dictData1["CardNo"] = "**** **** **** 1081" as AnyObject
        //        dictData1["Cvv"] = "123" as AnyObject
        //        dictData1["Expiry"] = "08/22" as AnyObject
        //        dictData1["CardType"] = "MasterCard" as AnyObject
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    
    @IBAction func txtAmount(_ sender: UITextField) {
        
        if let amountString = txtAmount.text?.currencyInputFormatting() {
            
            
            //            txtAmount.text = amountString
            
            
            let unfiltered1 = amountString   //  "!   !! yuahl! !"
            
            let spaceAdd = " "
            
            let insertCurrencySymboleInString = "\(currencySign),\(spaceAdd)"
            let insertcurrencySymboleInCharacter = [Character](insertCurrencySymboleInString)
            
            let removal1: [Character] = insertcurrencySymboleInCharacter    // ["!"," "]
            
            // turn the string into an Array
            let unfilteredCharacters1 = unfiltered1.characters
            
            // return an Array without the removal Characters
            let filteredCharacters1 = unfilteredCharacters1.filter { !removal1.contains($0) }
            
            // build a String with the filtered Array
            let filtered1 = String(filteredCharacters1)
            
            print(filtered1) // => "yeah"
            
            // combined to a single line
            print(String(unfiltered1.characters.filter { !removal1.contains($0) })) // => "yuahl"
            
            txtAmount.text = String(unfiltered1.characters.filter { !removal1.contains($0) })
            
            
            let space = " "
            let comma = " "
            let currencySymboleInString = "\(currencySign),\(comma),\(space)"
            let currencySymboleInCharacter = [Character](currencySymboleInString)
            
            
            // ----------------------------------------------------------------------
            // ----------------------------------------------------------------------
            let unfiltered = amountString   //  "!   !! yuahl! !"
            
            // Array of Characters to remove
            let removal: [Character] = currencySymboleInCharacter    // ["!"," "]
            
            // turn the string into an Array
            let unfilteredCharacters = unfiltered.characters
            
            // return an Array without the removal Characters
            let filteredCharacters = unfilteredCharacters.filter { !removal.contains($0) }
            
            // build a String with the filtered Array
            let filtered = String(filteredCharacters)
            
            print(filtered) // => "yeah"
            
            // combined to a single line
            print(String(unfiltered.characters.filter { !removal.contains($0) })) // => "yuahl"
            
            strAmt = String(unfiltered.characters.filter { !removal.contains($0) })
            print("amount : \(strAmt)")
            
            
        }
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    
    func validationOfTransferToBank() -> Bool {
        
        strAmt = strAmt.trimmingCharacters(in: .whitespacesAndNewlines)
        strAmt = strAmt.replacingOccurrences(of: " ", with: "")
        
//        if txtABN.text!.count == 0 {
//            
//            UtilityClass.setCustomAlert(title: "Missing", message: "Enter ABN Number") { (index, title) in
//            }
//            return false
//        }
//        if txtBSB.text!.count == 0 {
//
//            UtilityClass.setCustomAlert(title: "Missing", message: "Enter BSB Number") { (index, title) in
//            }
//            return false
//        }
//        else
        if txtAmount.text!.count == 0 {
            UtilityClass.showAlert("", message: "Please enter amount.", vc: self)
//            UtilityClass.setCustomAlert(title: "", message: "Enter Amount") { (index, title) in
//            }
            return false
        }
        else if txtAccountHolderName.text!.count == 0 {
            UtilityClass.showAlert("", message: "Please enter account holder name.", vc: self)
//            UtilityClass.setCustomAlert(title: "Missing", message: "Enter Account Holder Name") { (index, title) in
//            }
            return false
        }
        else if txtBankName.text!.count == 0 {
              UtilityClass.showAlert("", message: "Please enter bank name.", vc: self)
//            UtilityClass.setCustomAlert(title: "", message: "Enter Bank Name") { (index, title) in
//            }
            return false
        }
        else if txtBankAccountNo.text!.count == 0 {
             UtilityClass.showAlert("", message: "Please enter bank account number.", vc: self)
//            UtilityClass.setCustomAlert(title: "", message: "Enter Bank Account Number") { (index, title) in
//            }
            return false
        }
       
        else if Double(strAmt)! > SingletonClass.sharedInstance.strCurrentBalance {

            UtilityClass.setCustomAlert(title: "Info Message", message: "Sorry you have insufficient funds!") { (index, title) in
            }
            return false
        }
        
        
        return true
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    func webserviceOfTransferToBank() {
//        PassengerId,Amount,HolderName,ABN,BankName,BSB,AccountNo
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        
        var param = [String:AnyObject]()
        
        param["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        param["Amount"] = strAmt as AnyObject
        param["HolderName"] = txtAccountHolderName.text as AnyObject
//        param["ABN"] = txtABN.text as AnyObject
        param["BankName"] = txtBankName.text as AnyObject
        param["BSB"] = "" as AnyObject
        param["AccountNo"] = txtBankAccountNo.text as AnyObject

        
        webserviceForTransferToBank(param as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
              
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: "Success Message", message: res) { (index, title) in
                         self.perform(#selector(self.goBack), with: nil, afterDelay: 1.0)
                    }
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.setCustomAlert(title: "Success Message", message: resDict.object(forKey: "message") as! String) { (index, title) in
                         self.perform(#selector(self.goBack), with: nil, afterDelay: 1.0)
                    }
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: "Success Message", message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                         self.perform(#selector(self.goBack), with: nil, afterDelay: 1.0)
                    }
                }
                
//                self.webserviceOfTransactionHistory()
                
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
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func webserviceOfTransactionHistory() {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        webserviceForTransactionHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                SingletonClass.sharedInstance.strCurrentBalance = ((result as! NSDictionary).object(forKey: "walletBalance") as AnyObject).doubleValue
                self.lblCurrentBalanceTitle.text = "\(currencySign)\(String(format: "%.2f", SingletonClass.sharedInstance.strCurrentBalance))"
//                "\(currencySign)\(SingletonClass.sharedInstance.strCurrentBalance)"
                
                
                SingletonClass.sharedInstance.walletHistoryData = (result as! NSDictionary).object(forKey: "history") as! [[String:AnyObject]]
                self.navigationController?.popViewController(animated: false)
                
                
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
