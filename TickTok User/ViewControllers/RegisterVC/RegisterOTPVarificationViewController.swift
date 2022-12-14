//
//  RegisterOTPVarificationViewController.swift
//  PickNGo User
//
//  Created by Excelent iMac on 17/02/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.

import UIKit
import ACFloatingTextfield_Swift

class RegisterOTPVarificationViewController: UIViewController {

    //------------------------------------------------------------- 
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UtilityClass.setCornerRadiusTextField(textField: txtOTP, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var txtOTP: ACFloatingTextfield!

    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    @IBAction func btnResendVerificationCode(_ sender: UIButton) {
        if SingletonClass.sharedInstance.otpCode == txtOTP.text{
            
            let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
            registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width * 2, y: 0), animated: true)
            registrationContainerVC.selectPageControlIndex(Index: 2)
//                .pageControl.set(progress: 2, animated: true)
        }
        else
        {
            UtilityClass.setCustomAlert(title: "", message: "Please enter correct Verification code.", completionHandler: { (index, title) in
            })
        }
    }
    
    @IBAction func btnNext(_ sender: UIButton) {
        
        if SingletonClass.sharedInstance.otpCode == txtOTP.text{
            
            UtilityClass.setCustomAlert(title: "", message:   "Your email address is successfully verified.") { (index, title) in

                let registrationContainerVC = self.parent as! RegistrationContainerViewController
                
                registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width * 2, y: 0), animated: true)
                registrationContainerVC.selectPageControlIndex(Index: 2)
//                    .pageControl.set(progress: 2, animated: true)
            }
        }
            else
            {
                UtilityClass.setCustomAlert(title: "", message: "Please enter the Verification code to finish setting up your Ezygo Account.", completionHandler: { (index, title) in
                })
            }
    }
}

