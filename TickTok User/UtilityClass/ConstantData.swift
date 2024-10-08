 //
//  ConstantData.swift
//  TickTok User
//
//  Created by Excellent Webworld on 28/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import Foundation

let themeYellowColor: UIColor = UIColor.init(red: 190/255, green: 98/255, blue: 6/255, alpha: 1.0)//(red: 237/255, green: 122/255, blue: 4/255, alpha: 1.0)
let themeGrayColor: UIColor = UIColor.init(red: 114/255, green: 114/255, blue: 114/255, alpha: 1.0)
//let ThemeYellowColor : UIColor = UIColor.init(hex: ""BE6206)

let currencySign = "$"
let appName = "EZYGO Rider"
let alertTitle = "Ezygo"
let helpLineNumber = "1234567890"

 let kIsSocketEmited = "SocketEmited"

let googleAnalyticsTrackId = "UA-122360832-1"

//let appCurrentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String


struct WebserviceURLs {
    static let kTermOfUse_PrivacyPolicyURL = "https://ezygo.co.nz/web/ezygo-terms-of-use-privacy.pdf"
//    "https://ezygo.co.nz/web/ezygo-terms-conditions-without-JavaScript.pdf"
   
    static let kBaseURL                                 = "https://ezygo.co.nz/web/Passenger_Api/"
//    "http://13.237.0.107/web/Passenger_Api/"
    
    // "http://54.169.67.226/web/Passenger_Api/" // "https://pickngolk.info/web/Passenger_Api/" "http://54.169.67.226/web/Passenger_Api/" //
    static let kDriverRegister                          = "Register"
    static let kDriverLogin                             = "Login"
    static let kSocialLogin                             = "SocialLogin"
    static let kChangePassword                          = "ChangePassword"
    static let kUpdateProfile                           = "UpdateProfile"
    static let kForgotPassword                          = "ForgotPassword"
    static let kGetCarList                              = "GetCarClass"
    static let kMakeBookingRequest                      = "SubmitBookingRequest"
    static let kAdvancedBooking                         = "AdvancedBooking"
    static let kDriver                                  = "Driver"
    static let kBookingHistory                          = "BookingHistory/"
    static let kTripHistory                             = "TripReceipt"
    static let kPastBooking                             = "PastBooking/"
    static let kUpcomingBooking                         = "UpcomingBooking/"
    static let kOngoingBooking                          = "OngoingBooking/"
    static let kGetEstimateFare                         = "GetEstimateFare"
    static let kGetPromoCodeList                        = "PromoCodeList"
    static let kGetFeedbackList                         = "FeedbackList/"
    static let kCheckPromocode                          = "PromoCodeCheck"
    static let kImageBaseURL                            = "https://ezygo.co.nz/web/"
//    "http://13.237.0.107/web/" // "https://pickngolk.info/web/" "http://54.169.67.226/web/" //
    
    static let kCardsList                               = "Cards/"
    static let kPackageBookingHistory                   = "PackageBookingHistory"
    static let kBookPackage                             = "BookPackage"
    static let kCurrentBooking                          = "CurrentBooking/"
    static let kAddNewCard                              = "AddNewCard"
    static let kAddMoney                                = "AddMoney"
    static let kTransactionHistory                      = "TransactionHistory/"
    static let kSendMoney                               = "SendMoney"
    static let kQRCodeDetails                           = "QRCodeDetails"
    static let kRemoveCard                              = "RemoveCard/"
    static let kTickpay                                 = "Tickpay"
    static let kAddAddress                              = "AddAddress"
    static let kGetAddress                              = "GetAddress/"
    static let kRemoveAddress                           = "RemoveAddress/"
    static let kVarifyUser                              = "VarifyUser"
    static let kTickpayInvoice                          = "TickpayInvoice"
    static let kGetTickpayRate                          = "GetTickpayRate"
    static let kInit                                    = "Init/"
    static let kContactUs                               = "ContactUs"
    static let kDeleteAccount                           = "DeleteAccount"
    
    
    static let kReviewRating                            = "ReviewRating"
    static let kGetTickpayApprovalStatus                = "GetTickpayApprovalStatus/"
    static let kTransferToBank                          = "TransferToBank"
    static let kUpdateBankAccountDetails                = "UpdateBankAccountDetails"
    static let kOtpForRegister                          = "OtpForRegister"
    static let kGetPackages                             = "Packages"
    static let kMissBokkingRequest                      = "BookingMissRequest"
    static let kTrackRunningTrip                        = "TrackRunningTrip/"
    static let kLogout                                  = "Logout/"
    static let kDefaultCards                            = "SetDefaultCards/"
//    https://pickngolk.info/web/Passenger_Api/OtpForRegister
    
}

struct SocketData {
    
    static let kBaseURL                                     = "https://ezygo.co.nz:8080/"
//    "http://13.237.0.107:8080/"
    // "http://54.255.222.125:8080/" // "https://pickngolk.info:8081" "http://54.169.67.226:8080" //
    static let kNearByDriverList                            = "NearByDriverListIOS"
    static let kUpdatePassengerLatLong                      = "UpdatePassengerLatLong"
    static let kAcceptBookingRequestNotification            = "AcceptBookingRequestNotification"
    static let kArrivedDriverBookNowRequest                 = "DriverArrivedAtPickupLocation"
    static let kRejectBookingRequestNotification            = "RejectBookingRequestNotification"
    static let kPickupPassengerNotification                 = "PickupPassengerNotification"
    static let kBookingCompletedNotification                = "BookingDetails"
    static let kCancelTripByPassenger                       = "CancelTripByPassenger"
    static let kCancelTripByDriverNotficication             = "PassengerCancelTripNotification"
    static let kSendDriverLocationRequestByPassenger        = "se"
    static let kReceiveDriverLocationToPassenger            = "GetDriverLocation"
    static let kReceiveHoldingNotificationToPassenger       = "TripHoldNotification"
    static let kSendRequestForGetEstimateFare               = "EstimateFare"
    static let kReceiveGetEstimateFare                      = "GetEstimateFare"
    static let kAcceptAdvancedBookingRequestNotification    = "AcceptAdvancedBookingRequestNotification"
    static let kArrivedDriverBookLaterRequest               = "AdvanceBookingDriverArrivedAtPickupLocation"
    static let kRejectAdvancedBookingRequestNotification    = "RejectAdvancedBookingRequestNotification"
    static let kAdvancedBookingPickupPassengerNotification  = "AdvancedBookingPickupPassengerNotification"
    static let kAdvancedBookingTripHoldNotification         = "AdvancedBookingTripHoldNotification"
    static let kAdvancedBookingDetails                      = "AdvancedBookingDetails"
    static let kAdvancedBookingCancelTripByPassenger        = "AdvancedBookingCancelTripByPassenger"
    static let kInformPassengerForAdvancedTrip              = "InformPassengerForAdvancedTrip"
    static let kAcceptAdvancedBookingRequestNotify          = "AcceptAdvancedBookingRequestNotify"
    
}

struct SocketDataKeys {
    
    static let kBookingIdNow    = "BookingId"
}



struct SubmitBookingRequest {
// PassengerId,ModelId,PickupLocation,DropoffLocation,PickupLat,PickupLng,DropOffLat,DropOffLon
// PassengerId,ModelId,PickupLocation,DropoffLocation,PickupLat,PickupLng,DropOffLat,DropOffLon,PromoCode,Notes,PaymentType,CardId(If paymentType is card)
    
    
    static let kModelId                 = "ModelId"
    static let kPickupLocation          = "PickupLocation"
    static let kDropoffLocation         = "DropoffLocation"
    static let kPickupLat               = "PickupLat"
    static let kPickupLng               = "PickupLng"
    static let kDropOffLat              = "DropOffLat"
    static let kDropOffLon              = "DropOffLon"
    
    static let kPromoCode               = "PromoCode"
    static let kNotes                   = "Notes"
    static let kPaymentType             = "PaymentType"
    static let kCardId                  = "CardId"
    static let kSpecial                 = "Special"
    static let kShareRide               = "ShareRide"
    static let kNoOfPassenger           = "NoOfPassenger"
    static let kReceiptType             = "ReceiptType"
    static let kEstimateFare            = "EstimatedFare"
    
}

struct NotificationCenterName {
    // Define identifier
    static let keyForOnGoing   = "keyForOnGoing"
    static let keyForUpComming = "keyForUpComming"
    static let keyForPastBooking = "keyForPastBooking"
  
}

struct PassengerDataKeys {
    static let kPassengerID = "PassengerId"
    
}

struct setAllDevices {
    
    static let allDevicesStatusBarHeight = 20
    static let allDevicesNavigationBarHeight = 44
    static let allDevicesNavigationBarTop = 20
}

struct setiPhoneX {
    
    static let iPhoneXStatusBarHeight = 44
    static let iPhoneXNavigationBarHeight = 40
    static let iPhoneXNavigationBarTop = 44
    
    
}

 //MARK: - Notification Identifire
 
let NotificationKeyforUpdateProfileDetail = NSNotification.Name("UpdateProfile")
let NotificationKeyFroAllDriver =  NSNotification.Name("NotificationKeyFroAllDriver")

let NotificationBookNow = NSNotification.Name("NotificationBookNow")
let NotificationBookLater = NSNotification.Name("NotificationBookLater")
let NotificationSocketOff = NSNotification.Name("NotificationSocketOff")
let NotificationTrackRunningTrip = NSNotification.Name("NotificationTrackRunningTrip")
let NotificationForBookingNewTrip = NSNotification.Name("NotificationForBookingNewTrip")
let NotificationForAddNewBooingOnSideMenu = NSNotification.Name("NotificationForAddNewBooingOnSideMenu")



//let NotificationHotelReservation = NSNotification.Name("NotificationHotelReservation")
//let NotificationBookaTable = NSNotification.Name("NotificationBookaTable")
//let NotificationShopping = NSNotification.Name("NotificationShopping")

//struct iPhoneDevices {
//    
//    static func getiPhoneXDevice() -> String {
//        
//        var deviceName = String()
//        
//        if UIDevice().userInterfaceIdiom == .phone {
//            switch UIScreen.main.nativeBounds.height {
//            case 1136:
//                print("iPhone 5 or 5S or 5C")
//                return deviceName = "iPhone 5"
//                
//            case 1334:
//                print("iPhone 6/6S/7/8")
//                deviceName = "iPhone 6"
//                
//            case 2208:
//                print("iPhone 6+/6S+/7+/8+")
//                deviceName = "iPhone 6+"
//                
//            case 2436:
//                print("iPhone X")
//                deviceName = "iPhone X"
//                
//            default:
//                print("unknown")
//            }
//        }
//    }
//}
/*
struct iPhoneDevices {
    
    let SCREEN_MAX_LENGTH = max(UIScreen.screenWidth, UIScreen.screenHeight)
    let SCREEN_MIN_LENGTH = min(UIScreen.screenWidth, UIScreen.screenHeight)
    
    let IS_IPHONE_4_OR_LESS = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH < 568.0
    let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH == 568.0
    let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH == 667.0
    let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH == 736.0
    let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad && SCREEN_MAX_LENGTH == 1024.0
    let IS_IPHONE_X = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH == 812.0

}
*/


