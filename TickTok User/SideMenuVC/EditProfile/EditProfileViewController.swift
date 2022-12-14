//
//  EditProfileViewController.swift
//  TickTok User
//
//  Created by Excelent iMac on 23/12/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    //-----------------------------------------------------------
    // MARK: - Outlets
    //-----------------------------------------------------------
    
    @IBOutlet weak var viewEditProfile: UIView!
    @IBOutlet weak var viewAccount: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnEditProfile.layer.cornerRadius = btnEditProfile.frame.width / 2
//        btnEditProfile.layer.borderWidth = 1.0
        btnEditProfile.layer.masksToBounds = true
        btnAccount.layer.cornerRadius = btnAccount.frame.width / 2
      //btnAccount.layer.borderWidth = 1.0
        btnAccount.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewEditProfile.layer.cornerRadius = 10
        viewEditProfile.layer.masksToBounds = true
        
        viewAccount.layer.cornerRadius = 10
        viewAccount.layer.masksToBounds = true
       
//        self.ConstraintEditProfileX.constant = self.view.frame.origin.x - viewEditProfile.frame.size.width - 20
//        self.constraintAccountTailing.constant = -(viewEditProfile.frame.size.width + 20)
//        AnimationToView()
        setImageColor()
//
//        iconProfile.image = setImageColorOfImage(name: "iconEditProfile")
//        iconAccount.image = setImageColorOfImage(name: "iconAccount")
        
        btnEditProfile.layer.cornerRadius = 30
        btnEditProfile.layer.masksToBounds = true
    
        btnAccount.layer.cornerRadius = 30
        btnAccount.layer.masksToBounds = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        ConstraintEditProfileX.constant = -(self.view.frame.size.width)
//        constraintAccountTailing.constant = -(self.view.frame.size.width)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        AnimationToView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func setImageColor() {
        
//        let img = UIImage(named: "iconArrowGrey")
//        imgArrowProfile.image = img?.maskWithColor(color: UIColor.white)
//        imgArrowAccount.image = img?.maskWithColor(color: UIColor.white)
    }
    
    
    
    
    func setImageColorOfImage(name: String) -> UIImage {
        
        let imageView = UIImageView()
        
        let img = UIImage(named: name)
        imageView.image = img?.maskWithColor(color: UIColor.white)
       
        
        return imageView.image!
    }
    

    //----------------------------------------------------------
    // MARK: - Actions
    //----------------------------------------------------------
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
//        AnimationToView()
        
        print("Back Button Clicked")
        
    }
    
    @IBAction func btnEditProfile(_ sender: UIButton) {
        performSegue(withIdentifier: "SegueToEditProfile", sender: self)
    }
    
    @IBAction func btnEditAccount(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToEditAccountVc", sender: self)
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
//    func AnimationToView() {
//
//        self.ConstraintEditPr    ofileX.constant = self.view.frame.origin.x - viewEditProfile.frame.size.width - 20
//        self.constraintAccountTailing.constant = -(viewEditProfile.frame.size.width + 20)
//
//        self.viewMain.layoutIfNeeded()
//
//        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseIn, animations: {
//
//
//            self.ConstraintEditProfileX.constant = 20
//            self.constraintAccountTailing.constant = 20
//
//            self.viewMain.layoutIfNeeded()
//
//
//        }, completion: { finished in
//
//        })
//
//
//    }
    

}


extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}
