//
//  SplashViewController.Swift
//  TickTok User
//
//  Created by Excellent Webworld on 25/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    
    
    @IBOutlet var iconLogo: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iconLogo.alpha = 0
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        UIView.animate(withDuration: 0.6, animations:
            {
                self.iconLogo.alpha = 0.5
        })
        { (status) in
            
            
            
            UIView.animate(withDuration: 1, animations:
                {
                   
            })
            { (status) in
                self.iconLogo.alpha = 1
            }
        }
        
        self.perform(#selector(moveToLogin), with: nil, afterDelay: 6.0)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func moveToLogin()
    {
        let StroyBordLogin = UIStoryboard(name: "Login", bundle: nil)
      
        let SplaceScreenVc: UIViewController = StroyBordLogin.instantiateViewController(withIdentifier: "SplashViewController")
        let LoginVc: UIViewController = StroyBordLogin.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(SplaceScreenVc, animated: false)
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
