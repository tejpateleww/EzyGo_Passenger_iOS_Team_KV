//
//  RegistrationContainerViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class RegistrationContainerViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var firstStep: UIImageView!
    
    @IBOutlet weak var secondStep: UIImageView!
    
    @IBOutlet weak var ThirdStep: UIImageView!
    
    
    @IBOutlet weak var scrollObject: UIScrollView!
    
    var strEmail:String = ""
    var strFirstName:String = ""
    var strLastName:String = ""
    var isFromSocialLogin:Bool = false
    var strSocialID:String = ""
    var SocialType:String = ""
  

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollObject.delegate = self
        print(isFromSocialLogin)
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        UIApplication.shared.isStatusBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func selectPageControlIndex(Index:Int) {
        self.firstStep.image = UIImage(named: "Unselected_Circle")
        self.secondStep.image = UIImage(named: "Unselected_Circle")
        self.ThirdStep.image = UIImage(named: "Unselected_Circle")
        
        if Index == 0 {
            self.firstStep.image = UIImage(named: "Selected_Circle")
        } else if Index == 1 {
            self.secondStep.image = UIImage(named: "Selected_Circle")
        } else if Index == 2 {
            self.ThirdStep.image = UIImage(named: "Selected_Circle")
        }
        
    }
    
    @IBAction func btnBack(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//        let currentPage = scrollView.contentOffset.x / scrollView.frame.size.width
//        self.pageControl.set(progress: Int(0), animated: true)
        let currentPage = self.scrollObject.contentOffset.x / self.scrollObject.frame.size.width

        if (currentPage == 0)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else if (currentPage == 1){
            self.scrollObject.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.selectPageControlIndex(Index: 0)
//            self.pageControl.set(progress: 0, animated: true)
        }
        else
        {
            self.selectPageControlIndex(Index: 0)
            self.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
//            self.pageControl.set(progress: 0, animated: true)
        }

    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentPage = scrollView.contentOffset.x / scrollView.frame.size.width
//        self.pageControl.set(progress: Int(currentPage), animated: true)
            self.selectPageControlIndex(Index: 0)
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
