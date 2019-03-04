//
//  LoginViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 25/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import Foundation
import UIKit
import TransitionButton
import ACFloatingTextfield_Swift
//import SideMenu
import NVActivityIndicatorView
import CoreLocation
import FBSDKLoginKit
import FacebookLogin
import GoogleSignIn
import GoogleMaps
import GooglePlaces


class LoginViewController: UIViewController, CLLocationManagerDelegate, alertViewMethodsDelegates,GIDSignInDelegate,GIDSignInUIDelegate, UITextFieldDelegate {
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var btnLogin: TransitionButton!
    @IBOutlet weak var btnSignup: TransitionButton!
    
    
    var locationManager = CLLocationManager()

    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func loadView() {
        super.loadView()
        
        if Connectivity.isConnectedToInternet() {
            print("Yes! internet is available.")
            // do some tasks..
        }
        else {
            print("No! internet is not available.")
//            UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
//            }
        }
        
//        if SingletonClass.sharedInstance.isUserLoggedIN == true {
            webserviceOfAppSetting()
//        }
        
        locationManager.requestAlwaysAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))
            {
                if locationManager.location != nil
                {
                    locationManager.startUpdatingLocation()
                    locationManager.delegate = self
                }
                //                manager.startUpdatingLocation()
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        txtEmail.text = "1122334456"
//        txtPassword.text = "12345678"
        
        
        viewMain.isHidden = true
        btnLogin.titleLabel?.text = "Log In"

        
//        txtEmail.lineColor = UIColor.white
//        txtPassword.lineColor = UIColor.white

//        if UIDevice.current.name == "Bhavesh iPhone" || UIDevice.current.name == "Excellent Web's iPhone 5s" || UIDevice.current.name == "Rahul's iPhone"
//        {
//
////            txtEmail.text = "1122334456"
////            txtPassword.text = "12345678"
//        }
        
        btnSignup.layer.borderWidth = 1.0
        btnSignup.layer.borderColor = UIColor.white.cgColor
        
        UtilityClass.setCornerRadiusTextField(textField: txtEmail, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        
        UtilityClass.setCornerRadiusTextField(textField: txtPassword, borderColor: UIColor.white, bgColor: UIColor.clear, textColor: UIColor.white)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    //MARK: - Validation
    
    func checkValidation() -> Bool
    {
        if (txtEmail.text?.count == 0)
        {

            UtilityClass.setCustomAlert(title: "", message: "Enter Phone Number") { (index, title) in
            }
            
             // txtEmail.showErrorWithText(errorText: "Enter Email")
            return false
        }
        else if (txtPassword.text?.count == 0)
        {

            UtilityClass.setCustomAlert(title: "", message: "Enter Password") { (index, title) in
            }

            return false
        }
        return true
    }
    
    
    @IBAction func textDidChange(_ sender: UITextField) {
        if !sender.text!.isEmpty {
            txtEmail.text = removeZeros(from: sender.text!)
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtEmail && range.location == 0 {
            
            if string == "0" {
                return false
            }
            
            //            let resultText: String? = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            //            if resultText!.count >= 11 {
            //                return false
            //            }
            //            else {
            //                return true
            //            }
        }
        
        return true
    }
    
    func removeZeros(from anyString: String?) -> String? {
        if anyString?.hasPrefix("0") ?? false && (anyString?.count ?? 0) > 1 {
            return removeZeros(from: (anyString as NSString?)?.substring(from: 1))
        } else {
            return anyString
        }
    }
    
    //MARK: - Webservice Call for Login
    
    func webserviceCallForLogin()
    {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        let dictparam = NSMutableDictionary()
        dictparam.setObject(txtEmail.text!, forKey: "Username" as NSCopying)
        dictparam.setObject(txtPassword.text!, forKey: "Password" as NSCopying)
        dictparam.setObject("1", forKey: "DeviceType" as NSCopying)
        dictparam.setObject("6287346872364287", forKey: "Lat" as NSCopying)
        dictparam.setObject("6287346872364287", forKey: "Lng" as NSCopying)
        dictparam.setObject(SingletonClass.sharedInstance.deviceToken, forKey: "Token" as NSCopying)
        
        webserviceForDriverLogin(dictparam) { (result, status) in
            
            if ((result as! NSDictionary).object(forKey: "status") as! Int == 1)
            {
//                DispatchQueue.main.async(execute: { () -> Void in

//                    self.btnLogin.stopAnimation(animationStyle: .normal, completion: {
                        SingletonClass.sharedInstance.dictProfile = NSMutableDictionary(dictionary: (result as! NSDictionary).object(forKey: "profile") as! NSDictionary)
                        SingletonClass.sharedInstance.arrCarLists = NSMutableArray(array: (result as! NSDictionary).object(forKey: "car_class") as! NSArray)
                        SingletonClass.sharedInstance.strPassengerID = String(describing: SingletonClass.sharedInstance.dictProfile.object(forKey: "Id")!)//as! String
                        SingletonClass.sharedInstance.isUserLoggedIN = true
                        
                        UserDefaults.standard.set(SingletonClass.sharedInstance.dictProfile, forKey: "profileData")
                        UserDefaults.standard.set(SingletonClass.sharedInstance.arrCarLists, forKey: "carLists")

                        self.webserviceForAllDrivers()
                        
//                        self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
//                    })
                }
                
        
            else
            {
//                self.btnLogin.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: {
                
//                    let next = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertsViewController") as! CustomAlertsViewController
//                    next.delegateOfAlertView = self
//                    next.strTitle = "Error"
//                    next.strMessage = (result as! NSDictionary).object(forKey: "message") as! String
//                    self.navigationController?.present(next, animated: false, completion: nil)
//

                     UtilityClass.setCustomAlert(title: alertTitle, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
            }

//                })
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "segueToHomeVC") {
//
//        }
    }

    
    var aryAllDrivers = NSArray()
    func webserviceForAllDrivers()
    {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        webserviceForAllDriversList { (result, status) in
            
            if (status) {
                
                self.aryAllDrivers = ((result as! NSDictionary).object(forKey: "drivers") as! NSArray)
                
                SingletonClass.sharedInstance.allDiverShowOnBirdView = self.aryAllDrivers
                UtilityClass.getAppDelegate().GoToHome()
// Bhautik
                
//                self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
                
                
//            let MainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//            let CustomSideMenu = MainStoryBoard.instantiateViewController(withIdentifier: "CustomSideMenuViewController") as! CustomSideMenuViewController
//            self.navigationController?.pushViewController(CustomSideMenu, animated: true)
            
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
    
     //MARK: - Webservice Call for Forgot Password

//    
//    func webserviceCallForForgotPassword(strEmail : String)
//    {
//        let dictparam = NSMutableDictionary()
//        dictparam.setObject(strEmail, forKey: "MobileNo" as NSCopying)
//        let activityData = ActivityData()
//        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
//        webserviceForForgotPassword(dictparam) { (result, status) in
//            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
//
//            if ((result as! NSDictionary).object(forKey: "status") as! Int == 1) {
//  
//                 UtilityClass.setCustomAlert(title: "Success", message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
//                }
//            }
//            else {
//
//                 UtilityClass.setCustomAlert(title: alertTitle, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
//                }
//            }
//        }
//
    func webserviceCallForForgotPassword(strEmail : String)
    {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        let dictparam = NSMutableDictionary()
        dictparam.setObject(strEmail, forKey: "MobileNo" as NSCopying)

        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        webserviceForForgotPassword(dictparam) { (result, status) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

            if ((result as! NSDictionary).object(forKey: "status") as! Int == 1) {
  
                 UtilityClass.setCustomAlert(title: "Success", message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                }
            }
            else {
                UtilityClass.setCustomAlert(title: alertTitle, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                }
            }
        }
    }
    
    func webserviceOfAppSetting() {
//        version : 1.0.0 , (app_type : AndroidPassenger , AndroidDriver , IOSPassenger , IOSDriver)

        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        
        print("Vewsion : \(version)")
        
        var param = String()
        param = version + "/" + "IOSPassenger"
        webserviceForAppSetting(param as AnyObject) { (result, status) in
            
            if (status) {
                print("result is : \(result)")

                self.viewMain.isHidden = false
                
                if ((result as! NSDictionary).object(forKey: "update") as? Bool) != nil {
                    
                    let alert = UIAlertController(title: nil, message: (result as! NSDictionary).object(forKey: "message") as? String, preferredStyle: .alert)
                    let UPDATE = UIAlertAction(title: "UPDATE", style: .default, handler: { ACTION in
                        
//                        UIApplication.shared.openURL(NSURL(string: "https://itunes.apple.com/us/app/pick-n-go/id1320783092?mt=8")! as URL)
                    })
                    let Cancel = UIAlertAction(title: "Cancel", style: .default, handler: { ACTION in
                        
                        if(SingletonClass.sharedInstance.isUserLoggedIN)
                        {
//                            self.webserviceForAllDrivers()
                            
                            // Bhautik
                            UtilityClass.getAppDelegate().GoToHome()

                        }
                    })
                    alert.addAction(UPDATE)
                    alert.addAction(Cancel)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    
                    if(SingletonClass.sharedInstance.isUserLoggedIN) {
                        
                        // Bhautik
                        UtilityClass.getAppDelegate().GoToHome()
                    }
                }
            }
            else {
                print(result)
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: alertTitle, message: res) { (index, title) in
                    }
                }
                else if let update = (result as! NSDictionary).object(forKey: "update") as? Bool {
                    
                    if (update) {

                        UtilityClass.showAlertWithCompletion("", message: (result as! NSDictionary).object(forKey: "message") as! String, vc: self, completionHandler: { ACTION in
                            
//                            UIApplication.shared.open((NSURL(string: "https://itunes.apple.com/us/app/pick-n-go/id1320783092?mt=8")! as URL), options: [:], completionHandler: { (status) in
                            
//                            })//openURL(NSURL(string: "https://itunes.apple.com/us/app/pick-n-go/id1320783092?mt=8")! as URL)
                        })
                    }
                    else {

                         UtilityClass.setCustomAlert(title: alertTitle, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                            if (index == 0)
                            {
//                                UIApplication.shared.open((NSURL(string: "https://itunes.apple.com/us/app/pick-n-go/id1320783092?mt=8")! as URL), options: [:], completionHandler: { (status) in
                                
//                                })
                            }
                        }

                    }
                    
                }
/*
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
 */
            }
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
    }
    
    
    @IBAction func btnGoogleClicked(_ sender: Any) {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self as GIDSignInUIDelegate
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    //MARK: - Google SignIn Delegate -
    
    func signInWillDispatch(signIn: GIDSignIn!, error: Error!)
    {
        // myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        UIApplication.shared.statusBarStyle = .default
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!)
    {
        UIApplication.shared.statusBarStyle = .lightContent
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        
        if (error == nil)
        {
            // Perform any operations on signed in user here.
            let userId : String = user.userID // For client-side use only!
            let firstName : String  = user.profile.givenName
            let lastName : String  = user.profile.familyName
            let email : String = user.profile.email
            
            var dictUserData = [String: AnyObject]()
            var image = UIImage()
            if user.profile.hasImage
            {
                let pic = user.profile.imageURL(withDimension: 400)
                let imgUrl: String = (pic?.absoluteString)!
                print(imgUrl)
                let url = URL(string: imgUrl as! String)
                let data = try? Data(contentsOf: url!)
                
                if let imageData = data {
                    image = UIImage(data: imageData)!
                }else {
                    image = UIImage(named: "iconUser")!
                }
                
                //                dictUserData["image"] = strImage as AnyObject
            }
            
//            var strFullName = ""
//
//            if Utili !Utilities.isEmpty(str: firstName)
//            {
//                strFullName = strFullName + ("\(firstName)")
//            }
//            if !Utilities.isEmpty(str: strFullName) {
//                strFullName = strFullName + (" \(lastName)")
//            }
            
            
            //            dictUserData["profileimage"] = "" as AnyObject
            dictUserData["Firstname"] = firstName as AnyObject
            dictUserData["Lastname"] = lastName as AnyObject
            dictUserData["Email"] = email as AnyObject
            dictUserData["MobileNo"] = "" as AnyObject
            dictUserData["Lat"] = "6287346872364287" as AnyObject
            dictUserData["Lng"] = "6287346872364287" as AnyObject
            dictUserData["SocialId"] = userId as AnyObject
            dictUserData["SocialType"] = "Google" as AnyObject
            dictUserData["Token"] = SingletonClass.sharedInstance.deviceToken as AnyObject
            dictUserData["DeviceType"] = "1" as AnyObject
            self.webserviceForSocilLogin(dictUserData as AnyObject, ImgPic: image, socialId: userId, SocialType:"Google")
        }
        else
        {
            print("\(error.localizedDescription)")
        }
        
    }
    
    //MARK: - Webservice methods -
    func webserviceForSocilLogin(_ dictData : AnyObject, ImgPic : UIImage, socialId:String, SocialType:String)
    {
        webserviceForSocialLogin(dictData as AnyObject) { (result, status) in
            if(status)
            {
                
//                let dictData = result as! [String : AnyObject]
                SingletonClass.sharedInstance.dictProfile = NSMutableDictionary(dictionary: (result as! NSDictionary).object(forKey: "profile") as! NSDictionary)
                SingletonClass.sharedInstance.arrCarLists = NSMutableArray(array: (result as! NSDictionary).object(forKey: "car_class") as! NSArray)
                SingletonClass.sharedInstance.strPassengerID = String(describing: SingletonClass.sharedInstance.dictProfile.object(forKey: "Id")!)//as! String
                SingletonClass.sharedInstance.isUserLoggedIN = true
                
                UserDefaults.standard.set(SingletonClass.sharedInstance.dictProfile, forKey: "profileData")
                UserDefaults.standard.set(SingletonClass.sharedInstance.arrCarLists, forKey: "carLists")
                
                self.webserviceForAllDrivers()
//                let dict = dictData["profile"] as! [String : AnyObject]
//                let tempID = dict["Id"] as? String
                
            }
            else
            {
                print(result)
                if let res = result as? String
                {
                    UtilityClass.showAlert(appName, message: res, vc: self)
                }
                else if let resDict = result as? NSDictionary
                {
                    
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationContainerViewController") as!  RegistrationContainerViewController
                   
                    viewController.strEmail = dictData["Email"] as! String
                    viewController.strFirstName = dictData["Firstname"] as! String
                    viewController.strLastName = dictData["Lastname"] as! String
                    viewController.isFromSocialLogin = true
                    viewController.strSocialID = socialId
                    viewController.SocialType = SocialType
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                }
                else if let resAry = result as? NSArray
                {
                    UtilityClass.showAlert(appName, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)

                }
            }
        }
    }

    
    @IBAction func btnFBClicked(_ sender: Any) {
    
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        let login = FBSDKLoginManager()
        login.loginBehavior = FBSDKLoginBehavior.browser
        UIApplication.shared.statusBarStyle = .default
        login.logOut()
        login.logIn(withReadPermissions: ["public_profile","email"], from: self) { (result, error) in
            
            
            if error != nil
            {
                UIApplication.shared.statusBarStyle = .lightContent
            }
            else if (result?.isCancelled)!
            {
                UIApplication.shared.statusBarStyle = .lightContent
            }
            else
            {
                if (result?.grantedPermissions.contains("email"))!
                {
                    UIApplication.shared.statusBarStyle = .lightContent
                    self.getFBUserData()
                }
                else
                {
                    print("you don't have permission")
                }
            }
        }
        
    }
    
    
    //function is fetching the user data from Facebook
    
    func getFBUserData()
    {
        
        //        Utilities.showActivityIndicator()
        
        var parameters = [AnyHashable: Any]()
        parameters["fields"] = "first_name, last_name, picture, email,id"
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: parameters).start { (connection, result, error) in
            if error == nil
            {
                print("\(#function) \(result)")
                let dictData = result as! [String : AnyObject]
                let strFirstName = String(describing: dictData["first_name"]!)
                let strLastName = String(describing: dictData["last_name"]!)
                let strEmail = String(describing: dictData["email"]!)
                let strUserId = String(describing: dictData["id"]!)
                
                //                //NSString *strPicurl = [NSString stringWithFormat:@"%@",[[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
                let imgUrl = ((dictData["picture"] as! [String:AnyObject])["data"]  as! [String:AnyObject])["url"] as? String
                
                //                var imgUrl = "http://graph.facebook.com/\(strUserId)/picture?type=large"
                
                
                
                //                let pictureDict = self.report["picture"]!["data"] as AnyObject
                //                let imgUrl = pictureDict["url"] as AnyObject
                
                var image = UIImage()
                let url = URL(string: imgUrl as! String)
                let data = try? Data(contentsOf: url!)
                
                if let imageData = data {
                    image = UIImage(data: imageData)!
                }else {
                    image = UIImage(named: "iconUser")!
                }
                
                var dictUserData = [String: AnyObject]()
                
                dictUserData["Firstname"] = strFirstName as AnyObject
                dictUserData["Lastname"] = strLastName as AnyObject
                dictUserData["Email"] = strEmail as AnyObject
                dictUserData["MobileNo"] = "" as AnyObject
                dictUserData["Lat"] = "6287346872364287" as AnyObject
                dictUserData["Lng"] = "6287346872364287" as AnyObject
                dictUserData["SocialId"] = strUserId as AnyObject
                dictUserData["SocialType"] = "Facebook" as AnyObject
                dictUserData["Token"] = SingletonClass.sharedInstance.deviceToken as AnyObject
                dictUserData["DeviceType"] = "1" as AnyObject
                
                self.webserviceForSocilLogin(dictUserData as AnyObject, ImgPic: image, socialId: strUserId,SocialType: "Facebook")
                
                //                self.APIcallforSocialMedia(dictParam: dictUserData)
                
                //                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                //                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    
    
    @IBAction func btnLogin(_ sender: Any) {
        self.view.endEditing(true)
        if (checkValidation()) {
//            self.btnLogin.startAnimation()
            self.webserviceCallForLogin()
        }
    }
    
    @IBAction func btnSignup(_ sender: Any) {
       let Registercontainer = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationContainerViewController") as!  RegistrationContainerViewController
      
        self.navigationController?.pushViewController(Registercontainer, animated: true)
        
    }
    
    
    @IBAction func btnForgotPassword(_ sender: UIButton) {
        
        performSegue(withIdentifier: "segueToForgotPassword", sender: self)
        
//
//        //1. Create the alert controller.
//        let alert = UIAlertController(title: "Forgot Password?", message: "Enter Mobile Number", preferredStyle: .alert)
//
//        //2. Add the text field. You can configure it however you need.
//        alert.addTextField { (textField) in
//
//            textField.placeholder = "Mobile Number"
//        }
//
//        // 3. Grab the value from the text field, and print it when the user clicks OK.
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
//            print("Text field: \(String(describing: textField?.text))")
//
//            if (textField?.text?.count != 0)
//            {
//                self.webserviceCallForForgotPassword(strEmail: (textField?.text)!)
//            }
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
//        }))
//
//        // 4. Present the alert.
//        self.present(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Location Methods
    //-------------------------------------------------------------
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
//        print("Location: \(location)")
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
           
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func didOKButtonPressed() {
        
    }
    
    func didCancelButtonPressed() {
        
    }
    
    
    func setCustomAlert(title: String, message: String) {
        AJAlertController.initialization().showAlertWithOkButton(aStrTitle: title, aStrMessage: message) { (index,title) in
        }
        
//        let next = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertsViewController") as! CustomAlertsViewController
//
//        next.delegateOfAlertView = self
//        next.strTitle = title
//        next.strMessage = message
//
//        self.navigationController?.present(next, animated: false, completion: nil)
        
    }
    
}
