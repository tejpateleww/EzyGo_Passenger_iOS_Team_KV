//
//  InviteDriverViewController.swift
//  TiCKTOC-Driver
//
//  Created by Excellent Webworld on 14/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import MessageUI
import Social
import SDWebImage

class InviteDriverViewController: ParentViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {

    
    var strReferralCode = String()
    var strReferralMoney = String()
    
    
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet var imgProfilePick: UIImageView!
    @IBOutlet weak var lblReferralCode: UILabel!
//  @IBOutlet weak var lblReferralMoney: UILabel!
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
       

        let profileData = SingletonClass.sharedInstance.dictProfile

        if let ReferralCode = profileData.object(forKey: "ReferralCode") as? String {
            strReferralCode = ReferralCode
            self.lblReferralCode.text = self.strReferralCode
        }
        
        if let RefarMoney = profileData.object(forKey: "ReferralAmount") as? Double {
            strReferralMoney = String(RefarMoney)
//            self.lblReferralMoney.text = "\(currencySign) \(strReferralMoney)"
        }

        if let imgProfile = (profileData).object(forKey: "Image") as? String {
            
            imgProfilePick.sd_setShowActivityIndicatorView(true)
            imgProfilePick.sd_setIndicatorStyle(.gray)
            imgProfilePick.sd_setImage(with: URL(string: imgProfile), completed: nil)
        }

       
        
      

//        headerView?.btnBack.addTarget(self, action: #selector(self.nevigateToBack), for: .touchUpInside)
        
        imgProfilePick.layer.cornerRadius = imgProfilePick.frame.width / 2
        imgProfilePick.layer.masksToBounds = true
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
/*
    func nevigateToBack()
    {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: TabbarController.self) {
                self.sideMenuController?.embed(centerViewController: controller)
                break
            }
        }
    }
*/
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnFacebook(_ sender: UIButton) {
        
        let text = codeToSend()
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)

//        var fbController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
//
//        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
//            var completionHandler: SLComposeViewControllerCompletionHandler = {(_ result: SLComposeViewControllerResult) -> Void in
//                fbController?.dismiss(animated: true) { [weak self] in }
//                switch result {
//                case .done:
//                    print("Posted.")
//                case .cancelled:
//                    fallthrough
//                default:
//                    print("Cancelled.")
//                }
//            }
////            fbController?.add(UIImage(named: "1.jpg") ?? UIImage())
//            fbController?.setInitialText(codeToSend())
////            fbController.add(URL(string: "URLString")!)
//            fbController?.completionHandler = completionHandler
//            self.present(fbController!, animated: true) { [weak self] in }
//        }
//        else {
//
//            UtilityClass.setCustomAlert(title: "Not Available App", message: "Please install Facebook app") { (index, title) in
//            }
//        }
        
        
        
//            if let fbSignInDialog = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
//                fbSignInDialog.setInitialText("")
//                self.present(fbSignInDialog, animated: false) { [weak self] in }
//        }
//            else {
//                UtilityClass.setCustomAlert(title: "Not Available App", message: "Please install Facebook app") { (index, title) in
//                }
//            }
//        }

//        commingSoon()
        
    }
    
    @IBAction func btnTwitter(_ sender: UIButton) {
        
        let text = codeToSend()
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        

//        var TWController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//
//        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
//            var completionHandler: SLComposeViewControllerCompletionHandler = {(_ result: SLComposeViewControllerResult) -> Void in
//                TWController?.dismiss(animated: true) { [weak self] in }
//                switch result {
//                case .done:
//                    print("Posted.")
//                case .cancelled:
//                    fallthrough
//                default:
//                    print("Cancelled.")
//                }
//            }
//            //            fbController?.add(UIImage(named: "1.jpg") ?? UIImage())
//            TWController?.setInitialText(codeToSend())
//            //            fbController.add(URL(string: "URLString")!)
//            TWController?.completionHandler = completionHandler
//            self.present(TWController!, animated: true) { [weak self] in }
//        }
//        else {
//            if let twitterSignInDialog = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
//
//                twitterSignInDialog.setInitialText(codeToSend())
//
//                if twitterSignInDialog.serviceType == SLServiceTypeTwitter {
//                     self.present(twitterSignInDialog, animated: false)
//                }
//                else {
//
//                    UtilityClass.setCustomAlert(title: "Not Available App", message: "Please install Twitter app") { (index, title) in
//                    }
//                }
//
//            }
//            else {
//                UtilityClass.setCustomAlert(title: "Not Available App", message: "Please install Twitter app") { (index, title) in
//                }
//            }
//        }
 
//        commingSoon()
    }
    
    @IBAction func btnEmail(_ sender: UIButton) {
        
//        let emailTitle = ""
//        var messageBody = ""
//        let toRecipents = [""]
//
//        if (MFMailComposeViewController.canSendMail()) {
//            let mc: MFMailComposeViewController = MFMailComposeViewController()
//            mc.mailComposeDelegate = self
//            mc.setSubject(emailTitle)
//            mc.setMessageBody(codeToSend(), isHTML: false)
//            mc.setToRecipients(toRecipents)
//
//            self.present(mc, animated: true, completion: nil)
//        } else {
//            UtilityClass.setCustomAlert(title: "Email id Missing", message: "Please sign in from email settings") { (index, title) in
//            }
//        }
        
        
        let text = codeToSend()
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)

//        commingSoon()
    }
    
    @IBAction func btnWhatsApp(_ sender: UIButton) {

//        let urlString = codeToSend()
//        let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
//        let url = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
//        
//        if UIApplication.shared.canOpenURL(url! as URL) {
//            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
//        } else {
//
//            UtilityClass.setCustomAlert(title: "Not Available App", message: "Please install WhatsApp app") { (index, title) in
//            }
//
//        }
        
        let text = codeToSend()
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        
        

//      commingSoon()
    }
    
    @IBAction func btnSMS(_ sender: UIButton) {
        
//        if (MFMessageComposeViewController.canSendText()) {
//            let controller = MFMessageComposeViewController()
//            controller.messageComposeDelegate = self
//            controller.body = codeToSend()
//            controller.recipients = [""]
//            self.present(controller, animated: true, completion: nil)
//        }
        
        let text = codeToSend()
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        
//        commingSoon()
    }
    
    func commingSoon() {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "CommingSoonViewController") as! CommingSoonViewController
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
            UtilityClass.setCustomAlert(title: "Error", message: "Mail cancelled") { (index, title) in
            }

        case MFMailComposeResult.saved:
            print("Mail saved")
           
            UtilityClass.setCustomAlert(title: "Done", message: "Mail saved") { (index, title) in
            }
        case MFMailComposeResult.sent:
            print("Mail sent")
            
            UtilityClass.setCustomAlert(title: "Done", message: "Mail sent") { (index, title) in
            }
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
      
            UtilityClass.setCustomAlert(title: "Error", message: "Mail sent failure: \(String(describing: error?.localizedDescription))") { (index, title) in
            }
        default:
            
             UtilityClass.setCustomAlert(title: "Error", message: "Something went wrong") { (index, title) in
             }
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnMoreOption(_ sender: Any) {
        
        let messageBody = "\n Please download from below link \n \n"// \(urlForMail)\\url backend mle
        
        
        let activityViewController = UIActivityViewController(activityItems: [messageBody], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        switch result {
        case MessageComposeResult.cancelled:
            print("Mail cancelled")

            UtilityClass.setCustomAlert(title: "Error", message: "Mail cancelled") { (index, title) in
            }
        case MessageComposeResult.sent:
            print("Mail sent")
            
            UtilityClass.setCustomAlert(title: "Done", message: "Mail sent") { (index, title) in
            }
        case MessageComposeResult.failed:
            print("Mail sent failure")

            UtilityClass.setCustomAlert(title: "Error", message: "Mail sent failure") { (index, title) in
            }
        default:

             UtilityClass.setCustomAlert(title: "Error", message: "Something went wrong") { (index, title) in
             }
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }

    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    
    func codeToSend() -> String
    {
        let profile = SingletonClass.sharedInstance.dictProfile
        let driverFullName = profile.object(forKey: "Fullname") as! String
        let messageBody = "\(driverFullName) has invited you to become a \(appName) user"
        let androidLink = "Android click \("")"
 
        let iosLink = "iOS click \("https://goo.gl/L6XLqx")"
        
        let yourInviteCode = "Your invite code is: \(strReferralCode)"
        let urlOfTick = "http://www.pickngo.lk/ https://www.facebook.com/PickNGoSrilanka/"
        
        let urlString = "\(messageBody) \n \(androidLink) \n \(iosLink) \n \(yourInviteCode) \n \(urlOfTick)" as String
        return urlString
    }
    
}
