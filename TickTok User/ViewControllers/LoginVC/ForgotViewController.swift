
//
//  ForgotViewController.swift
//  EZYGO Rider
//
//  Created by Excelent iMac on 20/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift
import NVActivityIndicatorView

class ForgotViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
         UtilityClass.setCornerRadiusTextField(textField: txtEmail, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        
    }
    @IBAction func btnBack(_ sender: UIButton) {
            self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnResetPassword(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if self.checkValidation(){
            self.webserviceCallForForgotPassword(strEmail: (txtEmail?.text)!)
        }
        
        
        
//                //1. Create the alert controller.
//                let alert = UIAlertController(title: "Forgot Password?", message: "Enter Mobile Number", preferredStyle: .alert)
//
//                //2. Add the text field. You can configure it however you need.
////                alert.addTextField { (textField) in
////
////                    textField.placeholder = "Mobile Number"
////                }
//
//                // 3. Grab the value from the text field, and print it when the user clicks OK.
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//                    let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
//                    print("Text field: \(String(describing: textField?.text))")
        
//                    if (textField?.text?.count != 0)
//                    {
//                        self.webserviceCallForForgotPassword(strEmail: (txtEmail?.text)!)
//                    }
//                }))
//
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
//                }))
//
//                // 4. Present the alert.
//                self.present(alert, animated: true, completion: nil)
        
    }
    
    
        func webserviceCallForForgotPassword(strEmail : String)
        {
            if Connectivity.isConnectedToInternet() == false {
                
                UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
                    
                }
                return
            }
            let dictparam = NSMutableDictionary()
            dictparam.setObject(strEmail, forKey: "Email" as NSCopying)
            let activityData = ActivityData()
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
            webserviceForForgotPassword(dictparam) { (result, status) in
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    
                if ((result as! NSDictionary).object(forKey: "status") as! Int == 1) {
    
                     UtilityClass.setCustomAlert(title: "Success", message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                        self.perform(#selector(self.GoBack), with: nil, afterDelay: 1.0)
                    }
                }
                else {
    
                     UtilityClass.setCustomAlert(title: alertTitle, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                }
            }
        }
    
    @objc func GoBack() {
        self.navigationController?.popViewController(animated:true)
    }
    
    func checkValidation() -> Bool
    {
        if (txtEmail.text?.count == 0)
        {
            
            UtilityClass.setCustomAlert(title: "", message: " Please enter email.") { (index, title) in
            }
            
            // txtEmail.showErrorWithText(errorText: "Enter Email")
            return false
        } else if (txtEmail.text!).isValidEmailAddress() == false {
          
            UtilityClass.setCustomAlert(title: "", message: " Please enter valid email.") { (index, title) in
            }
            return false
            
        }
        
        return true
    }
}
