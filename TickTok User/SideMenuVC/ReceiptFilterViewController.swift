//
//  ReceiptFilterViewController.swift
//  EZYGO Rider
//
//  Created by EWW-iMac Old on 19/11/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit
import M13Checkbox

protocol FilterReceiptDelegate {
    func filterByBookId(BookingId:String)
    func filterByDate(FromDate:Date, ToDate:Date)
}

class ReceiptFilterViewController: UIViewController,WWCalendarTimeSelectorProtocol {

    @IBOutlet weak var ViewSearchBy: UIView!
    
    @IBOutlet weak var checkByBooking: M13Checkbox!
    @IBOutlet weak var checkByDate: M13Checkbox!
    
    var DateTimeselector = WWCalendarTimeSelector.instantiate()
    
    var FilterType:String = ""
    
    var FilterDelegate:FilterReceiptDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkByBooking.tintColor = themeYellowColor
        checkByBooking.stateChangeAnimation = .fill
        checkByBooking.boxType = .square
        
        checkByDate.tintColor = themeYellowColor
        checkByDate.stateChangeAnimation = .fill
        checkByDate.boxType = .square
        
        self.ViewSearchByID.isHidden = true
        self.ViewSearchByDate.isHidden = true
        
        DateTimeselector.delegate = self
        
        
        self.BookingIdError.alpha = 0.0
        self.lblDateError.alpha = 0.0
        
//        self.lblDateError.isHidden = true
//        self.BookingIdError.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Search By View
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- check Action Method
    
    @IBAction func btnCheckByDate(_ sender: Any) {
        self.setSelection(Index: 0)
    }
    
    
    @IBAction func btnCheckByBookId(_ sender: Any) {
        self.setSelection(Index: 1)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    func setSelection(Index:Int) {
        self.checkByDate.checkState = .unchecked
        self.checkByDate.stateChangeAnimation = .fill
        self.checkByBooking.checkState = .unchecked
        self.checkByBooking.stateChangeAnimation = .fill
        
        switch Index {
        case 0:
            self.checkByDate.checkState = .checked
            self.checkByDate.stateChangeAnimation = .fill
            self.FilterType = "Date"
        case 1:
            self.checkByBooking.checkState = .checked
            self.checkByBooking.stateChangeAnimation = .fill
            self.FilterType = "BookingID"
        default:
            break
        }
        
    }
    
    
    @IBAction func btnSearchOk(_ sender: Any) {
        
        if self.FilterType == "" {
            
        } else if self.FilterType == "Date" {
            self.ViewSearchByDate.isHidden = false
            self.ViewSearchBy.isHidden = true
        } else if self.FilterType == "BookingID" {
            self.ViewSearchByID.isHidden = false
            self.ViewSearchBy.isHidden = false
        }
        
    }
    

    //MARK:- Search By Date
    
    @IBOutlet weak var ViewSearchByDate: UIView!
    
    @IBOutlet weak var lblFromDate: UILabel!
    
    @IBOutlet weak var lblToDate: UILabel!
    
    @IBOutlet weak var lblDateError: UILabel!
    
    
    var isCalenderForFromDate:Bool = false
    
    var fromDate = Date()
    var toDate = Date()
    
    @IBAction func btnSelectFromDate(_ sender: Any) {
        self.isCalenderForFromDate = true
         DateTimeselector.optionCalendarFontColorPastDates = UIColor.gray
        DateTimeselector.optionButtonFontColorDone = themeYellowColor
        DateTimeselector.optionSelectorPanelBackgroundColor = themeYellowColor
        DateTimeselector.optionCalendarBackgroundColorTodayHighlight = themeYellowColor
        DateTimeselector.optionTopPanelBackgroundColor = themeYellowColor
        DateTimeselector.optionClockBackgroundColorMinuteHighlightNeedle = themeYellowColor
        DateTimeselector.optionClockBackgroundColorHourHighlight = themeYellowColor
        DateTimeselector.optionClockBackgroundColorAMPMHighlight = themeYellowColor
        DateTimeselector.optionCalendarBackgroundColorPastDatesHighlight = themeYellowColor
        DateTimeselector.optionCalendarBackgroundColorFutureDatesHighlight = themeYellowColor
        DateTimeselector.optionClockBackgroundColorMinuteHighlight = themeYellowColor
//        selector.optionStyles.showDateMonth(true)
        DateTimeselector.optionStyles.showYear(false)
//        selector.optionStyles.showMonth(true)
        DateTimeselector.optionStyles.showTime(false)
        
        // 2. You can then set delegate, and any customization options
        DateTimeselector.optionTopPanelTitle = "Please choose date"
        
//        DateTimeselector.optionIdentifier = "Time" as AnyObject
        
//        let dateCurrent = Date()
//        DateTimeselector.optionCurrentDate = dateCurrent.addingTimeInterval(30 * 60)
        
        // 3. Then you simply present it from your view controller when necessary!
        self.present(DateTimeselector, animated: true, completion: nil)
    }
    
    
    
    @IBAction func btnSelectToDate(_ sender: Any) {
        
        self.isCalenderForFromDate = false
        
        DateTimeselector.optionCalendarFontColorPastDates = UIColor.gray
        DateTimeselector.optionButtonFontColorDone = themeYellowColor
        DateTimeselector.optionSelectorPanelBackgroundColor = themeYellowColor
        DateTimeselector.optionCalendarBackgroundColorTodayHighlight = themeYellowColor
        DateTimeselector.optionTopPanelBackgroundColor = themeYellowColor
        DateTimeselector.optionClockBackgroundColorMinuteHighlightNeedle = themeYellowColor
        DateTimeselector.optionClockBackgroundColorHourHighlight = themeYellowColor
        DateTimeselector.optionClockBackgroundColorAMPMHighlight = themeYellowColor
        DateTimeselector.optionCalendarBackgroundColorPastDatesHighlight = themeYellowColor
        DateTimeselector.optionCalendarBackgroundColorFutureDatesHighlight = themeYellowColor
        DateTimeselector.optionClockBackgroundColorMinuteHighlight = themeYellowColor
        DateTimeselector.optionStyles.showYear(false)
        DateTimeselector.optionStyles.showTime(false)
        // 2. You can then set delegate, and any customization options
        
        DateTimeselector.optionTopPanelTitle = "Please choose date"
//        DateTimeselector.optionIdentifier = "Time" as AnyObject
        
//        let dateCurrent = Date()
//        DateTimeselector.optionCurrentDate = dateCurrent.addingTimeInterval(30 * 60)
        
        // 3. Then you simply present it from your view controller when necessary!
        self.present(DateTimeselector, animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnDateOk(_ sender: Any) {
        if self.lblFromDate.text?.count != 10 {
            self.lblDateError.text = "Please select from date."
            self.ShowDateError()
        } else if self.lblToDate.text?.count != 10 {
            self.lblDateError.text = "Please select to date."
            self.ShowDateError()
        } else if self.toDate < self.fromDate {
            self.lblDateError.text = "From date is greater than the to date."
            self.ShowDateError()
        } else {
            self.lblDateError.isHidden = true
            self.dismiss(animated: true) {
                self.FilterDelegate.filterByDate(FromDate: self.fromDate, ToDate: self.toDate)
            }
        }
        
    }
    
    func ShowDateError() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.lblDateError.alpha = 1.0
        }, completion: {
            (finished: Bool) -> Void in
            
            //Once the label is completely invisible, set the text and fade it back in
            
            // Fade in
            UIView.animate(withDuration: 1.0, delay: 3.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.lblDateError.alpha = 0.0
            }, completion: nil)
        })
    }
    
    
    
    
    //MARK:- Search By BookingId
    
    @IBOutlet weak var ViewSearchByID: UIView!
   
    @IBOutlet weak var txtBookingId: UITextField!
    
    @IBOutlet weak var BookingIdError: UILabel!
    
    
    @IBAction func btnSearchBookId(_ sender: Any) {
        
        if (self.txtBookingId.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count)! > 0 {
            self.dismiss(animated: true) {
                self.FilterDelegate.filterByBookId(BookingId: self.txtBookingId.text!)
            }
        } else {
            self.ShowBookingIdError()
        }
        
    }
    
    func ShowBookingIdError() {

        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.BookingIdError.alpha = 1.0
        }, completion: {
            (finished: Bool) -> Void in
            
            //Once the label is completely invisible, set the text and fade it back in
            
            // Fade in
            UIView.animate(withDuration: 1.0, delay: 3.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.BookingIdError.alpha = 0.0
            }, completion: nil)
        })
    }
    
    @objc func hideError(){
        UIView.animate(withDuration: 30) {
            self.BookingIdError.isHidden = true
        }
    }
    
    var currentDate = Date()
    
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date)
    {
        
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "dd-MM-yyyy"
        
        
        let SelectedDate = date.getLocalDateOnly()
        let finalDateSTring = myDateFormatter.string(from: date)
        if self.isCalenderForFromDate == true {
            self.lblFromDate.text = finalDateSTring
            self.fromDate = SelectedDate
        } else {
            self.lblToDate.text = finalDateSTring
            self.toDate = SelectedDate
        }
        
        
    }
    
    func WWCalendarTimeSelectorWillDismiss(_ selector: WWCalendarTimeSelector) {
        
    }
    
    func WWCalendarTimeSelectorDidDismiss(_ selector: WWCalendarTimeSelector) {
        
    }
    
    
    func WWCalendarTimeSelectorShouldSelectDate(_ selector: WWCalendarTimeSelector, date: Date) -> Bool {
        
        if date.getLocalDateOnly() <= currentDate.getLocalDateOnly() {
            return true
        }
        
        return false
    }
    

    
}
