//
//  RegistrationNewViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift
import TransitionButton
import M13Checkbox

class RegistrationNewViewController: UIViewController,AKRadioButtonsControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate {
  
    
    var aryage = [String]()
    var strDateOfBirth = String()
    var isProfileSelected = false
    var agePicker = UIPickerView()
    var pickerView = UIPickerView()
    var radioButtonsController: AKRadioButtonsController!
   
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet var radioButtons: [AKRadioButton]!
    @IBOutlet weak var txtFirstName: ACFloatingTextfield!
    @IBOutlet weak var txtLastName: ACFloatingTextfield!
    @IBOutlet weak var btnSignUp: TransitionButton!
    @IBOutlet weak var lblAgeGroup: UILabel!
    
    @IBOutlet weak var txtInviteCode: ACFloatingTextfield!
    @IBOutlet weak var btnFemale: AKRadioButton!
    @IBOutlet weak var btnMale: AKRadioButton!
    @IBOutlet weak var txtAddress: ACFloatingTextfield!
    @IBOutlet weak var txtAgeGroup: ACFloatingTextfield!//binal
    @IBOutlet weak var imgProfile: UIImageView!

    @IBOutlet weak var viewCheck: M13Checkbox!
    
    @IBOutlet weak var txtPostcode: UITextField!
    
    
    var strPhoneNumber = String()
    var strEmail = String()
    var strPassword = String()
    var isSocialLogin:Bool = false
    var SocialId = String()
    var SocialType = String()
    var gender = String()
    
    var iscameFromCamera:Bool = false
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        agePicker.delegate = self
        agePicker.dataSource = self
        txtAgeGroup.inputView = agePicker
        self.viewCheck.tintColor = themeYellowColor
        self.viewCheck.checkState = .unchecked
        self.viewCheck.stateChangeAnimation = .fill
        self.viewCheck.boxType = .square
        // Do any additional setup after loading the view.
        
        self.radioButtonsController = AKRadioButtonsController(radioButtons: self.radioButtons)
        self.radioButtonsController.strokeColor = UIColor.init(red: 237/255, green: 122/255, blue: 4/255, alpha: 1.0)//init(red: 255/255, green: 163/255, blue: 0, alpha: 1)
        self.radioButtonsController.startGradColorForSelected = UIColor.init(red: 237/255, green: 122/255, blue: 4/255, alpha: 1.0)
        self.radioButtonsController.endGradColorForSelected = UIColor.init(red: 237/255, green: 122/255, blue: 4/255, alpha: 1.0)
        self.radioButtonsController.selectedIndex = 2
        self.radioButtonsController.delegate = self
        //class should implement AKRadioButtonsControllerDelegate
//        txtFirstName.text = "rahul"
//        txtLastName.text = "patel"
      
        
        
    
        aryage = [ "18 to 25", "26 to 35", "35 to 55", "55+"]
    
        UtilityClass.setCornerRadiusTextField(textField: txtFirstName, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        UtilityClass.setCornerRadiusTextField(textField: txtInviteCode, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        UtilityClass.setCornerRadiusTextField(textField: txtLastName, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        UtilityClass.setCornerRadiusTextField(textField: txtAgeGroup, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)

        UtilityClass.setCornerRadiusTextField(textField: txtPostcode, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
//
        UtilityClass.setCornerRadiusTextField(textField: txtAddress, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        
        UtilityClass.setCornerRadiusButton(button: btnMale, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        
          UtilityClass.setCornerRadiusButton(button: btnFemale, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationController?.viewControllers.last != nil && self.iscameFromCamera == false {
            let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
            if registrationContainerVC.isFromSocialLogin {
                self.txtFirstName.text = registrationContainerVC.strFirstName
                self.txtLastName.text = registrationContainerVC.strLastName
                self.isSocialLogin = registrationContainerVC.isFromSocialLogin
                self.SocialId = registrationContainerVC.strSocialID
                self.SocialType = registrationContainerVC.SocialType
            }
        }
        if self.iscameFromCamera == true {
            self.iscameFromCamera = false
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width/2
        self.imgProfile.layer.masksToBounds = true
        self.imgProfile.contentMode = .scaleAspectFill
    }
    
    func selectedButton(sender: AKRadioButton) {

        print(sender.currentTitle!)
        
        switch sender.currentTitle! {
            
        case "Male":
            gender = "male"
        case "Female":
            gender = "female"
        default:
            gender = "male"
        }
    }
    
    // MARK: - Pick Image
     func TapToProfilePicture() {
        
        let alert = UIAlertController(title: "Choose Options", message: nil, preferredStyle: .alert)
        
        let Gallery = UIAlertAction(title: "Gallery", style: .default, handler: { ACTION in
            self.PickingImageFromGallery()
        })
        let Camera  = UIAlertAction(title: "Camera", style: .default, handler: { ACTION in
            self.PickingImageFromCamera()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(Gallery)
        alert.addAction(Camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func PickingImageFromGallery()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        
        // picker.stopVideoCapture()
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.iscameFromCamera = true
        present(picker, animated: true, completion: nil)
    }
    
    
    func PickingImageFromCamera()
    {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        self.iscameFromCamera = true
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Image Delegate and DataSource Methods

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgProfile.contentMode = .scaleToFill
            imgProfile.image = pickedImage
            isProfileSelected = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func txtAgeGroup(_ sender: ACFloatingTextfield) {
//
//        let datePickerView:UIDatePicker = UIDatePicker()
//        datePickerView.datePickerMode = UIDatePickerMode.date
//        sender.inputView = datePickerView
//        datePickerView.addTarget(self, action: #selector(self.pickupdateMethod(_:)), for: UIControlEvents.valueChanged)
//    }
//
//    @objc func pickupdateMethod(_ sender: UIDatePicker)
//    {
//        let dateFormaterView = DateFormatter()
//        dateFormaterView.dateFormat = "yyyy-MM-dd"
//        txtAgeGroup.text = dateFormaterView.string(from: sender.date)
//        strDateOfBirth = txtAgeGroup.text!
//    }

    
    //-------------------------------------------------------------
    // MARK: - PickerView Methods
    //-------------------------------------------------------------
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return aryage.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return aryage[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        lblAgeGroup.text = aryage[row]
       
    }
    // MARK: - Navigation
    
  
    
    //MARK: - Validation
    
    func checkValidation() -> Bool
    {
        if (isProfileSelected == false)//binal
        {
            
            UtilityClass.setCustomAlert(title: "", message: "Please choose profile picture") { (index, title) in
            }
            return false
        } else if (txtFirstName.text?.count == 0)
        {

            UtilityClass.setCustomAlert(title: "", message: "Please enter first name.") { (index, title) in
            }
            return false
        }
        else if (txtLastName.text?.count == 0)
        {
            
            UtilityClass.setCustomAlert(title: "", message: "Please enter last name.") { (index, title) in
            }
            return false
        }
        else if (txtAddress.text?.count == 0)
        {
            
            UtilityClass.setCustomAlert(title: "", message: "Please enter address.") { (index, title) in
            }
            return false
        }
        else if (txtPostcode.text?.count == 0)
        {
            
            UtilityClass.setCustomAlert(title: "", message: "Please enter post code.") { (index, title) in
            }
            return false
        }
        else if (self.lblAgeGroup.text == "Select Age Group") {
            UtilityClass.setCustomAlert(title: "", message: "Please choose age group") { (index, title) in
            }
            return false
        }
            
//        else if imgProfile.image == UIImage(named: "profile-pic2")
//        {
//
//            UtilityClass.setCustomAlert(title: "", message: "Please choose profile picture") { (index, title) in
//            }
//            return false
//        }
//        else if strDateOfBirth == "" {
//
//            UtilityClass.setCustomAlert(title: "", message: "Please choose Date of Birth") { (index, title) in
//            }
//            return false
//        }
        else if gender == "" {
            
            UtilityClass.setCustomAlert(title: "", message: "Please choose Gender") { (index, title) in
            }
            return false
        }
        else if self.viewCheck.checkState == .unchecked {
            UtilityClass.setCustomAlert(title: "", message: "Please check Privacy Policy.") { (index, title) in
            }
            return false
        }
        
        return true
    }
    
    
    //MARK: - IBActions
    
    @IBAction func viewCheck(_ sender: M13Checkbox) {
        
        
    }
    
    
    @IBAction func btnChooseImage(_ sender: Any) {
        
        self.TapToProfilePicture()
    }
    
    @IBAction func btnTermsOfUser(_ sender: Any) {
        let MainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let next = MainStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
        next.HeaderTitle = "Terms Of Use"
        next.URLString = WebserviceURLs.kTermOfUse_PrivacyPolicyURL
        self.navigationController?.pushViewController(next, animated: true)
        
        
    }
    
    @IBAction func btnPrivacyPolicy(_ sender: Any) {
        let MainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let next = MainStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
        next.HeaderTitle = "Privacy Policy"
        next.URLString = WebserviceURLs.kTermOfUse_PrivacyPolicyURL
        self.navigationController?.pushViewController(next, animated: true)
        
        
    }
    
    
    @IBAction func btnSignUp(_ sender: Any) {
        
        if (checkValidation())
        {
            let registerVC = (self.navigationController?.viewControllers.last as! RegistrationContainerViewController).childViewControllers[0] as! RegisterViewController
                                    
            var MobileNumber:String = ""
            
            if let CountryCode:String = registerVC.txtContoryNum.text, let Phone:String = registerVC.txtPhoneNumber.text {
                if CountryCode == "AU +61" {
                    MobileNumber = "61\(Phone)"
                } else if CountryCode == "NZ +64" {
                    MobileNumber = "64\(Phone)"
                }
            }
            strPhoneNumber = MobileNumber
            strEmail = (registerVC.txtEmail.text)!
            strPassword = (registerVC.txtPassword.text)!
            
//            self.btnSignUp.startAnimation()
            
            webServiceCallForRegister()
        }
        
    }
    
    // MARK: - WebserviceCall
    
    func webServiceCallForRegister()
    {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        let dictParams = NSMutableDictionary()
        dictParams.setObject(txtFirstName.text!, forKey: "Firstname" as NSCopying)
        dictParams.setObject(txtLastName.text!, forKey: "Lastname" as NSCopying)
//        dictParams.setObject(txtPostCode.text!, forKey: "ReferralCode" as NSCopying)//binal
        dictParams.setObject(strPhoneNumber, forKey: "MobileNo" as NSCopying)
        dictParams.setObject(strEmail, forKey: "Email" as NSCopying)
        dictParams.setObject(strPassword, forKey: "Password" as NSCopying)
        dictParams.setObject(SingletonClass.sharedInstance.deviceToken, forKey: "Token" as NSCopying)
        dictParams.setObject("1", forKey: "DeviceType" as NSCopying)
        dictParams.setObject(gender, forKey: "Gender" as NSCopying)
        dictParams.setObject("12376152367", forKey: "Lat" as NSCopying)
        dictParams.setObject(lblAgeGroup.text!, forKey: "AgeGroup" as NSCopying)
        dictParams.setObject("2348273489", forKey: "Lng" as NSCopying)
        
        if self.isSocialLogin == true {
            dictParams.setObject(SocialId, forKey: "SocialId" as NSCopying)
            dictParams.setObject(SocialType, forKey: "SocialType" as NSCopying)
        }
       
        //dictParams.setObject(strDateOfBirth, forKey: "DOB" as NSCopying)//binal
        dictParams.setObject(txtAddress.text!, forKey: "Address" as NSCopying)
        
//        if SingletonClass.sharedInstance.otpCode != nil {
        dictParams.setObject(txtPostcode.text!, forKey: "ZipCode" as NSCopying)
//        }
   
        let imgtemp = imgProfile.image!
        webserviceForRegistrationForUser(dictParams, image1: imgtemp) { (result, status) in
            
            print(result)
            if ((result as! NSDictionary).object(forKey: "status") as! Int == 1)
            {
                
                SingletonClass.sharedInstance.dictProfile = NSMutableDictionary(dictionary: (result as! NSDictionary).object(forKey: "profile") as! NSDictionary)
                SingletonClass.sharedInstance.isUserLoggedIN = true
                SingletonClass.sharedInstance.strPassengerID = String(describing: SingletonClass.sharedInstance.dictProfile.object(forKey: "Id")!)
                SingletonClass.sharedInstance.arrCarLists = NSMutableArray(array: (result as! NSDictionary).object(forKey: "car_class") as! NSArray)
                UserDefaults.standard.set(SingletonClass.sharedInstance.arrCarLists, forKey: "carLists")
                
                UserDefaults.standard.set(SingletonClass.sharedInstance.dictProfile, forKey: "profileData")
                // Bhautik
                UtilityClass.getAppDelegate().GoToHome()
//                self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
//                let MainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//                let CustomSideMenu = MainStoryBoard.instantiateViewController(withIdentifier: "CustomSideMenuViewController") as! CustomSideMenuViewController
//                self.navigationController?.pushViewController(CustomSideMenu, animated: true)

                
//                DispatchQueue.main.async(execute: { () -> Void in
//
//                    self.btnSignUp.stopAnimation(animationStyle: .normal, completion: {
//
//                    })
//                })
//
            }
            else
            {
                UtilityClass.setCustomAlert(title: alertTitle, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                }
//                self.btnSignUp.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: {
//
//
//
//                })
            }
        }
    }
    
    
//    @IBOutlet weak var btnPrivacypolicy: UIButton!
//
//    @IBAction func btnPrivacyPolicy(_ sender: UIButton) {
//
//        sender.isSelected = !sender.isSelected
//        btnPrivacypolicy.isSelected = sender.isSelected
//        if sender.isSelected == true
//        {
//            self.btnPrivacypolicy.setImage(UIImage(named: "iConStarSelected"), for: .normal)
//
//        }
//        else
//        {
//            self.btnPrivacypolicy.setImage(UIImage(named: "iconMasterCardLogo"), for: .normal)
//        }
//
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




//{
//    Address = "hello ";
//    DeviceType = 1;
//    Email = "jgygj@fug.kbb";
//    Firstname = bin;
//    Gender = female;
//    Lastname = "jlk ";
//    Lat = 12376152367;
//    Lng = 2348273489;
//    MobileNo = 8808884225;
//    Password = rahull;
//    Token = "czEpNzqLmVI:APA91bF19b8BLisU71lEAP9RILLiyvKXZyGGyunkhWXaPceu8-pMv9LXrLk3av4HqMeE03ozyWQKgNq7pJaHBV1z4pRfv6Tb3kQNLYiDy6AompN_M6Cc-e6hFjigpgWwDb_ET9xnlYHf";
//    ZipCode = 866760;
//}
