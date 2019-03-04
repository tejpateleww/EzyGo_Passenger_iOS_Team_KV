//
//  ContactUsViewController.swift
//  EZYGO Rider
//
//  Created by EWW-iMac Old on 28/11/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
class ContactUsViewController: UIViewController {
    
    @IBOutlet weak var btnSelectSubject: UIButton!
    
    @IBOutlet weak var txtVwDescription: UITextView!
    
    var arrData = ["Feedback","General Enquiry","Account Enquiry"]
    override func viewDidLoad() {
        super.viewDidLoad()
        txtVwDescription.text = "Description"
        txtVwDescription.textColor = UIColor.lightGray
        
        //        txtVwDescription.selectedTextRange = txtVwDescription.textRange(from: txtVwDescription.beginningOfDocument, to: txtVwDescription.beginningOfDocument)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: Button Click Event
    
    @IBAction func selectSubjectClick(_ sender: UIButton) {
        //        let arrData = Singletons.sharedInstance.arrReasonForReject.map{$0.strReason}
        
        
        ActionSheetStringPicker.show(withTitle: "Select Subject", rows: arrData, initialSelection: 0, doneBlock: { (actionSheet, index, obj) in
            //            self.selectedIndex = index
            //            Singletons.sharedInstance.strReasonForCancel = arrData[index]
            self.btnSelectSubject.setTitle(self.arrData[index], for: .normal)
        }, cancel: { (actionSheet) in
            
        }, origin: self.view)
        
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        if btnSelectSubject.currentTitle == "Select Subject" {
            UtilityClass.showAlert("", message: "Please select reason.", vc:self)
        }else if txtVwDescription.text.isEmpty || txtVwDescription.textColor == UIColor.lightGray {
            UtilityClass.showAlert("", message: "Please enter description.", vc:self)
        }else {
            if Connectivity.isConnectedToInternet() == false {
                UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
                }
                return
            }
            if Connectivity.isConnectedToInternet() == false {
                
                UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
                    
                }
                return
            }
            var param = [String:AnyObject]()
            
            param["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
            param["Subject"] = btnSelectSubject.currentTitle as AnyObject
            param["Description"] = txtVwDescription.text as AnyObject
            
            webserviceForContactUs(param as AnyObject) { (result, status) in
                
                UtilityClass.showAlertWithCompletion("", message: result["message"] as? String ?? "", vc: self, completionHandler: { (status) in
                    self.navigationController?.popViewController(animated: true)
                   
                })
                
            }
            
            
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated:  true)
        
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
    
}
extension ContactUsViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Description" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
}
