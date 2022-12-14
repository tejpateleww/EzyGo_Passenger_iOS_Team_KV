//
//  UpdateProfileViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 13/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import SDWebImage
import M13Checkbox
import NVActivityIndicatorView
import ACFloatingTextfield_Swift

class UpdateProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UIPickerViewDataSource,UIPickerViewDelegate
{
    
   var aryage = [String]()
    var firstName = String()
    var lastName = String()
    var fullName = String()
    var gender = String()
    var isprofile = false

    
    @IBOutlet weak var lblAge: UILabel!
    var countoryPicker = UIPickerView()
    var pickerView = UIPickerView()
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblContactNumber: UILabel!
    
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var txtAge: ACFloatingTextfield!
    @IBOutlet weak var txtMobileNum: UITextField!
    @IBOutlet weak var txtFirstName: ACFloatingTextfield!
    @IBOutlet weak var txtLastName: ACFloatingTextfield!
    @IBOutlet weak var txtAddress: ACFloatingTextfield!
//  @IBOutlet weak var txtDateOfBirth: ACFloatingTextfield!//binal
    @IBOutlet weak var txtHomeNumber: ACFloatingTextfield!
    @IBOutlet weak var viewMale: M13Checkbox!
    @IBOutlet weak var viewFemale: M13Checkbox!
    
    @IBOutlet weak var btnSave: UIButton!
    
//  @IBOutlet var viewChangePassword: UIView!//binal
    @IBOutlet var btnChangePassword: UIButton!
    @IBOutlet var btnProfile: UIButton!
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aryage = [ "18 to 25", "26 to 35", "35 to 55", "55+"]
        setData()
        pickerView.delegate = self
        pickerView.dataSource = self
        countoryPicker.delegate = self
        countoryPicker.dataSource = self
        txtAge.inputView = pickerView

    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imgProfile.layer.cornerRadius = imgProfile.frame.width / 2
        imgProfile.layer.borderWidth = 1.0
        imgProfile.layer.borderColor = themeYellowColor.cgColor
        imgProfile.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
         
    }
    
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
        txtAge.text = aryage[row]

    }
    
    //-------------------------------------------------------------
    // MARK: - TextField Delegate Method
    //-------------------------------------------------------------
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtHomeNumber {
            if txtMobileNum == txtMobileNum {
            let resultText: String? = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            
            if resultText!.count >= 11 {
                return false
            }
            else {
                return true
            }
        }
    }
           return true

    }
  
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
   
    
    @IBAction func btnMale(_ sender: UIButton) {
        
        viewMale.checkState = .checked
        viewMale.tintColor = themeYellowColor
        viewFemale.checkState = .unchecked
        
        gender = "Male"
    }
    @IBAction func btnFemale(_ sender: UIButton) {
        
        viewFemale.checkState = .checked
        viewFemale.tintColor = themeYellowColor
        viewMale.checkState = .unchecked
        
        gender = "Female"
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
//    @IBAction func txtDateOfBirthAction(_ sender: ACFloatingTextfield) {
//
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
//
//       // txtDateOfBirth.text = dateFormaterView.string(from: sender.date)
//    }
//
    @IBAction func btnChangePassword(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        self.navigationController?.pushViewController(next, animated: true)

    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        
        let validationError = self.isValidateRequest()
        
        if validationError.1 == true {
            webserviceOfUpdateProfile()
        } else {
            UtilityClass.showAlert("", message: validationError.0, vc: self)
        }
        

/*
        if txtAddress.text == "" || txtFirstName.text == "" || gender == ""  {
            
            if isprofile == false
            {
                UtilityClass.setCustomAlert(title: "Misssing", message: "Please select from galary") { (index, title) in
                }
            }
            
          
//            if(imgProfile.image  "profile-pic2")
//            {
//                
//                
//                UtilityClass.setCustomAlert(title: "Misssing", message: "Please ") { (index, title) in
//                }
//            }
            
            UtilityClass.setCustomAlert(title: "Misssing", message: "Please fill all details") { (index, title) in
            }
        }
        else {
            
        }
 */
        
    }
    
    
    func isValidateRequest() -> (String,Bool) {
        
        var ValidationStatus:Bool = true
        var ValidationMessage:String = ""
        
        if txtFirstName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 && txtLastName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 && txtAddress.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 && txtHomeNumber.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 && txtAge.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0  {
            ValidationStatus = false
            ValidationMessage = "Please fill all details."
        } else if txtFirstName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            ValidationStatus = false
            ValidationMessage = "Please enter first name."
        } else if txtLastName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            ValidationStatus = false
            ValidationMessage = "Please enter last name."
        } else if txtAddress.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            ValidationStatus = false
            ValidationMessage = "Please enter address."
        } else if txtHomeNumber.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            ValidationStatus = false
            ValidationMessage = "Please enter post code."
        } else if txtAge.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            ValidationStatus = false
            ValidationMessage = "Please select age group."
        }
        
        return (ValidationMessage,ValidationStatus)
    }
    
    
    @IBAction func btnUploadImage(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Choose Image From", message: nil, preferredStyle: .actionSheet)
        
        let Camera = UIAlertAction(title: "Camera", style: .default, handler: { ACTION in
            
            self.PickingImageFromCamera()
        })
        
        let Gallery = UIAlertAction(title: "Gallery", style: .default, handler: { ACTION in
            
             self.PickingImageFromGallery()
        })
        
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(Camera)
        alert.addAction(Gallery)
        alert.addAction(Cancel)
        
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
        present(picker, animated: true, completion: nil)
    }
    
    func PickingImageFromCamera()
    {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgProfile.contentMode = .scaleToFill
            imgProfile.image = pickedImage
            isprofile = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    func setData() {
        
        let getData = SingletonClass.sharedInstance.dictProfile
        
//        imgProfile.sd_setShowActivityIndicatorView(true)
//        imgProfile.sd_setIndicatorStyle(.white)
//        imgProfile.sd_setImage(with: URL(string: getData.object(forKey: "Image") as! String), completed: nil)
        if let Profileimg = getData.object(forKey: "Image") as? String {
            imgProfile.sd_setShowActivityIndicatorView(true)
            imgProfile.sd_setIndicatorStyle(.gray)
            imgProfile.sd_setImage(with: URL(string: Profileimg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), completed: nil)
        }
        
        lblName.text = (getData.object(forKey: "Fullname") as? String)?.uppercased()
        lblEmailId.text = getData.object(forKey: "Email") as? String
        lblContactNumber.text = getData.object(forKey: "MobileNo") as? String
//        txtDateOfBirth.text = getData.object(forKey: "DOB") as? String
//                lblAge.text = getData.object(forKey: "AgeGroup") as? String
        
        fullName = getData.object(forKey: "Fullname") as! String
  
        let fullNameArr = fullName.components(separatedBy: " ")
        firstName = fullNameArr[0]
        lastName = fullNameArr[1]
        
        let name = (getData["Fullname"] as! String).components(separatedBy: " ")
        if(name.count == 1)
        {
            txtFirstName.text = (getData["Fullname"] as! String).components(separatedBy: " ").first
            txtLastName.text = (getData["Fullname"] as! String)

        }
        else if(name.count == 2)
        {
            txtFirstName.text = (getData["Fullname"] as! String).components(separatedBy: " ").first
            txtLastName.text = (getData["Fullname"] as! String).components(separatedBy: " ").last

        }
        txtHomeNumber.text =  getData.object(forKey: "HomeNumber") as? String
      
        txtAddress.text = getData.object(forKey: "Address") as? String
        txtAge.text = getData.object(forKey: "AgeGroup") as? String
        gender = getData.object(forKey: "Gender") as! String
        
        if gender == "male" || gender == "Male" {
            viewMale.checkState = .checked
            viewMale.tintColor = themeYellowColor
            viewFemale.checkState = .unchecked
        }
        else {
            viewMale.checkState = .unchecked
            viewFemale.tintColor = themeYellowColor
            viewFemale.checkState = .checked
        }
    }
    
    @IBAction func viewMale(_ sender: M13Checkbox) {
        
        viewMale.checkState = .checked
        viewMale.tintColor = UIColor.init(red: 237/255, green: 122/255, blue: 4/255, alpha: 1.0)
        viewFemale.checkState = .unchecked

        gender = "Male"
        
    }
    
    @IBAction func viewFemale(_ sender: M13Checkbox) {
        
        viewFemale.checkState = .checked
        viewFemale.tintColor = themeYellowColor
        viewMale.checkState = .unchecked
        
        gender = "Female"
        
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
         self.navigationController?.popViewController(animated: true)
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    //PassengerId,Fullname,Gender,Address,AgeGroup,HomeNumber,Image

    func webserviceOfUpdateProfile()
    {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        
        fullName = txtFirstName.text! + " " + txtLastName.text!
        
        var dictData = [String:AnyObject]()
        dictData["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        dictData["Fullname"] = fullName as AnyObject
        dictData["Gender"] = gender as AnyObject
        dictData["Address"] = txtAddress.text as AnyObject
        dictData["AgeGroup"] = txtAge.text as AnyObject
        dictData["HomeNumber"] = txtHomeNumber.text as AnyObject
        
//      dictData["DOB"] = txtDateOfBirth.text as AnyObject//binal
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        webserviceForUpdateProfile(dictData as AnyObject, image1: imgProfile.image!) { (result, status) in
            
            if (status) {
                
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                
                print(result)
                SingletonClass.sharedInstance.dictProfile = NSMutableDictionary(dictionary: (result as! NSDictionary).object(forKey: "profile") as! NSDictionary)
                
                UserDefaults.standard.set(SingletonClass.sharedInstance.dictProfile, forKey: "profileData")
                NotificationCenter.default.post(name: NotificationKeyforUpdateProfileDetail, object: nil)
                
                UtilityClass.setCustomAlert(title: "Success Message", message: "Your Profile has been updated.") { (index, title) in
                    self.perform(#selector(self.goBack), with: nil, afterDelay: 1.0)
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
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

////respons
//profile =     {
//    ABN = "";
//    Address = "Ahmedabad ";
//    AgeGroup = "18 to 25";
//    BSB = "";
//    BankAccountNo = "";
//    BankName = "";
//    CompanyName = "";
//    CreatedDate = "2018-10-12 14:45:13";
//    DOB = "0000-00-00";
//    Description = "";
//    DeviceType = 1;
//    Email = "bhautik@exellentwebworld.in";
//    Fullname = "nasit  medium ";
//    Gender = Female;
//    HomeNumber = 7878616495;
//    Id = 12;
//    Image = "http://13.237.0.107/web/images/passenger/9dd2cc216ba8896069e035fbc70c445c.png";
//    Lat = 6287346872364287;
//    LicenceImage = "";
//    Lng = 6287346872364287;
//    MobileNo = 641122334456;
//    PassportImage = "";
//    Password = 25d55ad283aa400af464c76d713c07ad;
//    QRCode = "http://13.237.0.107/web/images/qrcode/cGFzc2VuZ2VyXzY0MTEyMjMzNDQ1Ng==.png";
//    ReferralCode = ezgops12bha;
//    Status = 1;
//    Token = "";
//    Trash = 0;
//    Verify = 0;
//    ZipCode = 380054;
//};
