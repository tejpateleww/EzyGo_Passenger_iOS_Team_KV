//
//  RegisterViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 25/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift

class RegisterViewController: UIViewController, UITextFieldDelegate ,UIPickerViewDataSource,UIPickerViewDelegate{
   
    var aryContoryNum = [String:AnyObject]()
    
    @IBOutlet weak var txtPhoneNumber: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var txtConfirmPassword: ACFloatingTextfield!
    
    @IBOutlet weak var txtContoryNum: UITextField!
    let countoryz : Int = 0
    
    var countoryPicker = UIPickerView()
    var pickerView = UIPickerView()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        aryContoryNum = ["name" : "+64","namea" : "+91"] as [String : AnyObject]
        txtPhoneNumber.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
       
        //        txtPhoneNumber.text = "1234567890"
        //        txtEmail.text = "rahul.bbit@gmail.com"
        //        txtPassword.text = "12345678"
        //        txtConfirmPassword.text = "12345678"
        
        UtilityClass.setCornerRadiusTextField(textField: txtPhoneNumber, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        UtilityClass.setCornerRadiusTextField(textField: txtEmail, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        UtilityClass.setCornerRadiusTextField(textField: txtPassword, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        UtilityClass.setCornerRadiusTextField(textField: txtConfirmPassword, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
         UtilityClass.setCornerRadiusTextField(textField: txtContoryNum, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        
        countoryPicker.delegate = self
        countoryPicker.dataSource = self
        
        txtContoryNum.inputView = countoryPicker
//        txtPhoneNumber.placeHolderColor = UIColor.red
        // Do any additional setup after loading the view.
    }
    
  
    //-------------------------------------------------------------
    // MARK: - TextField Delegate Method
    //-------------------------------------------------------------
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPhoneNumber {
            let resultText: String? = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            
            if resultText!.count >= 11 {
                return false
            }
            else {
                return true
            }
        }
        
        return true
    }
    //-------------------------------------------------------------
    // MARK: - PickerView Methods
    //-------------------------------------------------------------
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == countoryPicker{
            return 2
        }
        
        return aryContoryNum.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if pickerView == countoryPicker {
            return 120
        }
        return 60
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        
        if pickerView == countoryPicker
        {
        //mainview
         let viewOfContryCode = UIView(frame: CGRect(x: 10, y: 10, width: countoryPicker.frame.size.width , height: countoryPicker.frame.size.height ))
        
        //image
        let imgOfCountry = UIImageView(frame: CGRect(x:viewOfContryCode.center.x - 20, y:viewOfContryCode.center.y - 20 , width: 100, height: 50))
        
        //labelNum
        let lblOfCountryNum = UILabel(frame: CGRect(x: imgOfCountry.center.x - 10, y: imgOfCountry.center.y - 25, width: 60, height: 60))
        //addsubview
        viewOfContryCode.addSubview(imgOfCountry)
        viewOfContryCode.addSubview(lblOfCountryNum)
       // return mainview
        return viewOfContryCode
        
        }
        
        let dataOfCountory = aryContoryNum
        var strcountory = String()
        let viewContoryCode = UIView(frame: CGRect(x:0, y:0, width: pickerView.bounds.width - 30, height: 60))
        
        let imageOfCountoryPicker =  UIImageView(frame: CGRect(x:0, y:0, width:50, height:50))
  
        var  imgStr = String()
        

        switch countoryz {
        case 0:
            strcountory = dataOfCountory["name"] as! String
            imageOfCountoryPicker.image = UIImage(named: "iconActiveDriver")
        case 1 :
            strcountory = dataOfCountory["name"] as! String
            imageOfCountoryPicker.image = UIImage(named: "iconActiveDriver")
        default:
            print("Error")
        }
        

        let lblOfCountryNum = UILabel(frame: CGRect(x:60, y:0, width:pickerView.bounds.width - 90, height:60 ))
        viewContoryCode.addSubview(lblOfCountryNum)
        viewContoryCode.addSubview(imageOfCountoryPicker)
        
     return pickerView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        if pickerView == countoryPicker {
            
         
    }
    }
    // MARK: - Navigation
    
    
    @IBAction func btnNext(_ sender: Any) {
        
        if (validateAllFields())
        {

            webserviceForGetOTPCode(email: txtEmail.text!, mobile: txtPhoneNumber.text!)

        }
        
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-------------------------------------------------------------
    // MARK: - validation Email Methods
    //-------------------------------------------------------------
    
    func validateAllFields() -> Bool
    {
     
        let isEmailAddressValid = isValidEmailAddress(emailID: txtEmail.text!)
        
        if (txtPhoneNumber.text?.count == 0)
        {

            UtilityClass.setCustomAlert(title: "", message: "Enter Phone Number") { (index, title) in
            }

            return false
        }
        else if ((txtPhoneNumber.text?.count)! < 10)
        {

            UtilityClass.setCustomAlert(title: "", message: "Phone Number should 10 digits") { (index, title) in
            }

            return false
        }
        else if (txtEmail.text?.count == 0)
        {
            UtilityClass.setCustomAlert(title: "", message: "Enter Email Address") { (index, title) in
            }

            return false
        }
        else if (!isEmailAddressValid)
        {
            UtilityClass.setCustomAlert(title: "", message: "Please Enter Valid Email ID") { (index, title) in
            }

            return false
        }
        else if (txtPassword.text?.count == 0)
        {
            UtilityClass.setCustomAlert(title: "", message: "Enter Password") { (index, title) in
            }

            return false
        }
            
        else if ((txtPassword.text?.count)! < 6)
        {
            UtilityClass.setCustomAlert(title: "", message: "Password should be of more than 6 characters") { (index, title) in
            }

            return false
        }
        else if (txtPassword.text != txtConfirmPassword.text)
        {
            UtilityClass.setCustomAlert(title: "", message: "Password and Confirm Password does not match") { (index, title) in
            }

            return false
        }
       
        
        return true
    }
    
    
    func isValidEmailAddress(emailID: String) -> Bool
    {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z)-9.-]+\\.[A-Za-z]{2,3}"
        
        do{
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailID as NSString
            let results = regex.matches(in: emailID, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
        }
        catch _ as NSError
        {
            returnValue = false
        }
        
        return returnValue
    }
    
    func setCustomAlert(title: String, message: String) {
        AJAlertController.initialization().showAlertWithOkButton(aStrTitle: title, aStrMessage: message) { (index,title) in
        }
     
    }
    
    func webserviceForGetOTPCode(email: String, mobile: String) {
        
//        Param : MobileNo,Email

        
        var param = [String:AnyObject]()
        param["MobileNo"] = mobile as AnyObject
        param["Email"] = email as AnyObject
        
        var boolForOTP = Bool()
        
        webserviceForOTPRegister(param as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                let datas = (result as! [String:AnyObject])
                
                
                UtilityClass.showAlertWithCompletion("OTP Code", message: datas["message"] as! String, vc: self, completionHandler: { ACTION in
                    
                    if let otp = datas["otp"] as? String {
                        SingletonClass.sharedInstance.otpCode = otp
                    }
                    else if let otp = datas["otp"] as? Int {
                        SingletonClass.sharedInstance.otpCode = "\(otp)"
                    }
                    
                    
                    let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
                    registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
                    registrationContainerVC.pageControl.set(progress: 1, animated: true)
                    
                })
                
//                UtilityClass.setCustomAlert(title: "OTP Code", message: datas["message"] as! String, completionHandler: { (index, title) in
//
//                    if let otp = datas["otp"] as? String {
//                        SingletonClass.sharedInstance.otpCode = otp
//                    }
//                    else if let otp = datas["otp"] as? Int {
//                        SingletonClass.sharedInstance.otpCode = "\(otp)"
//                    }
//
//
//                    let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
//                    registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
//                    registrationContainerVC.pageControl.set(progress: 1, animated: true)
//
//
//                    let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
//                    registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
//                    registrationContainerVC.pageControl.set(progress: 1, animated: true)
      
                
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
