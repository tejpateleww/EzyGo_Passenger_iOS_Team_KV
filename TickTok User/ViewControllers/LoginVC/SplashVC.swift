//
//  SplashVC.swift
//  EZYGO Rider
//
//  Created by Excellent's iMac on 15/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

    
    @IBOutlet var iconLogo: UIImageView!
    
    @IBOutlet weak var imgBackGround: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iconLogo.alpha = 0
        self.imgBackGround.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        UIView.animate(withDuration: 0.6, animations:
            {
                self.iconLogo.alpha = 0.5
                self.imgBackGround.alpha = 0.5
        })
        { (status) in
            
            UIView.animate(withDuration: 1, animations:
                {
            })
            { (status) in
                self.iconLogo.alpha = 1
                self.imgBackGround.alpha = 1
                self.perform(#selector(self.moveToLogin), with: nil, afterDelay: 2.0)

            }
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func moveToLogin()
    {
        let StroyBordLogin = UIStoryboard(name: "Login", bundle: nil)
//
//        let SplaceScreenVc: UIViewController = StroyBordLogin.instantiateViewController(withIdentifier: "SplashVC")
        let LoginVc: UIViewController = StroyBordLogin.instantiateViewController(withIdentifier: "LoginViewController")
//        self.navigationController?.pushViewController(SplaceScreenVc, animated: false)
        self.navigationController?.pushViewController(LoginVc, animated: false)
        
        
        //        let storybordLogin * LoginStoryBoard = [UIStoryboard]
        //
        //        let viewLoginController = self.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        //        let viewHomeController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        
        
        //                if (UserDefaults.standard.object(forKey:  driverProfileKeys.kKeyDriverProfile) != nil)
        //                {
        //                    SingletonClass.sharedInstance.isDriverLoggedIN = true
        //
        //                }
        //                else
        //                {
        //                    SingletonClass.sharedInstance.isDriverLoggedIN = false
        
        //                }
        
        
    }
    
}
