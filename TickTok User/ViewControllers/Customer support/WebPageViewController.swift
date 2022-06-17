//
//  WebPageViewController.swift
//  EZYGO Rider
//
//  Created by EWW-iMac Old on 28/11/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class WebPageViewController: UIViewController,UIWebViewDelegate {

    
    var HeaderTitle:String = ""
    var URLString:String = ""
    
    
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblWebViewHeader: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.scalesPageToFit = true
        self.webView.delegate =  self
        self.webView.contentMode = .scaleAspectFit
        self.lblWebViewHeader.text = HeaderTitle
        if Connectivity.isConnectedToInternet() == false {
            
            UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        
        self.webView.loadRequest(URLRequest(url: URL(string: URLString)!))
        UtilityClass.showHUD()
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UtilityClass.hideHUD()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UtilityClass.hideHUD()
    }

}
