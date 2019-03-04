//
//  ChangePasswordVC.swift
//  TickTok User
//
//  Created by Excellent Webworld on 11/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ACFloatingTextfield_Swift

class ChangePasswordVC: UIViewController {

    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        btnSubmit.layer.cornerRadius = 5
//        btnSubmit.layer.masksToBounds = true
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
         
    }
    

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    
    @IBAction func btnSubmit(_ sender: UIButton) {
       
        let ValidationError = self.isValidateRequest()
        
        if ValidationError.1 == true {
            webserviceOfChangePassword()
        } else {
            UtilityClass.showAlert("", message: ValidationError.0, vc: self)
        }
        
//        let str = txtNewPassword.text
//
//        if txtNewPassword.text == txtConfirmPassword.text {
//
//            if str!.count >= 8  {
//                webserviceOfChangePassword()
//            }
//            else {
//                UtilityClass.setCustomAlert(title: "", message: "Password should be minimum 8 characters.") { (index, title) in
//            }
//            }
//        }
//        else {
//            UtilityClass.setCustomAlert(title: "Password did not match", message: "Please re-enter password") { (index, title) in
//            }
//        }
        
    }
    
    func isValidateRequest() -> (String,Bool) {
        
        var ValidationStatus:Bool = true
        var ValidationMessage:String = ""
        
        if txtNewPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 && txtConfirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            ValidationStatus = false
            ValidationMessage = "Please fill all details."
        } else if txtNewPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            ValidationStatus = false
            ValidationMessage = "Please enter new password."
        } else if (txtNewPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines).count)! <= 5 {
            ValidationStatus = false
            ValidationMessage = "Password must contain atleast 6 characters."
        } else if txtConfirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            ValidationStatus = false
            ValidationMessage = "Please enter confirm password"
        } else if txtNewPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) != txtConfirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            ValidationStatus = false
            ValidationMessage = "Password and confirm password doesn't match"
        }
        
        return (ValidationMessage,ValidationStatus)
    }
    
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var btnCall: UIButton!
    @IBAction func btCallClicked(_ sender: UIButton)
    {
        
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
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    func webserviceOfChangePassword() {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        var dictData = [String:AnyObject]()
        
        dictData["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        dictData["Password"] = txtNewPassword.text as AnyObject
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        webserviceForChangePassword(dictData as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                
                self.txtNewPassword.text = ""
                self.txtConfirmPassword.text = ""
                
                UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    
                    self.perform(#selector(self.goBack), with: nil, afterDelay: 1.0)
                    
            }
                
//                UtilityClass.showAlert("", message: (result as! NSDictionary).object(forKey: "message") as! String, vc: self)
                
                
            }
            else {
                 print(result)
                
//                UtilityClass.setCustomAlert(title: <#T##String#>, message: <#T##String#>, completionHandler: { (<#Int#>, <#String#>) in
//                    <#code#>
//                })
                
            }
        }
        
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

}



