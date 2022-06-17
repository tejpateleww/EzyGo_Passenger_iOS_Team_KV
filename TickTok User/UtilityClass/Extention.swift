//
//  Extention.swift
//  EZYGO Rider
//
//  Created by EWW-iMac Old on 14/11/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation
import UIKit
import ACFloatingTextfield_Swift

extension ACFloatingTextfield {
    
    func setTitleColor() {
//        self.placeHolderColor = themeYellowColor
    }
    
}

extension UITextField {
    
    func setCurrencyLeftView() {
        
        let LeftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        LeftLabel.font = self.font
        LeftLabel.textAlignment = .center
        LeftLabel.text = currencySign
        LeftLabel.textColor = UIColor.black
        LeftLabel.backgroundColor = UIColor.white
        self.leftView = LeftLabel
        self.leftViewMode = .always
    }
}


extension Date {
    
    func getLocalDateOnly() -> Date {
        
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "dd-MM-yyyy"
        let OnlyDateString = myDateFormatter.string(from: self)
        let OnlyDate = myDateFormatter.date(from: OnlyDateString)
        return OnlyDate!
    }
    
}


extension String {
    
    func isValidEmailAddress() -> Bool
    {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z)-9.-]+\\.[A-Za-z]{2,3}"
        
        do{
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            
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
    
}
