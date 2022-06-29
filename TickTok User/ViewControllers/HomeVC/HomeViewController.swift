//
//  HomeViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
//import SideMenu
import SocketIO
import SDWebImage
import NVActivityIndicatorView
import M13Checkbox
import ActionSheetPicker_3_0
import CoreLocation

//let BaseURL = "http://54.206.55.185:8080"

protocol FavouriteLocationDelegate {
    func didEnterFavouriteDestination(Source: [String: AnyObject])
}

protocol CompleterTripInfoDelegate {
    func didRatingCompleted()
}

protocol CompleteRatingDelegate {
    func DidCompletedRating()
}

protocol addCardFromHomeVCDelegate {
    func didAddCardFromHomeVC()
}


class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GMSAutocompleteViewControllerDelegate, FavouriteLocationDelegate, UIPickerViewDelegate, UIPickerViewDataSource, NVActivityIndicatorViewable, UIGestureRecognizerDelegate, FloatRatingViewDelegate, CompleterTripInfoDelegate, ARCarMovementDelegate, GMSMapViewDelegate, addCardFromHomeVCDelegate, UITableViewDataSource, UITableViewDelegate, SelectCardDelegate, BookLaterSubmitedDelegate,CompleteRatingDelegate,AddFavouriteLocationDelegate {
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
//    let baseUrlForGetAddress = "https://maps.googleapis.com/maps/api/geocode/json?"
//    let baseUrlForAutocompleteAddress = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"

    let apikey = googlPlacesApiKey //"AIzaSyCKEP5WGD7n5QWtCopu0QXOzM9Qec4vAfE"
    
    let socket = SocketIOClient(socketURL: URL(string: SocketData.kBaseURL)!, config: [.log(false), .compress])
    var isRequestedToConnectSocket:Bool = false
    //    let socket = (UIApplication.shared.delegate as! AppDelegate).SocketManager
    
    var moveMent: ARCarMovement!
    var driverMarker: GMSMarker!
    
    var timerToUpdatePassengerlocation:Timer!
    var timerToGetDriverLocation : Timer!
    var aryCards = [[String:AnyObject]]()
    var aryCompleterTripData:[[String:Any]] = []
    
    var locationManager = CLLocationManager()
//    var currentLocation: CLLocation?
    var mapView = GMSMapView()
    var placesClient = GMSPlacesClient()
    var zoomLevel: Float = 17.0
//    var likelyPlaces: [GMSPlace] = []
//    var selectedPlace: GMSPlace?
    var defaultLocation = CLLocation(latitude: 6.9422744, longitude: 79.9196117)
    var arrNumberOfAvailableCars = NSMutableArray()
    var arrTotalNumberOfCars = NSMutableArray()
    var arrNumberOfOnlineCars = NSMutableArray()
    //    var dictCars = NSMutableDictionary()
    var strCarModelClass = String()
    
    var aryRequestAcceptedData = NSArray()
    
    var strCarModelID = String()
    var strCarModelIDIfZero = String()
    var strNavigateCarModel = String()
    
    var aryEstimateFareData = NSArray()
    
    var strSelectedCarMarkerIcon = String()
    var ratingToDriver = Float()
    var commentToDriver = String()
    
    var currentLocationMarkerText = String()
    var destinationLocationMarkerText = String()
    
    var arrDemoCarList:[[String:Any]] = []
    
    var isAutoCompleteSelected:Bool = false
    
    var arrNumberOfPassengerList:[String] = []
    
    // this variable is used for stop Auto address change after selection from AutoComplete method
    
    //-------------------------------------------------------------
    // MARK: - Final Rating View
    //-------------------------------------------------------------
    
    //    var BookNowDate:Date!
    
    @IBOutlet weak var MarkerCurrntLocation: UIButton!
    @IBOutlet weak var viewMainFinalRating: UIView!
    @IBOutlet weak var viewSubFinalRating: UIView!
    @IBOutlet weak var txtFeedbackFinal: UITextField!
    
    @IBOutlet weak var giveRating: FloatRatingView!
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        
        giveRating.rating = rating
        ratingToDriver = giveRating.rating
        
    }
    
    @IBAction func btnSubmitFinalRating(_ sender: UIButton) {
        //        BookingId,Rating,Comment,BookingType(BookNow,BookLater)
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        var param = [String:AnyObject]()
        param["BookingId"] = SingletonClass.sharedInstance.bookingId as AnyObject
        param["Rating"] = ratingToDriver as AnyObject
        param["Comment"] = txtFeedbackFinal.text as AnyObject
        param["BookingType"] = strBookingType as AnyObject
        
        webserviceForRatingAndComment(param as AnyObject) { (result, status) in
            
            if (status) {
                //       print(result)
                
                self.txtFeedbackFinal.text = ""
                self.ratingToDriver = 0
                
                self.completeTripInfo(isPaid:true)
                
            }
            else {
                //      print(result)
                
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
    
    
    func didRatingCompleted() {
        openRatingView()
        //        self.completeTripInfo()
    }
    
    // ----------------------------------------------------------------------
    //MARK:- Driver Details
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverEmail: UILabel!
    @IBOutlet weak var lblDriverPhoneNumber: UILabel!
    @IBOutlet weak var imgDriverImage: UIImageView!
    @IBOutlet weak var viewDriverInformation: UIView!
    @IBOutlet weak var viewTripActions: UIView!
    
    @IBOutlet weak var btnCancelStartedTrip: UIButton!
    
    
    //MARK:-
    @IBOutlet weak var viewCarLists: UIView!
    @IBOutlet weak var viewShareRideView: UIView!
    @IBOutlet weak var imgIsShareRideON: UIImageView!
    
    /// if intShareRide = 1 than ON and if intShareRide = 0 OFF
    var intShareRide:Int = 0
    
    var isShareRideON = Bool()
    
    @IBAction func btnShareRide(_ sender: UIButton) {
        isShareRideON = !isShareRideON
        
        if (isShareRideON) {
            imgIsShareRideON.image = UIImage(named: "iconGreen")
            intShareRide = 1
            SingletonClass.sharedInstance.isShareRide = 1
        }
        else {
            imgIsShareRideON.image = UIImage(named: "iconRed")
            intShareRide = 0
            SingletonClass.sharedInstance.isShareRide = 0
        }
        
        postPickupAndDropLocationForEstimateFare()
        
    }
    
    @IBOutlet weak var constantLeadingOfShareRideButton: NSLayoutConstraint! // 10 or -150
    
    @IBOutlet weak var btnShareRideToggle: UIButton!
    
    @IBAction func btnShareRideToggle(_ sender: UIButton) {
        
        if sender.currentImage == UIImage(named: "iconRightArraw") {
            
            sender.setImage(UIImage(named: "iconArrowSmall"), for: .normal)
            constantLeadingOfShareRideButton.constant = 10
            
            UIView.animate(withDuration: 0.5) {
                self.viewShareRideView.layoutIfNeeded()
            }
        }
        else {
            
            sender.setImage(UIImage(named: "iconRightArraw"), for: .normal)
            constantLeadingOfShareRideButton.constant = -150
            
            UIView.animate(withDuration: 0.5) {
                self.viewShareRideView.layoutIfNeeded()
            }
        }
        
    }
    
    
    //PassengerId,ModelId,PickupLocation,DropoffLocation,PickupLat,PickupLng,DropOffLat,DropOffLon
    
    var strModelId = String()
    var ReceiptType = String()
    var strPickupLocation = String()
    var strDropoffLocation = String()
    var doublePickupLat = Double()
    var doublePickupLng = Double()
    var doubleUpdateNewLat = Double()
    var doubleUpdateNewLng = Double()
    var doubleDropOffLat = Double()
    var doubleDropOffLng = Double()
    var arrDataAfterCompletetionOfTrip:[[String:Any]] = []
    var selectedIndexPath: IndexPath?
    var strSpecialRequest = String()
    var strSpecialRequestFareCharge = String()
    
    var strPickUpLatitude = String()
    var strPickUpLongitude = String()
    
    
    @IBOutlet weak var ConstantViewCarListsHeight: NSLayoutConstraint! // 170
    
    
    @IBOutlet weak var PaymentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constraintTopSpaceViewDriverInfo: NSLayoutConstraint!
    
    @IBOutlet weak var viewForMainFavourite: UIView!
    @IBOutlet weak var viewForFavourite: UIView!
    
    var loadingView: NVActivityIndicatorView!
    //---------------
    
    var sumOfFinalDistance = Double()
    
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var arrivedRoutePath: GMSPath?

    
    //---------------
    @IBOutlet var HomeViewGrandParentView: UIView!
    
    @IBOutlet weak var viewDestinationLocation: UIView!
    @IBOutlet weak var viewCurrentLocation: UIView!
    @IBOutlet weak var viewParentFromToLocation: UIView!
    
    @IBOutlet weak var txtDestinationLocation: UITextField!
    @IBOutlet weak var txtCurrentLocation: UITextField!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var collectionViewCars: UICollectionView!
    
    @IBOutlet weak var lblPassengers: UILabel!
    
    var dropoffLat = Double()
    var dropoffLng = Double()
    var PasangerDefinedLimit:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.removeObserver(self, name: NotificationBookNow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.setLocationFromBarAndClub(_:)), name: NotificationBookNow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NotificationBookLater, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.setBookLaterDestinationAddress(_:)), name: NotificationBookLater, object: nil)
        NotificationCenter.default.removeObserver(self, name: NotificationTrackRunningTrip, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.webserviceOfRunningTripTrack), name: NotificationTrackRunningTrip, object: nil)
        NotificationCenter.default.removeObserver(self, name: NotificationForBookingNewTrip, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.newBooking(_:)), name: NotificationForBookingNewTrip, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NotificationSocketOff, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.OffSocket), name: NotificationSocketOff, object: nil)
        //        self.stackViewNumberOfPassenger.isHidden = true
        
        self.btnDoneForLocationSelected.isHidden = true
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        //        self.viewShareRideView.isHidden = true
        
        currentLocationMarkerText = "Current Location"
        destinationLocationMarkerText = "Destination Location"
        
        imgIsShareRideON.image = UIImage(named: "iconRed")
        
        currentLocationMarker.isDraggable = true
        destinationLocationMarker.isDraggable = true
        
        moveMent = ARCarMovement()
        moveMent.delegate = self
        
        mapView.delegate = self
        
        self.setupGoogleMap()
        
        sortCarListFirstTime()
        webserviceOfCurrentBooking()
        setPaymentType()
        
        viewMainFinalRating.isHidden = true
        //        btnDriverInfo.layer.cornerRadius = 5
        //        btnDriverInfo.layer.masksToBounds = true
        //        btnRequest.layer.cornerRadius = 5
        //        btnRequest.layer.masksToBounds = true
        //        btnCurrentLocation.layer.cornerRadius = 5
        //        btnCurrentLocation.layer.masksToBounds = true
        
        self.btnCancelStartedTrip.isHidden = true
        
        giveRating.delegate = self
        
        ratingToDriver = 0.0
        
        paymentType = "cash"
        
        self.viewBookNow.isHidden = true
        stackViewOfPromocode.isHidden = true
        
        viewMainActivityIndicator.isHidden = true
        
        viewActivity.type = .ballPulse
        viewActivity.color = themeYellowColor
        
        
        viewHavePromocode.tintColor = themeYellowColor
        viewHavePromocode.stateChangeAnimation = .fill
        viewHavePromocode.boxType = .square
        
        tripCheck.tintColor = themeYellowColor
        tripCheck.stateChangeAnimation = .fill
        tripCheck.boxType = .square
        
        taxCheck.tintColor = themeYellowColor
        taxCheck.stateChangeAnimation = .fill
        taxCheck.boxType = .square
        
        viewTripActions.isHidden = true
        
        webserviceOfCardList()
        
        viewForMainFavourite.isHidden = true
        
        SingletonClass.sharedInstance.isFirstTimeDidupdateLocation = true;
        self.view.bringSubview(toFront: btnFavourite)
        
        callToWebserviceOfCardListViewDidLoad()
        
        //
        //        // Do any additional setup after loading the view.
        //         
        //
        //        viewCurrentLocation.layer.shadowOpacity = 0.3
        //        viewCurrentLocation.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        //
        //        viewDestinationLocation.layer.shadowOpacity = 0.3
        //        viewDestinationLocation.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        //
        //        self.setupSideMenu()
        //                webserviceCallForGettingCarLists()
        //
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "HomeVC")

        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    @IBOutlet weak var viewHeaderHeightConstant: NSLayoutConstraint!
    
    func setHeaderForIphoneX() {
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                
                viewHeaderHeightConstant.constant = 80
                
                //                frame = CGRect(x: CGFloat(0), y: CGFloat(-20), width: screenWidth, height: CGFloat(heightWithoutLabelForX))
                //                hView.contraintLabelCentr.constant = 10
                //
                //                if (showTitleLabelView)
                //                {
                //                    frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: screenWidth, height: CGFloat(heightWithLabelForX))
                //                    hView.lblHeaderTitle.text = strHeaderTitle
            //                }
            default:
                break
                //                print("unknown")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.btnDoneForLocationSelected.isHidden = true
        //        setupGoogleMap()
        
        //        viewTripActions.isHidden = true
        
        // This is For Book Later Address
        if (SingletonClass.sharedInstance.isFromNotificationBookLater) {
            
            if strCarModelID == "" {
                UtilityClass.showAlert("", message: "Please select service type eg Standard, Premium, Van!", vc: self)
                //                UtilityClass.setCustomAlert(title: "", message: "Select Car") { (index, title) in
                //                }
            }
            else if strDestinationLocationForBookLater != "" {
                let profileData = SingletonClass.sharedInstance.dictProfile
                
                let next = self.storyboard?.instantiateViewController(withIdentifier: "BookLaterViewController") as! BookLaterViewController
                
                SingletonClass.sharedInstance.isFromNotificationBookLater = false
                
                next.strModelId = strCarModelID
                next.strCarModelURL = strNavigateCarModel
                next.strCarName = strCarModelClass
                next.BookLaterCompleted = self
                next.strFullname = profileData.object(forKey: "Fullname") as! String
                next.strMobileNumber = profileData.object(forKey: "MobileNo") as! String
                
                if strCarModelClass == "Premium" {
                    next.PasangerDefinedLimit = 4
                } else {
                    next.PasangerDefinedLimit = 6
                }
                let visibleRegion = mapView.projection.visibleRegion()
                let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
                next.NearByRegion = bounds
                
                next.strDropoffLocation = strDestinationLocationForBookLater
                next.doubleDropOffLat = dropOffLatForBookLater
                next.doubleDropOffLng = dropOffLngForBookLater
                
                self.navigationController?.pushViewController(next, animated: true)
            }
            else {
                
                UtilityClass.setCustomAlert(title: "", message: "We did not get proper address") { (index, title) in
                }
            }
            
        }
        
        viewSubFinalRating.layer.cornerRadius = 5
        viewSubFinalRating.layer.masksToBounds = true
        
        //        viewSelectPaymentOption.layer.borderWidth = 1.0
        //        viewSelectPaymentOption.layer.borderColor = UIColor.gray.cgColor
        //        viewSelectPaymentOption.layer.cornerRadius = 5
        //        viewSelectPaymentOption.layer.masksToBounds = true
        //
        viewSelectPaymentOptionParent.layer.cornerRadius = 5
        viewSelectPaymentOptionParent.layer.masksToBounds = true
        
        
//        if(locationManager != nil)
//        {
            locationManager.startUpdatingLocation()
//        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //
        //
        
        //        if (self.mapView != nil)
        //        {
        //
        //        self.mapView.clear()
        ////        self.mapView.stopRendering()
        ////        self.mapView.removeFromSuperview()
        ////        self.mapView = nil
        //        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setHeaderForIphoneX()
        
        self.arrTotalNumberOfCars = NSMutableArray(array: SingletonClass.sharedInstance.arrCarLists)
        self.arrDemoCarList = SingletonClass.sharedInstance.arrCarLists as! [[String:Any]]
        
        //        self.setupGoogleMap()
        
    }
    
    
    //-------------------------------------------------------------
    // MARK: - BookLater Completed Delegate Methods
    //-------------------------------------------------------------
    
    func BookLaterComplete() {
        self.clearSetupMapForNewBooking()
    }
    
    //-------------------------------------------------------------
    // MARK: - Notification Center Methods
    //-------------------------------------------------------------
    
    
    @objc func setLocationFromBarAndClub(_ notification: NSNotification) {
        
        print("Notification Data : \(notification)")
        
        if let Address = notification.userInfo?["Address"] as? String {
            // do something with your image
            txtDestinationLocation.text = Address
            strDropoffLocation = Address
            
            if let lat = notification.userInfo?["lat"] as? Double {
                
                if lat != 0 {
                    doubleDropOffLat = Double(lat)
                }
            }
            
            if let lng = notification.userInfo?["lng"] as? Double {
                
                if lng != 0 {
                    doubleDropOffLng = Double(lng)
                }
            }
        }
        
    }
    
    var strDestinationLocationForBookLater = String()
    var dropOffLatForBookLater = Double()
    var dropOffLngForBookLater = Double()
    
    @objc func setBookLaterDestinationAddress(_ notification: NSNotification) {
        
        print("Notification Data : \(notification)")
        
        if let Address = notification.userInfo?["Address"] as? String {
            // do something with your image
            strDestinationLocationForBookLater = Address
            
            if let lat = notification.userInfo?["lat"] as? Double {
                
                if lat != 0 {
                    dropOffLatForBookLater = Double(lat)
                }
            }
            
            if let lng = notification.userInfo?["lng"] as? Double {
                
                if lng != 0 {
                    dropOffLngForBookLater = Double(lng)
                }
            }
            
        }
    }
    
    
    //-------------------------------------------------------------
    // MARK: - setMap and Location Methods
    //-------------------------------------------------------------
    
    
    @IBOutlet weak var btnDoneForLocationSelected: UIButton!
    @IBAction func btnDoneForLocationSelected(_ sender: UIButton) {
        
        clearMap()
        self.routePolyline.map = nil
        self.updateCounting()
        if strLocationType == currentLocationMarkerText {
            
            btnDoneForLocationSelected.isHidden = true
            if txtDestinationLocation.text?.count != 0 {
                txtDestinationLocation.becomeFirstResponder()
            }
        }
        else if strLocationType == destinationLocationMarkerText {
            
            btnDoneForLocationSelected.isHidden = true
        }
        
        if txtCurrentLocation.text != "" && txtDestinationLocation.text != "" {
            
            //commented for Query Limit Issue -
            setupBothCurrentAndDestinationMarkerAndPolylineOnMap()
            //            self.callforMapLine(functionname: #function)
            selectedIndexPath = nil
            self.lblMinutes.text = "Approximate arrival time \(0) minutes"
            self.lblPrices.text = "\(currencySign) \(0.00)"
            self.collectionViewCars.reloadData()
            btnDoneForLocationSelected.isHidden = true
            
            
            self.viewCarLists.isHidden = false
            
            //            self.viewShareRideView.isHidden = false
            self.ConstantViewCarListsHeight.constant = 230
        }
        else {
            self.ConstantViewCarListsHeight.constant = 0
            self.viewCarLists.isHidden = true
            //            self.viewShareRideView.isHidden = true
        }
        
    }
    
    
    //    @IBOutlet weak var btnCurrentLocation: UIButton!
    
    var currentLocationMarker = GMSMarker()
    var destinationLocationMarker = GMSMarker()
    
    var routePolyline = GMSPolyline()
    var demoPolylineOLD = GMSPolyline()
    
    var setDummyLineIndex = 0
    var dummyTimer = Timer()
    
    
    @IBAction func btnCurrentLocation(_ sender: UIButton) {
        
        currentLocationAction()
    }

    func currentLocationAction() {
        
        clearMap()
        
        txtDestinationLocation.text = ""
        strDropoffLocation = ""
        doubleDropOffLat = 0
        doubleDropOffLng = 0
        self.destinationLocationMarker.map = nil
        self.currentLocationMarker.map = nil
        self.strLocationType = self.currentLocationMarkerText
        self.btnDoneForLocationSelected.isHidden = false
        if self.selectedIndexPath != nil {
            self.selectedIndexPath = nil
        }
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        //        self.viewShareRideView.isHidden = true
        
        mapView.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: 17.5)
        
        mapView.camera = camera
        
        self.MarkerCurrntLocation.isHidden = false
        self.btnDoneForLocationSelected.isHidden = false
        if self.selectedIndexPath != nil {
            self.selectedIndexPath = nil
        }
        
        self.doublePickupLat = (defaultLocation.coordinate.latitude)
        self.doublePickupLng = (defaultLocation.coordinate.longitude)
        
        //        let strLati: String = "\(self.doublePickupLat)"
        //        let strlongi: String = "\(self.doublePickupLng)"
        //
        //        getAddressForLatLng(latitude: strLati, longitude: strlongi, markerType: currentLocationMarkerText)
        
        //        let position = CLLocationCoordinate2D(latitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude)
        //        currentLocationMarker = GMSMarker(position: position)
        //        currentLocationMarker.map = self.mapView
        //        currentLocationMarker.snippet = currentLocationMarkerText // "Current Location"
        //        currentLocationMarker.icon = UIImage(named: "iconCurrentLocation")
        //        currentLocationMarker.isDraggable = true
    }
    
//    let geocoder = GMSGeocoder()
     lazy var geocoder = CLGeocoder()
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.btnDoneForLocationSelected.isHidden = true
    }
    
    var strLocationType = String()
    
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        
        print(#function + "\(Date())")
        if Connectivity.isConnectedToInternet() {
            
            if self.isAutoCompleteSelected == false {
                
                if MarkerCurrntLocation.isHidden == false {
                    
                    //                geocoder.reverseGeocodeCoordinate(cameraPosition.target) { (response, error) in
                    //                    guard error == nil else {
                    //                        return
                    //                    }
                    //                }
                    
                    if self.strLocationType != "" {
                        
                        //                     UtilityClass.showACProgressHUD()
                        
                        if self.bookingIDNow == "" && self.advanceBookingID == "" {
                            self.btnDoneForLocationSelected.isHidden = false
                        }
                       
                        if self.selectedIndexPath != nil {
                            self.selectedIndexPath = nil
                        }
                        
                        if self.strLocationType == self.currentLocationMarkerText {
                            
                            self.doublePickupLat = cameraPosition.target.latitude
                            self.doublePickupLng = cameraPosition.target.longitude
                            
                            getAddressForLatLng(latitude: "\(cameraPosition.target.latitude)", Longintude: "\(cameraPosition.target.longitude)", markerType: strLocationType)
                            
                            
                        }
                        else if self.strLocationType == self.destinationLocationMarkerText {
                            
                            self.doubleDropOffLat = cameraPosition.target.latitude
                            self.doubleDropOffLng = cameraPosition.target.longitude
                            
                            getAddressForLatLng(latitude: "\(cameraPosition.target.latitude)", Longintude: "\(cameraPosition.target.longitude)", markerType: strLocationType)
                            
                            
                        }
                        
                        if txtCurrentLocation.text?.count != 0 && txtDestinationLocation.text?.count != 0 && self.btnDoneForLocationSelected.isHidden != false {
                            self.strLocationType = ""
                            
                            //                        UtilityClass.hideHUD()
                        }
                    }
                    
                    
                    //                getAddressForLatLng(latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)", markerType: strLocationType) // currentLocationMarkerText
                }
            } else {
                self.isAutoCompleteSelected = false
                self.btnDoneForLocationSelected.isHidden = false
                if self.selectedIndexPath != nil {
                    self.selectedIndexPath = nil
                }
            }
        }
        else {
            UtilityClass.showAlert("", message: "Internet connection not available", vc: self)
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        
        print("didBeginDragging")
        
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("didDrag")
        
        //        currentLocationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
        //        currentLocationMarker.map = self.mapView
        //        currentLocationMarker.snippet = currentLocationMarkerText // "Current Location"
        //        currentLocationMarker.icon = UIImage(named: "iconCurrentLocation")
        
    }
    
    func mapView(_ mapView: GMSMapView, did position: GMSCameraPosition) {
        
        print("did position: \(position)")
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        //        print("didChange position: \(position)")
        
        
        //        print("\(position.target.latitude) \(position.target.longitude)")
        
        //        currentLocationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude))
        //        currentLocationMarker.map = self.mapView
        //        currentLocationMarker.snippet = currentLocationMarkerText // "Current Location"
        //        currentLocationMarker.icon = UIImage(named: "iconCurrentLocation")
        //
        //        let latitude = mapView.camera.target.latitude
        //        let longitude = mapView.camera.target.longitude
        
        //        let locat = CLLocation(latitude: latitude, longitude: longitude)
        /*
         if self.strLocationType != "" {
         
         if self.strLocationType == self.currentLocationMarkerText {
         
         self.doublePickupLat = position.target.latitude
         self.doublePickupLng = position.target.longitude
         
         getAddressForLatLng(latitude: "\(position.target.latitude)", longitude: "\(position.target.longitude)", markerType: strLocationType)
         }
         else if self.strLocationType == self.destinationLocationMarkerText {
         
         self.doubleDropOffLat = position.target.latitude
         self.doubleDropOffLng = position.target.longitude
         
         getAddressForLatLng(latitude: "\(position.target.latitude)", longitude: "\(position.target.longitude)", markerType: strLocationType)
         }
         
         if txtCurrentLocation.text?.count != 0 && txtDestinationLocation.text?.count != 0 && btnDoneForLocationSelected.isHidden != false {
         self.strLocationType = ""
         }
         }
         */
        
        /*
         
         let ceo = CLGeocoder()
         let loc = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
         print("Locations : \(loc)")
         //----------------------------------------------------------------------
         
         // ----------------------------------------------------------------------
         ceo.reverseGeocodeLocation(loc) { (placemarks, error) in
         
         if placemarks != nil {
         let placemark = placemarks![0] as? CLPlacemark
         
         let address = (placemark?.addressDictionary?["FormattedAddressLines"] as! [String]).joined(separator: ", ")
         
         if self.strLocationType == self.currentLocationMarkerText {
         
         print("Address: \(address)")
         self.txtCurrentLocation.text = address
         self.strPickupLocation = address
         self.doublePickupLat = (placemark?.location?.coordinate.latitude)!
         self.doublePickupLng = (placemark?.location?.coordinate.longitude)!
         }
         else if self.strLocationType == self.destinationLocationMarkerText {
         
         print("Address: \(address)")
         self.txtDestinationLocation.text = address
         self.strDropoffLocation = address
         self.doubleDropOffLat = (placemark?.location?.coordinate.latitude)!
         self.doubleDropOffLng = (placemark?.location?.coordinate.longitude)!
         }
         
         print("didEndDragging")
         }
         }
         */
    }
    
    func getAddressForLatLng(latitude:String, Longintude:String, markerType: String) {
//        self.StartingPointLatitude = Double(latitude)!
//        self.StartingPointLongitude = Double(Longintude)!
        
        let location = CLLocation(latitude: Double(latitude)!, longitude: Double(Longintude)!)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error,markerType: markerType)
        }
        
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?, markerType: String) {
        // Update View
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            //            lblStartPoint.text = "Unable to Find Address for Location"
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                var addressString:String = ""
                if let Address = placemark.addressDictionary as? [String:Any] {
                    addressString =  (Address["FormattedAddressLines"] as! [String]).joined(separator: ", ")
                }
                else {
                    if let SubLocality = placemark.subLocality, let City = placemark.locality, let State = placemark.administrativeArea, let Postalcode = placemark.postalCode , let country = placemark.country {
                        addressString = "\(SubLocality), \(City), \(State) \(Postalcode), \(country)"
                    }
                }
                
                if self.bookingIDNow == "" && self.advanceBookingID == "" {
                    if markerType == currentLocationMarkerText {
                        self.txtCurrentLocation.text = addressString
                        self.strPickupLocation = addressString
                        btnDoneForLocationSelected.isHidden = false
                        if self.selectedIndexPath != nil {
                            self.selectedIndexPath = nil
                        }
                    } else if markerType == destinationLocationMarkerText {
                        self.txtDestinationLocation.text = addressString
                        self.strDropoffLocation = addressString
                        btnDoneForLocationSelected.isHidden = false
                        if self.selectedIndexPath != nil {
                            self.selectedIndexPath = nil
                        }
                    }
                }
            } else {
                //                lblStartPoint.text = "No Address Found"
            }
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("didEndDragging")
        /*
         if (marker.snippet == currentLocationMarkerText) {
         let ceo = CLGeocoder()
         var loc = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
         ceo.reverseGeocodeLocation(loc) { (placemarks, error) in
         
         if placemarks != nil {
         
         let placemark = placemarks![0] as? CLPlacemark
         
         //            print(placemark?.addressDictionary ?? "")
         
         //            print("placemark \(String(describing: placemark))")
         //            //String to hold address
         //            var locatedAt: String? = (placemark?.addressDictionary?["FormattedAddressLines"] as AnyObject).joined(separator: ", ")
         //            print("addressDictionary \(String(describing: placemark?.addressDictionary) ?? "")")
         
         let address = (placemark?.addressDictionary?["FormattedAddressLines"] as! [String]).joined(separator: ", ")
         
         self.strPickupLocation = address
         self.doublePickupLat = (placemark?.location?.coordinate.latitude)!
         self.doublePickupLng = (placemark?.location?.coordinate.longitude)!
         
         let strLati: String = "\(self.doublePickupLat)"
         let strlongi: String = "\(self.doublePickupLng)"
         
         if (marker.snippet != nil) {
         self.getAddressForLatLng(latitude: strLati, longitude: strlongi, markerType: marker.snippet!)
         }
         
         }
         
         print("didEndDragging")
         }
         }
         else if (marker.snippet == destinationLocationMarkerText) {
         let ceo = CLGeocoder()
         var loc = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
         ceo.reverseGeocodeLocation(loc) { (placemarks, error) in
         
         if placemarks != nil {
         
         let placemark = placemarks![0] as? CLPlacemark
         
         //            print(placemark?.addressDictionary ?? "")
         
         //            print("placemark \(String(describing: placemark))")
         //            //String to hold address
         //            var locatedAt: String? = (placemark?.addressDictionary?["FormattedAddressLines"] as AnyObject).joined(separator: ", ")
         //            print("addressDictionary \(String(describing: placemark?.addressDictionary) ?? "")")
         
         let address = (placemark?.addressDictionary?["FormattedAddressLines"] as! [String]).joined(separator: ", ")
         
         self.strDropoffLocation = address
         self.doubleDropOffLat = (placemark?.location?.coordinate.latitude)!
         self.doubleDropOffLng = (placemark?.location?.coordinate.longitude)!
         
         let strLati: String = "\(self.doubleDropOffLat)"
         let strlongi: String = "\(self.doubleDropOffLng)"
         
         if marker.snippet != nil {
         self.getAddressForLatLng(latitude: strLati, longitude: strlongi, markerType: marker.snippet!)
         }
         
         }
         
         print("didEndDragging")
         }
         }
         
         */
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        //        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    
    //MARK:- Get location from Google geoCoding Api method
    /*
    func getAddressForLatLng(latitude: String, longitude: String, markerType: String) {
        
        if markerType == currentLocationMarkerText {
            let url = NSURL(string: "\(baseUrlForGetAddress)latlng=\(latitude),\(longitude)&key=\(apikey)")
            //            let autoCompleteHTTPs = NSURL(string: "\(baseUrlForAutocompleteAddress)input=35&location=\(latitude),\(longitude)&radius=1000&sensor=true&key=\(apikey)&components=&language=en")
            //            print("autoCompleteHTTPs Link is : \(autoCompleteHTTPs)")
            
            print("Link is : \(url)")
            
            //            do {
            //                let data = NSData(contentsOf: autoCompleteHTTPs as! URL)
            //                if data != nil {
            //                    if let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
            //                        if let result = json["predictions"] as? [[String:AnyObject]] {
            //                            if result != nil {
            //                                if result.count > 0 {
            //                                    if result.first != nil && result.first?.count != 0 {
            //                                        self.txtCurrentLocation.text = result.first?["description"] as? String
            //                                        self.strPickupLocation = result.first!["description"] as! String
            //                                        self.btnDoneForLocationSelected.isHidden = false
            //                                    }
            //                                }
            //                            }
            //                        }
            //                    }
            //                }
            //            }
            
            
            do {
                let data = NSData(contentsOf: url! as URL)
                let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                if let result = json["results"] as? [[String:AnyObject]] {
                    if result.count > 0 {
                        if let resString = result[0]["formatted_address"] as? String {
                            self.txtCurrentLocation.text = resString
                            self.strPickupLocation = resString
                            btnDoneForLocationSelected.isHidden = false
                            if self.selectedIndexPath != nil {
                                self.selectedIndexPath = nil
                            }
                        }
                        else if let address = result[0]["address_components"] as? [[String:AnyObject]] {
                            if address.count > 1 {
                                var streetNumber = String()
                                var streetStreet = String()
                                var streetCity = String()
                                var streetState = String()
                                for i in 0..<address.count {
                                    if i == 0 {
                                        if let number = address[i]["long_name"] as? String {
                                            streetNumber = number
                                        }
                                    }
                                    else if i == 1 {
                                        if let street = address[i]["long_name"] as? String {
                                            streetStreet = street
                                        }
                                    }
                                    else if i == 2 {
                                        if let city = address[i]["long_name"] as? String {
                                            streetCity = city
                                        }
                                    }
                                    else if i == 3 {
                                        if let state = address[i]["long_name"] as? String {
                                            streetState = state
                                        }
                                    }
                                    else if i == 4 {
                                        if let city = address[i]["long_name"] as? String {
                                            streetCity = city
                                        }
                                    }
                                }
                                print("\n\(streetNumber) \(streetStreet), \(streetCity), \(streetState)")
                                self.txtCurrentLocation.text = "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
                                self.strPickupLocation = "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
                                btnDoneForLocationSelected.isHidden = false
                                if self.selectedIndexPath != nil {
                                    self.selectedIndexPath = nil
                                }
                            }
                        }
                    }
                }
            }
            catch {
                print("Not Geting Address")
            }
        }
        else if markerType == destinationLocationMarkerText {
            let url = NSURL(string: "\(baseUrlForGetAddress)latlng=\(latitude),\(longitude)&key=\(apikey)")
            
            print("Link is : \(url)")
            do {
                let data = NSData(contentsOf: url! as URL)
                let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                if let result = json["results"] as? [[String:AnyObject]] {
                    if result.count > 0 {
                        if let resString = result[0]["formatted_address"] as? String {
                            
                            self.txtDestinationLocation.text = resString
                            self.strDropoffLocation = resString
                            btnDoneForLocationSelected.isHidden = false
                            if self.selectedIndexPath != nil {
                                self.selectedIndexPath = nil
                            }
                            
                        }
                        else if let address = result[0]["address_components"] as? [[String:AnyObject]] {
                            
                            if address.count > 1 {
                                
                                var streetNumber = String()
                                var streetStreet = String()
                                var streetCity = String()
                                var streetState = String()
                                
                                
                                for i in 0..<address.count {
                                    
                                    if i == 0 {
                                        if let number = address[i]["long_name"] as? String {
                                            streetNumber = number
                                        }
                                    }
                                    else if i == 1 {
                                        if let street = address[i]["long_name"] as? String {
                                            streetStreet = street
                                        }
                                    }
                                    else if i == 2 {
                                        if let city = address[i]["long_name"] as? String {
                                            streetCity = city
                                        }
                                    }
                                    else if i == 3 {
                                        if let state = address[i]["long_name"] as? String {
                                            streetState = state
                                        }
                                    }
                                    else if i == 4 {
                                        if let city = address[i]["long_name"] as? String {
                                            streetCity = city
                                        }
                                    }
                                }
                                
                                print("\n\(streetNumber) \(streetStreet), \(streetCity), \(streetState)")
                                
                                self.txtDestinationLocation.text = "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
                                self.strDropoffLocation = "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
                                btnDoneForLocationSelected.isHidden = false
                                if self.selectedIndexPath != nil {
                                    self.selectedIndexPath = nil
                                }
                                //                                UtilityClass.hideHUD()
                            }
                        }
                    }
                }
            }
            catch {
                print("Not Geting Address")
            }
        }
        //   btnDoneForLocationSelected.isHidden = false
        
    }
 */
 
    @IBOutlet weak var btnFavourite: UIButton!
    
    @IBOutlet weak var tblFavourite: UITableView!
    
    let arrFavourites = ["Home","Office", "Airport","Others"]
    let arrFavImages = ["iconHome", "iconOffice", "iconAirport", "iconOthers"]
    
    @IBAction func btnFavourite(_ sender: UIButton) {
        
        if txtDestinationLocation.text!.count == 0 {
            
            UtilityClass.setCustomAlert(title: "", message: "Enter Destination Address") { (index, title) in
            }
        }
        else {
            UIView.transition(with: viewForMainFavourite, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
                self.viewForMainFavourite.isHidden = false
                self.tblFavourite.dataSource = self
                self.tblFavourite.delegate = self
                self.tblFavourite.reloadData()
            }) { _ in }
            
        }
        
    }
    
    @IBAction func btnOkAction(_ sender: Any) {
        UIView.transition(with: self.viewForMainFavourite, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
            self.viewForMainFavourite.isHidden = true
        }) { _ in }
        
    }
    
    
    //MARK:- Favourite TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFavourites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let FavCell = self.tblFavourite.dequeueReusableCell(withIdentifier: "FavrouiteTableViewCell") as! FavrouiteTableViewCell
        
        FavCell.imgLogo.image = UIImage(named: self.arrFavImages[indexPath.row])
        FavCell.lblFavName.text = self.arrFavourites[indexPath.row]
        FavCell.Delegate = self
        
//        FavCell.selectionStyle = .none
        return FavCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func AddFavouriteLocation(CustomCell: UITableViewCell) {
        let indexPath = self.tblFavourite.indexPath(for: CustomCell)!
        self.webserviceOfAddAddressToFavourite(type: self.arrFavourites[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    @IBOutlet weak var btnSwapAddress: UIButton!
    @IBAction func btnSwapAddress(_ sender: UIButton) {
        
        let pickupLet = self.doublePickupLat
        let pickuplong = self.doublePickupLng
        
        let dropoffLet = self.doubleDropOffLat
        let dropoffLong = self.doubleDropOffLng
        
        let FromAddress:String = self.txtCurrentLocation.text!
        let ToAddress:String = self.txtDestinationLocation.text!
        
        self.doublePickupLat = dropoffLet
        self.doublePickupLng = dropoffLong
        
        self.doubleDropOffLat = pickupLet
        self.doubleDropOffLng = pickuplong
        
        self.txtDestinationLocation.text = FromAddress
        self.txtCurrentLocation.text = ToAddress
        
        MarkerCurrntLocation.isHidden = false
        
        self.destinationLocationMarker.map = nil
        self.currentLocationMarker.map = nil
        
        self.routePolyline.map = nil
        self.btnDoneForLocationSelected.isHidden = false
        
        if self.selectedIndexPath != nil {
            self.selectedIndexPath = nil
        }
        
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        
        self.clearMap()
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
    
    
    func setPaymentType() {
        
        //        pickerView.selectRow(0, inComponent: 0, animated: true)
        
        //        imgPaymentType.image = UIImage(named: "iconCashBlack")
        //        txtSelectPaymentOption.text = "cash"
        
    }
    
    func setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: Bool) {
        self.viewParentFromToLocation.isHidden = status
        //        viewCurrentLocation.isHidden = status
        //        viewDestinationLocation.isHidden = status
        //        btnCurrentLocation.isHidden = status
    }
    
    
    //Mark - Webservice Call For Miss Booking Request
    func webserviceCallForMissBookingRequest()
    {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        var dictParam = [String:AnyObject]()
        dictParam["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        dictParam["ModelId"] = strCarModelIDIfZero as AnyObject
        dictParam["PickupLocation"] = self.strPickupLocation as AnyObject
        dictParam["DropoffLocation"] = self.strDropoffLocation as AnyObject
        dictParam["PickupLat"] = doublePickupLat as AnyObject
        dictParam["PickupLng"] = doublePickupLng as AnyObject
        dictParam["DropOffLat"] = doubleDropOffLat as AnyObject
        dictParam["DropOffLon"] = doubleDropOffLng as AnyObject
        dictParam["Notes"] = "" as AnyObject
        
        webserviceForMissBookingRequest(dictParam as AnyObject) { (result, status) in
            
        }
    }
    
    
    //MARK:- Webservice Call for Booking Requests
    func webserviceCallForBookingCar()
    {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        //PassengerId,ModelId,PickupLocation,DropoffLocation,PickupLat,PickupLng,DropOffLat,DropOffLon
        //,PromoCode,Notes,PaymentType,CardId(If paymentType is card)
        
        let dictParams = NSMutableDictionary()
        dictParams.setObject(SingletonClass.sharedInstance.strPassengerID, forKey: "PassengerId" as NSCopying)
        dictParams.setObject(strModelId, forKey: SubmitBookingRequest.kModelId as NSCopying)
        if(strModelId == "")
        {
            dictParams.setObject(strCarModelIDIfZero, forKey: SubmitBookingRequest.kModelId as NSCopying)
            
        }
        dictParams.setObject(strPickupLocation, forKey: SubmitBookingRequest.kPickupLocation as NSCopying)
        dictParams.setObject(strDropoffLocation, forKey: SubmitBookingRequest.kDropoffLocation as NSCopying)
        
        dictParams.setObject(doublePickupLat, forKey: SubmitBookingRequest.kPickupLat as NSCopying)
        dictParams.setObject(doublePickupLng, forKey: SubmitBookingRequest.kPickupLng as NSCopying)
        
        dictParams.setObject(doubleDropOffLat, forKey: SubmitBookingRequest.kDropOffLat as NSCopying)
        dictParams.setObject(doubleDropOffLng, forKey: SubmitBookingRequest.kDropOffLon as NSCopying)
        
        
        dictParams.setObject(strSpecialRequest, forKey: SubmitBookingRequest.kSpecial as NSCopying)
        dictParams.setObject(self.btnNumberOfPassenger.currentTitle ?? "", forKey: SubmitBookingRequest.kNoOfPassenger as NSCopying)
        
        if paymentType != "" {
            dictParams.setObject(paymentType, forKey: SubmitBookingRequest.kPaymentType as NSCopying)
        }
        
        if ReceiptType != "" {
            dictParams.setObject(ReceiptType, forKey: SubmitBookingRequest.kReceiptType as NSCopying)
        }
        
        if self.btnSelectPromocode.currentTitle != "Select Promocode" {
            if let Promodetail:String = self.btnSelectPromocode.currentTitle {
                let promocode = Promodetail.components(separatedBy: " ")[0]
                dictParams.setObject(promocode, forKey: SubmitBookingRequest.kPromoCode as NSCopying)
            }
        }
        
        if self.txtNote.text != "Additional Information" && self.txtNote.textColor != UIColor.lightGray {
            dictParams.setObject(txtNote.text!, forKey: SubmitBookingRequest.kNotes as NSCopying)
        }
        
        //        if txtHavePromocode.text != "" {
        //            dictParams.setObject(txtHavePromocode.text!, forKey: SubmitBookingRequest.kPromoCode as NSCopying)
        //        }
        
        if CardID != "" {
            dictParams.setObject(CardID, forKey: SubmitBookingRequest.kCardId as NSCopying)
        }
        
        if intShareRide == 1 {
            dictParams.setObject(intShareRide, forKey: SubmitBookingRequest.kShareRide as NSCopying)
            dictParams.setObject(self.btnNumberOfPassenger.currentTitle ?? "", forKey: SubmitBookingRequest.kNoOfPassenger as NSCopying)
            
        }
        
        self.view.bringSubview(toFront: self.viewMainActivityIndicator)
        self.viewMainActivityIndicator.isHidden = false
        webserviceForTaxiRequest(dictParams) { (result, status) in
            
            if (status) {
                //      print(result)
                
                SingletonClass.sharedInstance.bookedDetails = (result as! NSDictionary)
                
                if let bookingId = ((result as! NSDictionary).object(forKey: "details") as! NSDictionary).object(forKey: "BookingId") as? Int {
                    SingletonClass.sharedInstance.bookingId = "\(bookingId)"
                }
                
                self.strBookingType = "BookNow"
                self.viewBookNow.isHidden = true
                self.viewActivity.startAnimating()
                //                    self.BookNowDate = Date()
                
            }
            else {
                //    print(result)
                
                self.viewBookNow.isHidden = true
                self.viewMainActivityIndicator.isHidden = true
                
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: alertTitle, message: res) { (index, title) in
                    }
                }
                else if let resDict = result as? NSDictionary {
                    if((resDict.object(forKey: "message") as? NSArray) != nil)
                    {
                        UtilityClass.setCustomAlert(title: alertTitle, message: (resDict.object(forKey: "message") as! NSArray).object(at: 0) as! String) { (index, title) in
                        }
                    }
                    else
                    {
                        UtilityClass.setCustomAlert(title: alertTitle, message: resDict.object(forKey: "message") as! String) { (index, title) in
                        }
                    }
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: alertTitle, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                }
            }
        }
    }
    
    
    func startProcessToSendRequest() {
        
        if paymentType == "cash" {
            UtilityClass.setCustomAlert(title: "Booking Confirmed", message: "CASH PAYMENT POLICY\nPlease Show Driver On Arrival That You Have Cash To Pay\nThanks") { (Index:Int,Status:String) in
                
                self.webserviceCallForBookingCar()
                
            }
        } else {
            self.webserviceCallForBookingCar()
        }
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - View Book Now
    //-------------------------------------------------------------
    
    @IBAction func tapToDismissActivityIndicator(_ sender: UITapGestureRecognizer) {
        viewMainActivityIndicator.isHidden = true
        
        //        socketMethodForCancelRequestTrip()
        
    }
    @IBOutlet weak var viewMainActivityIndicator: UIView!
    @IBOutlet weak var viewActivity: NVActivityIndicatorView!
    
    @IBOutlet weak var viewBookNow: UIView!
    
    @IBOutlet weak var viewSelectPaymentOptionParent: UIView!
    
    //    @IBOutlet weak var viewSelectPaymentOption: UIView!
    
    //    @IBOutlet weak var txtSelectPaymentOption: UITextField!
    
    @IBOutlet weak var viewHavePromocode: M13Checkbox!
    
    @IBOutlet weak var stackViewOfPromocode: UIView!
    
    //    @IBOutlet weak var stackViewNumberOfPassenger: UIStackView!
    
    @IBOutlet weak var lblNumberOfPassengers: UILabel!
    
    
    //    @IBOutlet weak var imgPaymentType: UIImageView!
    @IBOutlet weak var txtHavePromocode: UITextField!
    
    
    //    @IBOutlet weak var txtNote: UITextField!
    @IBOutlet weak var txtNote: UITextView!
    
    
    var boolIsSelected = Bool()
    
    @IBOutlet weak var PayCashView: UIView!
    @IBOutlet weak var CashLogo: UIImageView!
    @IBOutlet weak var btnCash: UIButton!
    
    @IBOutlet weak var PayWalletView: UIView!
    @IBOutlet weak var WalletLogo: UIImageView!
    @IBOutlet weak var btnWallet: UIButton!
    
    @IBOutlet weak var PayCardView: UIView!
    @IBOutlet weak var CardLogo: UIImageView!
    @IBOutlet weak var btnCard: UIButton!
    
    @IBOutlet weak var lblCardTitle: UILabel!
    
    @IBAction func btnPayment(_ sender: UIButton) {
        
        switch sender {
        case self.btnCard:
            let WalletStoryBoard = UIStoryboard(name: "Wallet", bundle: nil)
            let next = WalletStoryBoard.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
            SingletonClass.sharedInstance.isFromTopUP = true
            next.delegateForTopUp = self
            self.navigationController?.pushViewController(next, animated: true)
        //            self.SetPaymentOption(SelectionIndex: 0)
        case self.btnCash:
            self.SetPaymentOption(SelectionIndex: 1)
        case self.btnWallet:
            self.SetPaymentOption(SelectionIndex: 2)
        default:
            break
        }
    }
    
    func SetPaymentOption(SelectionIndex:Int) {
        
        self.PayWalletView.backgroundColor = UIColor.white
        self.PayCardView.backgroundColor = UIColor.white
        
        self.PayCashView.backgroundColor = UIColor.white
        
        if SelectionIndex == 0 {
            self.PayCardView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            paymentType = "card"
        } else if SelectionIndex == 1 {
            self.PayCashView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            paymentType = "cash"
            self.lblCardTitle.text = "Credit Card"
            CardID = ""
        } else if SelectionIndex == 2 {
            self.PayWalletView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            paymentType = "wallet"
            self.lblCardTitle.text = "Credit Card"
            CardID = ""
        }
        
    }
    
    
    
    var pickerViewForInvoiceType = UIPickerView()
    
    var CardID = String()
    var paymentType = String()
    
    var intNumberOfPassengerOnShareRiding:Int = 1
    
    var InvoiceTypes:[String] = ["Trip Receipt", "Tax Invoice"]
    
    
    @IBOutlet weak var btnNumberOfPassenger: UIButton!
    
    @IBAction func selectNumberOfPassenger(_ sender: UIButton) {
        //        let arrData = Singletons.sharedInstance.arrReasonForReject.map{$0.strReason}
        
        
        ActionSheetStringPicker.show(withTitle: "Select Number Of Passenger", rows: arrNumberOfPassengerList, initialSelection: 0, doneBlock: { (actionSheet, index, obj) in
            //            self.selectedIndex = index
            //            Singletons.sharedInstance.strReasonForCancel = arrData[index]
            self.btnNumberOfPassenger.setTitle(self.arrNumberOfPassengerList[index], for: .normal)
            
        }, cancel: { (actionSheet) in
            
        }, origin: self.view)
        
    }
    
    
    @IBAction func IncreasePassengerCount(_ sender: UIButton) {
        if intNumberOfPassengerOnShareRiding < self.PasangerDefinedLimit {
            intNumberOfPassengerOnShareRiding = intNumberOfPassengerOnShareRiding + 1
        }
        self.lblNumberOfPassengers.text = "\(intNumberOfPassengerOnShareRiding)"
    }
    
    
    @IBAction func DecreasePassengerCount(_ sender: UIButton) {
        
        if intNumberOfPassengerOnShareRiding > 1 {
            intNumberOfPassengerOnShareRiding = intNumberOfPassengerOnShareRiding - 1
            
        }
        self.lblNumberOfPassengers.text = "\(intNumberOfPassengerOnShareRiding)"
        
    }
    
    
    @IBOutlet weak var tripCheck: M13Checkbox!
    @IBAction func tripCheck(_ sender: M13Checkbox) {
        
        self.SelectReceiptType(index: 0)
    }
    
    
    @IBOutlet weak var taxCheck: M13Checkbox!
    @IBAction func taxCheck(_ sender: M13Checkbox) {
        
        self.SelectReceiptType(index: 1)
        
    }
    
    func SelectReceiptType(index:Int) {
        self.tripCheck.checkState = .unchecked
        self.tripCheck.stateChangeAnimation = .fill
        self.taxCheck.checkState = .unchecked
        self.taxCheck.stateChangeAnimation = .fill
        
        switch index {
        case 0:
            self.tripCheck.checkState = .checked
            self.tripCheck.stateChangeAnimation = .fill
            self.ReceiptType = "Trip Receipt"
        case 1:
            self.taxCheck.checkState = .checked
            self.taxCheck.stateChangeAnimation = .fill
            self.ReceiptType = "Tax Receipt"
        default:
            break
        }
        
    }
    
    
    @IBAction func btnPromocode(_ sender: UIButton) {
        
        boolIsSelected = !boolIsSelected
        
        if (boolIsSelected) {
            stackViewOfPromocode.isHidden = false
            viewHavePromocode.checkState = .checked
            viewHavePromocode.stateChangeAnimation = .fill
        }
        else {
            self.txtHavePromocode.text = ""
            stackViewOfPromocode.isHidden = true
            viewHavePromocode.checkState = .unchecked
            viewHavePromocode.stateChangeAnimation = .fill
        }
    }
    
    
    
    
    @IBAction func viewHavePromocode(_ sender: M13Checkbox) {
        
    }
    
    
    @IBAction func tapToDismissBookNowView(_ sender: UITapGestureRecognizer) {
        //        viewBookNow.isHidden = true
    }
    
    
    @IBAction func btnCloseBookNowView(_ sender: Any) {
        viewBookNow.isHidden = true
        self.view.endEditing(true)
    }
    
    
    @IBOutlet weak var txtInvoiceType: UITextField!
    
    @IBAction func txtInvoiceType(_ sender: UITextField) {
        
        pickerViewForInvoiceType.delegate = self
        pickerViewForInvoiceType.dataSource = self
        
        txtInvoiceType.inputView = pickerViewForInvoiceType
        
    }
    
    @IBOutlet weak var RequestStep1: UIView!
    
    @IBOutlet weak var RequestStep2: UIView!
    
    
    @IBAction func btnContinue(_ sender: Any) {
        RequestStep1.isHidden = true
        RequestStep2.isHidden = false
        self.webserviceOfGetPromocodeList()
    }
    
    @IBOutlet weak var btnSelectPromocode: UIButton!
    
    @IBAction func btnSelectPromocode(_ sender: Any) {
        
        ActionSheetStringPicker.show(withTitle: "Select Promocode", rows: self.arrPromocodeList, initialSelection: 0, doneBlock: { (actionSheet, index, obj) in
            //            self.selectedIndex = index
            //            Singletons.sharedInstance.strReasonForCancel = arrData[index]
            if self.arrPromocodeList.count > 1 {
                self.btnSelectPromocode.setTitle(self.arrPromocodeList[index], for: .normal)
            }
            
        }, cancel: { (actionSheet) in
            
        }, origin: self.view)
        
    }
    
    @IBAction func btnRequestNow(_ sender: UIButton) {
        
        if self.viewHavePromocode.checkState == M13Checkbox.CheckState.checked {
            if self.btnSelectPromocode.currentTitle != "Select Promocode" {
                self.webServiceOfCheckPromoCode()
            } else {
                UtilityClass.showAlert("", message: "Please enter valid promo code!", vc: self)
            }
        } else {
            self.view.endEditing(true)
            self.startProcessToSendRequest()
        }
    }
    
    
    //-------------------------------------------------------------
    // MARK: - PickerView Methods
    //-------------------------------------------------------------
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return InvoiceTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return InvoiceTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.txtInvoiceType.text = InvoiceTypes[row]
        // do something with selected row
    }
    
    func setCardIcon(str: String) -> String {
        //        visa , mastercard , amex , diners , discover , jcb , other
        var CardIcon = String()
        
        switch str {
        case "visa":
            CardIcon = "Visa"
            return CardIcon
        case "mastercard":
            CardIcon = "MasterCard"
            return CardIcon
        case "amex":
            CardIcon = "Amex"
            return CardIcon
        case "diners":
            CardIcon = "Diners Club"
            return CardIcon
        case "discover":
            CardIcon = "Discover"
            return CardIcon
        case "jcb":
            CardIcon = "JCB"
            return CardIcon
        case "iconCashBlack":
            CardIcon = "iconCashBlack"
            return CardIcon
        case "iconWalletBlack":
            CardIcon = "iconWalletBlack"
            return CardIcon
        case "other":
            CardIcon = "iconDummyCard"
            return CardIcon
        default:
            return ""
        }
        
    }
    
    
    // ----------------------------------------------------------------------
    //-------------------------------------------------------------
    // MARK: - Webservice For Find Cards List Available
    //-------------------------------------------------------------
    
    func callToWebserviceOfCardListViewDidLoad() {
        
        // Register to receive notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CardListReload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.reloadWebserviceOfCardList), name: NSNotification.Name(rawValue: "CardListReload"), object: nil)
        
    }
    
    var isReloadWebserviceOfCardList = Bool()
    
    @objc func reloadWebserviceOfCardList() {
        self.webserviceOfCardList()
        isReloadWebserviceOfCardList = true
        
        //        self.paymentOptions()
        
    }
    
    var arrPromocodeList:[String] = []
    
    func webserviceOfGetPromocodeList() {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        
        UtilityClass.showACProgressHUD()
        
        webserviceForPromoCodeList { (result, status) in
            UtilityClass.hideACProgressHUD()
            if (status) {
                print(result)
                if let arrPromo = (result as! [String:Any])["promocode_list"] as? [[String:Any]] {
                    //                let arrPromocodes = (result as! [String:Any])["promocode_list"] as! [[String:Any]]
                    if arrPromo.count > 0 {
                        self.arrPromocodeList.removeAll()
                        self.arrPromocodeList.append("Select Promocode")
                        for PromocodeDict in arrPromo {
                            var Benefit:String = ""
                            var Promocode:String = ""
                            if let FlatValue:String = PromocodeDict["Description"] as? String {
                                Benefit = FlatValue
                            }
                            if let PromoValue:String = PromocodeDict["PromoCode"] as? String {
                                Promocode =  PromoValue
                            }
                            let PromocodeDetail = "\(Promocode) : \(Benefit)"
                            self.arrPromocodeList.append(PromocodeDetail)
                        }
                    } else {
                        self.arrPromocodeList.removeAll()
                        self.arrPromocodeList.append("No promo code available")
                    }
                } else {
                    self.arrPromocodeList.removeAll()
                    self.arrPromocodeList.append("No promo code available")
                }
                
            }
            else {
                //                print(result)
                //                if let res = result as? String {
                //                    UtilityClass.setCustomAlert(title: alertTitle, message: res) { (index, title) in
                //                    }
                //                }
                //                else if let resDict = result as? NSDictionary {
                //                    UtilityClass.setCustomAlert(title: alertTitle, message: resDict.object(forKey: "message") as! String) { (index, title) in
                //                    }
                //                }
                //                else if let resAry = result as? NSArray {
                //                    UtilityClass.setCustomAlert(title: alertTitle, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                //                    }
                //                }
            }
        }
    }
    
    
    var aryCardsListForBookNow = [[String:AnyObject]]()
    
    func webserviceOfCardList() {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        webserviceForCardList(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                //        print(result)
                
                if let res = result as? [String:AnyObject] {
                    if let cards = res["cards"] as? [[String:AnyObject]] {
                        self.aryCardsListForBookNow = cards
                    }
                }
                
                var dict = [String:AnyObject]()
                dict["CardNum"] = "cash" as AnyObject
                dict["CardNum2"] = "cash" as AnyObject
                dict["Type"] = "iconCashBlack" as AnyObject
                
                var dict2 = [String:AnyObject]()
                dict2["CardNum"] = "wallet" as AnyObject
                dict2["CardNum2"] = "wallet" as AnyObject
                dict2["Type"] = "iconWalletBlack" as AnyObject
                
                
                self.aryCardsListForBookNow.append(dict)
                self.aryCardsListForBookNow.append(dict2)
                
                SingletonClass.sharedInstance.CardsVCHaveAryData = (result as! NSDictionary).object(forKey: "cards") as! [[String:AnyObject]]
                
                //                self.pickerView.reloadAllComponents()
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CardListReload"), object: nil)
                
                
                
                
                
                /*
                 {
                 cards =     (
                 {
                 Alias = visa;
                 CardNum = 4639251002213023;
                 CardNum2 = "xxxx xxxx xxxx 3023";
                 Id = 59;
                 Type = visa;
                 }
                 );
                 status = 1;
                 }
                 */
                
                
            }
            else {
                //    print(result)
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
    
    
    //MARK:- SideMenu Methods
    
    @IBOutlet weak var openSideMenu: UIButton!
    @IBAction func openSideMenu(_ sender: Any) {
        
        sideMenuController?.toggle()
        
    }
    
    
    func onGetEstimateFare() {
        
        self.socket.on(SocketData.kReceiveGetEstimateFare, callback: { (data, ack) in
            //            print("onGetEstimateFare() is \(data)")
            
            print("estimate Fare:\(data)")
            if (((data as NSArray).firstObject as? NSDictionary) != nil) {
                var estimateData = (data as! [[String:AnyObject]])
                estimateData = estimateData[0]["estimate_fare"] as! [[String:AnyObject]]
                
                let sortedArray = estimateData.sorted {($0["sort"] as! Int) < ($1["sort"] as! Int)}
                
                if self.aryEstimateFareData == self.aryEstimateFareData {
                    
                    let ary1 = self.aryEstimateFareData as! [[String:AnyObject]]
                    let ary2 = sortedArray
                    
                    for i in 0..<self.aryEstimateFareData.count {
                        
                        let dict1 = ary1[i] as NSDictionary
                        let dict2 = ary2[i] as NSDictionary
                        
                        if dict1 != dict2 {
                            
                            UIView.performWithoutAnimation {
                                self.collectionViewCars.reloadData()
                            }
                        }
                    }
                }
                
                self.aryEstimateFareData = NSMutableArray(array: sortedArray as NSArray)
                
                var count = Int()
                for i in 0..<self.arrNumberOfOnlineCars.count
                {
                    let dictOnlineCarData = (self.arrNumberOfOnlineCars.object(at: i) as! NSDictionary)
                    count = count + (dictOnlineCarData["carCount"] as! Int)
                    if (count == 0)
                    {
                        if(self.arrNumberOfOnlineCars.count == 0)
                        {
                            let alert = UIAlertController(title: "",
                                                          message: "Book Now cars not available. Please click OK to Book Later.",
                                                          preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.btnBookLater((Any).self)
                            }))
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
                            }))
                            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                    // To Display Estimate Fare of Online Car
                    if (self.selectedIndexPath != nil) && (i ==  Int(self.selectedIndexPath!.row)) {
                        if (self.strModelId != "") && (self.strModelId == (dictOnlineCarData.object(forKey: "Id") as? String)) {
                            if (count != 0) {
                                if self.aryEstimateFareData.count != 0 {
                                    if ((self.aryEstimateFareData.object(at: i) as! NSDictionary).object(forKey: "duration") as? NSNull) != nil {
                                        self.lblMinutes.text = "Approximate arrival time \(0) minutes"
                                    }
                                    else if let minute = (self.aryEstimateFareData.object(at: i) as! NSDictionary).object(forKey: "duration") as? Double {
                                        self.lblMinutes.text = "Approximate arrival time \(Int(minute)) minutes"
                                    }
                                    if ((self.aryEstimateFareData.object(at: i) as! NSDictionary).object(forKey: "total") as? NSNull) != nil {
                                        self.lblPrices.text = "\(currencySign) \(0.00)"
                                    }
                                    else if let price = (self.aryEstimateFareData.object(at: i) as! NSDictionary).object(forKey: "total") as? Double {
                                        self.lblPrices.text = currencySign + String(format: "%.2f", price)
                                        //                                        "\(currencySign) \(price)"
                                    }
                                }
                                else {
                                    self.lblMinutes.text = "Approximate arrival time \(0) minutes"
                                    self.lblPrices.text = "\(currencySign) \(0.00)"
                                }
                            }
                            else {
                                self.lblMinutes.text = "Approximate arrival time \(0) minutes"
                                self.lblPrices.text = "\(currencySign) \(0.00)"
                            }
                        }
                    }
                }
                UIView.performWithoutAnimation {
                    self.collectionViewCars.reloadData()
                }
            }
            
            
            
        })
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods for Add Address to Favourite
    //-------------------------------------------------------------
    
    func webserviceOfAddAddressToFavourite(type: String) {
        //        PassengerId,Type,Address,Lat,Lng
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        var param = [String:AnyObject]()
        param["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        param["Type"] = type as AnyObject
        param["Address"] = txtDestinationLocation.text as AnyObject
        param["Lat"] = doubleDropOffLat as AnyObject  // SingletonClass.sharedInstance.currentLatitude as AnyObject
        param["Lng"] = doubleDropOffLng as AnyObject  // SingletonClass.sharedInstance.currentLongitude as AnyObject
        
        webserviceForAddAddress(param as AnyObject) { (result, status) in
            
            if (status) {
                //  print(result)
                
                if let res = result as? String {
                    
                    UtilityClass.setCustomAlert(title: alertTitle, message: res) { (index, title) in
                    }
                }
                else if let res = result as? NSDictionary {
                    
                    let alert = UIAlertController(title: nil, message: res.object(forKey: "message") as? String, preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
                        
                        UIView.transition(with: self.viewForMainFavourite, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
                            self.viewForMainFavourite.isHidden = true
                        }) { _ in }
                    })
                    alert.addAction(OK)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            else {
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
                //     print(result)
            }
        }
    }
    
    //MARK: - Setup Google Maps
    func setupGoogleMap()
    {
        // Initialize the location manager.
        //        locationManager = CLLocationManager()
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        //        locationManager.distanceFilter = 0.1
        //        locationManager.delegate = self
        //        locationManager.startUpdatingLocation()
        //        locationManager.startUpdatingHeading()
        
        locationManager.delegate = self
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            if (locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) || locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)))
            {
                if locationManager.location != nil
                {
                    locationManager.startUpdatingLocation()
                    
                }
                
            }
        }
        
        
//        placesClient = GMSPlacesClient.shared()

        mapView.delegate = self
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: 17)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        
        mapView.camera = camera
        
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
        
        
        //        let position = CLLocationCoordinate2D(latitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude)
        //        let marker = GMSMarker(position: position)
        //        marker.map = self.mapView
        //        marker.isDraggable = true
        //        marker.icon = UIImage(named: "iconCurrentLocation")
        
        
        //        mapView.settings.myLocationButton = false
        //        mapView.isMyLocationEnabled = true
        
        
        
        //        self.mapView.padding = UIEdgeInsets(top:txtDestinationLocation.frame.size.height + txtDestinationLocation.frame.origin.y, left: 0, bottom: 0, right: 0)
        
        viewMap.addSubview(mapView)
        mapView.isHidden = true
        
    }
    
    func getPlaceFromLatLong()
    {
        self.strLocationType = self.currentLocationMarkerText
        self.getAddressForLatLng(latitude: "\(self.defaultLocation.coordinate.latitude )", Longintude: "\(self.defaultLocation.coordinate.longitude )", markerType: strLocationType)
//        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//
//            //            self.txtCurrentLocation.text = "No current place"
//            self.txtCurrentLocation.text = ""
//
//            if let placeLikelihoodList = placeLikelihoodList {
//                let place = placeLikelihoodList.likelihoods.first?.place
//                if let place = place {
//                    self.strPickupLocation = place.name + " " + place.formattedAddress!
//                    //                        place.formattedAddress!
//                    self.doublePickupLat = place.coordinate.latitude
//                    self.doublePickupLng = place.coordinate.longitude
//                    self.txtCurrentLocation.text = place.name + " " + place.formattedAddress!
//                    //                        place.formattedAddress?.components(separatedBy: ", ")
//                    //                        .joined(separator: "\n")
//                    self.strLocationType = self.currentLocationMarkerText
//                }
//            }
//        })
    }
    
    //MARK:- IBActions
    var cardData = [[String:AnyObject]]()
    
    @objc func newBooking(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "New Booking", message: "This will clear old trip details on map for temporary now.", preferredStyle: .alert)
        let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
            self.clearSetupMapForNewBooking()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { ACTION in
            
        })
        alert.addAction(OK)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnCollectionViewScrollRight(_ sender: Any) {
        if (arrTotalNumberOfCars.count <= 5) {
            
            //            self.collectionViewCars.scrollToItem(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .right, animated: true)
        }
        else {
            
            if self.collectionViewCars!.contentSize.width >= 150 {
                self.collectionViewCars.scrollToItem(at: NSIndexPath(row: arrTotalNumberOfCars.count, section: 0) as IndexPath, at: .right, animated: true)
            }
        }
    }
    
    @IBAction func btnCollectionViewScrollLeft(_ sender: Any) {
        
        self.collectionViewCars.scrollToItem(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .left, animated: true)
    }
    
    
    @IBOutlet weak var btnBookNow: UIButton!


    func checkDetailsBeforeBooking() -> Bool
    {
        if(SingletonClass.sharedInstance.CardsVCHaveAryData.isEmpty == true)
        {
            //Segue to card add screen
            self.moveToAddCard()
            return false
        }
        else if(SingletonClass.sharedInstance.strCurrentBalance < 0)
        {
            UtilityClass.showAlert("Negative Wallet Balance", message: "Sorry you will need to top up your wallet\nbefore booking another ride", vc: self)

            return false
        }
        return true
    }
    
    @IBAction func btnBookNow(_ sender: Any) {
        
        //        if BookNowDate != nil {
        //            let DateComponentsRequest = Calendar.current.dateComponents([.second], from: BookNowDate, to: Date())
        //            if Int(DateComponentsRequest.second!) <= 30 {
        //                UtilityClass.setCustomAlert(title: "Info Message", message: "Your one request is pending. so now you can send request after 30 seconds.") { (index, title) in
        //                }
        //                return
        //            }
        //        }
        
        // Unselect HavePromoCode

        if(checkDetailsBeforeBooking())
        {
            self.viewHavePromocode.checkState = .unchecked
            self.viewHavePromocode.stateChangeAnimation = .fill
            self.stackViewOfPromocode.isHidden = true
            self.txtHavePromocode.text = ""
            self.btnSelectPromocode.setTitle("Select Promocode", for: .normal)
            self.txtNote.text = "Additional Information"
            self.txtNote.textColor = UIColor.lightGray
            self.boolIsSelected = false

            //        self.lblNumberOfPassengers.text = "\(intNumberOfPassengerOnShareRiding)"

            self.btnBookNow.setTitleColor(UIColor.white, for: .normal)
            self.btnBookNow.backgroundColor = themeYellowColor

            self.btnBookLater.setTitleColor(themeYellowColor, for: .normal)
            self.btnBookLater.backgroundColor = UIColor.black

            var Count:Int = 0

            if self.arrNumberOfOnlineCars.count > 0 && self.selectedIndexPath != nil {
                let selectedCarData = (self.arrNumberOfOnlineCars.object(at: Int(self.selectedIndexPath!.row)) as! NSDictionary)
                Count = (selectedCarData["carCount"] as! Int)
            }

            if Count == 0 && self.selectedIndexPath == nil {
                UtilityClass.setCustomAlert(title: "Info Message", message: "Please select service type below.") { (index, title) in
                }
                return
                //Stop Execution from here if no car available
            } else if Count == 0 && self.selectedIndexPath?.row == 2 {
                UtilityClass.setCustomAlert(title: "Info Message", message: "Sorry there is no van available at this time. Please try again after a few minutes.") { (index, title) in
                }
                return
            } else if Count == 0 && (self.selectedIndexPath?.row == 0 || self.selectedIndexPath?.row == 1) {
                UtilityClass.setCustomAlert(title: "Info Message", message: "Sorry there is no car available at this time. Please try again after a few minutes.") { (index, title) in
                }
                return
            }

            if Connectivity.isConnectedToInternet()
            {
                if intShareRide == 1 {
                    //                self.stackViewNumberOfPassenger.isHidden = false
                    //                txtNumberOfPassengers.text = "1"
                }
                else {
                    //                self.stackViewNumberOfPassenger.isHidden = true
                    //                txtNumberOfPassengers.text = ""
                }

                if SingletonClass.sharedInstance.strPassengerID == "" || strModelId == "" || strPickupLocation == "" || strDropoffLocation == "" || doublePickupLat == 0 || doublePickupLng == 0 || doubleDropOffLat == 0 || doubleDropOffLng == 0 || strCarModelID == ""
                {
                    if txtCurrentLocation.text!.count == 0 {

                        UtilityClass.setCustomAlert(title: "", message: "Please enter your pickup location again") { (index, title) in
                        }
                    }
                    else if txtDestinationLocation.text!.count == 0 {

                        UtilityClass.setCustomAlert(title: "", message: "Please enter your destination again") { (index, title) in
                        }
                    }
                    else if strModelId == "" {

                        //                    UtilityClass.setCustomAlert(title: appName, message: "There are no cars available. Do you want to pay extra chareges?") { (index, title) in
                        //                    }

                        let alert = UIAlertController(title: appName, message: "There are no vehicles available within 5 kms and do u want to pay additional \(currencySign) \(strSpecialRequestFareCharge) and make a booking?", preferredStyle: .alert)
                        let OK = UIAlertAction(title: "Yes", style: .default, handler: { ACTION in
                            self.strSpecialRequest = "1"
                            self.bookingRequest()
                            self.webserviceCallForMissBookingRequest()

                        })
                        let Cancel = UIAlertAction(title: "No", style: .destructive, handler: { ACTION in

                            self.webserviceCallForMissBookingRequest()

                        })

                        alert.addAction(OK)
                        alert.addAction(Cancel)
                        self.present(alert, animated: true, completion: nil)

                    }
                    else {
                        UtilityClass.setCustomAlert(title: "", message: "Locations or select available car") { (index, title) in
                        }
                    }

                }
                else {
                    strSpecialRequest = "0"
                    bookingRequest()

                    //                if (SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0) && self.aryCardsListForBookNow.count == 2 {
                    //                    //                UtilityClass.showAlert("", message: "There is no card, If you want to add card than choose payment options to add card.", vc: self)
                    //
                    //                    let alert = UIAlertController(title: nil, message: "Do you want to add card.", preferredStyle: .alert)
                    //                    let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
                    //
                    //                        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
                    //
                    //                        next.delegateAddCardFromHomeVC = self
                    //
                    //                        self.navigationController?.present(next, animated: true, completion: nil)
                    //
                    //                    })
                    //                    let Cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { ACTION in
                    //                        self.paymentOptions()
                    //                    })
                    //                    alert.addAction(OK)
                    //                    alert.addAction(Cancel)
                    //                    self.present(alert, animated: true, completion: nil)
                    //
                    //                }
                    //                else {
                    //                    self.paymentOptions()
                    //                }
                }

            }
            else {
                UtilityClass.showAlert("", message: "Internet connection not available", vc: self)
            }
        }
    }
    
    func moveToAddCard()
    {
        if SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0 {
            let WalletStoryBoard = UIStoryboard(name: "Wallet", bundle: nil)
            let next = WalletStoryBoard.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
            next.isFromHomeVC = true
            self.navigationController?.pushViewController(next, animated: false)
        }

    }
    func bookingRequest()
    {
        self.paymentOptions()
        
        //        if (SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0) && self.aryCardsListForBookNow.count == 2 {
        //            //                UtilityClass.showAlert("", message: "There is no card, If you want to add card than choose payment options to add card.", vc: self)
        //
        //            let alert = UIAlertController(title: nil, message: "Select Payment Method Credit Card Cash Wallet.", preferredStyle: .alert)
        //            let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
        //
        //                let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
        //
        //                next.delegateAddCardFromHomeVC = self
        //
        //                self.navigationController?.present(next, animated: true, completion: nil)
        //
        //            })
        //            let Cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { ACTION in
        //                self.paymentOptions()
        //            })
        //            alert.addAction(OK)
        //            alert.addAction(Cancel)
        //            self.present(alert, animated: true, completion: nil)
        //
        //        }
        //        else {
        //            self.paymentOptions()
        //        }
        
        
    }
    
    func paymentOptions() {
        
        if SingletonClass.sharedInstance.CardsVCHaveAryData.count != 0 {
            
            cardData = SingletonClass.sharedInstance.CardsVCHaveAryData
            
            for i in 0..<aryCardsListForBookNow.count {
                cardData.append(aryCardsListForBookNow[i])
            }
            
            if self.aryCardsListForBookNow.count != 0 {
                cardData = self.aryCardsListForBookNow
            }
            
        }
        else {
            cardData.removeAll()
            
            for i in 0..<aryCardsListForBookNow.count {
                cardData.append(aryCardsListForBookNow[i])
            }
        }
        //        self.pickerView.reloadAllComponents()
        
        let data = cardData[0]
        
        //        imgPaymentType.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        //        txtSelectPaymentOption.text = data["CardNum2"] as? String
        
        let type = data["CardNum"] as! String
        
        if type  == "wallet" {
            paymentType = "wallet"
        }
        else if type == "cash" {
            paymentType = "cash"
        }
        else {
            paymentType = "card"
        }
        
        if paymentType == "card" {
            CardID = data["Id"] as! String
        }
        self.SetPaymentOption(SelectionIndex: 1)
        self.SelectReceiptType(index: 0)
        if strCarModelClass == "VAN" {
            self.arrNumberOfPassengerList = ["5","6","7","8","9","10"]
            //            self.PasangerDefinedLimit = 4
            //            self.lblPassengers.text = "(maximum \(self.PasangerDefinedLimit) passengers)"
        } else {
            self.arrNumberOfPassengerList = ["1","2","3","4"]
            
            //            self.lblPassengers.text = "(maximum \(self.PasangerDefinedLimit) passengers)"
        }
        self.btnNumberOfPassenger.setTitle(self.arrNumberOfPassengerList[0], for: .normal)
        RequestStep1.isHidden = false
        RequestStep2.isHidden = true
        viewBookNow.isHidden = false
        
        
    }
    
    func didAddCardFromHomeVC() {
        paymentOptions()
    }
    
    
    
    @IBOutlet weak var btnBookLater: UIButton!
    
    @IBAction func btnBookLater(_ sender: Any) {

        if(checkDetailsBeforeBooking())
        {
        
        self.btnBookLater.setTitleColor(UIColor.white, for: .normal)
        self.btnBookLater.backgroundColor = themeYellowColor
        
        self.btnBookNow.setTitleColor(themeYellowColor, for: .normal)
        self.btnBookNow.backgroundColor = UIColor.black
        
        if Connectivity.isConnectedToInternet() {
            
            let profileData = SingletonClass.sharedInstance.dictProfile
            
            // This is For Book Later Address
            if (SingletonClass.sharedInstance.isFromNotificationBookLater) {
                
                if strCarModelID == "" {
                    UtilityClass.showAlert("", message: "Please select service type below.", vc: self)
                    //                    UtilityClass.setCustomAlert(title: "", message: "Select Car") { (index, title) in
                    //                    }
                }
                else {
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "BookLaterViewController") as! BookLaterViewController
                    SingletonClass.sharedInstance.isFromNotificationBookLater = false
                    
                    next.strModelId = strCarModelID
                    next.strCarModelURL = strNavigateCarModel
                    next.strCarName = strCarModelClass
                    next.BookLaterCompleted = self
                    next.strFullname = profileData.object(forKey: "Fullname") as! String
                    next.strMobileNumber = profileData.object(forKey: "MobileNo") as! String
                    next.strPickupLocation = strPickupLocation
                    next.doublePickupLat = doublePickupLat
                    next.doublePickupLng = doublePickupLng
                    
                    let visibleRegion = mapView.projection.visibleRegion()
                    let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
                    next.NearByRegion = bounds
                    
                    if strCarModelClass == "Premium" {
                        next.PasangerDefinedLimit = 4
                    } else {
                        next.PasangerDefinedLimit = 6
                    }
                    
                    next.strDropoffLocation = strDropoffLocation
                    next.doubleDropOffLat = doubleDropOffLat
                    next.doubleDropOffLng = doubleDropOffLng
                    
                    self.navigationController?.pushViewController(next, animated: true)
                }
            }
            else {
                
                if strCarModelID == "" && strCarModelIDIfZero == "" || selectedIndexPath == nil {
                    UtilityClass.showAlert("", message: "Please select service type below.", vc: self)
                    //                    UtilityClass.setCustomAlert(title: "", message: "Select Car") { (index, title) in
                    //                    }
                }
                else {
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "BookLaterViewController") as! BookLaterViewController
                    
                    next.strModelId = strCarModelID
                    next.strCarModelURL = strNavigateCarModel
                    next.strCarName = strCarModelClass
                    next.strPickupLocation = strPickupLocation
                    next.doublePickupLat = doublePickupLat
                    next.doublePickupLng = doublePickupLng
                    next.BookLaterCompleted = self
                    if strCarModelClass == "Premium" {
                        next.PasangerDefinedLimit = 4
                    } else {
                        next.PasangerDefinedLimit = 6
                    }
                    
                    let visibleRegion = mapView.projection.visibleRegion()
                    let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
                    next.NearByRegion = bounds
                    
                    next.strDropoffLocation = strDropoffLocation
                    next.doubleDropOffLat = doubleDropOffLat
                    next.doubleDropOffLng = doubleDropOffLng
                    
                    next.strFullname = profileData.object(forKey: "Fullname") as! String
                    next.strMobileNumber = profileData.object(forKey: "MobileNo") as! String
                    
                    self.navigationController?.pushViewController(next, animated: true)
                    
                }
            }
        }
        else {
            UtilityClass.showAlert("", message: "Internet connection not available", vc: self)
        }
        
        }
    }
    
    @IBAction func btnGetFareEstimate(_ sender: Any) {
        
        if txtCurrentLocation.text == "" || txtDestinationLocation.text == "" {
            
            UtilityClass.setCustomAlert(title: "", message: "Please enter both address.") { (index, title) in
            }
        }
            
        else {
            
            self.postPickupAndDropLocationForEstimateFare()
        }
    }
    
    @IBOutlet weak var btnRequest: UIButton!
    @IBAction func btnRequest(_ sender: UIButton)
    {
        let ConfirmationAlert = UIAlertController(title: "", message: "Are you sure you want to cancel the trip?", preferredStyle: UIAlertControllerStyle.alert)
        let YesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            
            if self.strBookingType == "BookLater" {
                self.CancelBookLaterTripAfterDriverAcceptRequest()
            }
            else {
                self.socketMethodForCancelRequestTrip()
            }
            
            
            self.clearMap()
            
            self.txtCurrentLocation.text = ""
            self.txtDestinationLocation.text = ""
            
            self.clearDataAfteCompleteTrip()
            
            self.getPlaceFromLatLong()
            
            
            //        UtilityClass.setCustomAlert(title: "\(appName)", message: "Request Cancelled") { (index, title) in
            //        }
            
            self.viewTripActions.isHidden = true
            self.viewCarLists.isHidden = true
            self.ConstantViewCarListsHeight.constant = 230
            //        self.constraintTopSpaceViewDriverInfo.constant = 170
            //        self.viewShareRideView.isHidden = true
        }
        
        let NoAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        ConfirmationAlert.addAction(YesAction)
        ConfirmationAlert.addAction(NoAction)
        self.present(ConfirmationAlert, animated: true, completion: nil)
        
        
        
    }
    
    @IBOutlet weak var btnDriverInfo: UIButton!
    @IBAction func btnDriverInfo(_ sender: UIButton) {
        
        let DriverInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSArray).object(at: 0) as! NSDictionary
        let carInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSArray).object(at: 0) as! NSDictionary
        let bookingInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        
        var DriverRating:String = ""
        if let DriverRate:String = (self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).value(forKey: "DriverRate")  as? String {
            DriverRating = DriverRate
        } else if let DriverRate:NSNumber = (self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).value(forKey: "DriverRate")  as? NSNumber {
            DriverRating = "\(DriverRate)"
        }
        //        let DriverRating = (self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).value(forKey: "DriverRate") as! Double
        
        print(self.aryRequestAcceptedData.object(at: 0) as! NSDictionary)
        print("Driver Rate is --- \(DriverRating) ---")
        showDriverInfo(bookingInfo: bookingInfo, DriverInfo: DriverInfo, carInfo: carInfo, DriverRate:DriverRating)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func swipDownDriverInfo(_ sender: UISwipeGestureRecognizer) {
        
        //        constraintTopSpaceViewDriverInfo.constant = 170
        
    }
    
    @IBAction func TapToDismissGesture(_ sender: UITapGestureRecognizer) {
        
        
//        UIView.transition(with: viewForMainFavourite, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
//            self.viewForMainFavourite.isHidden = true
//        }) { _ in }
//
//
//        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        
        
        //        self.dismiss(animated: true, completion: nil)
    }
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("Hello World")
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    @IBAction func btnCancelStartedTrip(_ sender: UIButton) {
        UtilityClass.showAlert("", message: "Currently this feature is not available.", vc: self)
    }
    
    //-------------------------------------------------------------
    // MARK: - Favourite Delegate Methods
    //-------------------------------------------------------------
    
    func didEnterFavouriteDestination(Source: [String:AnyObject]) {
        
        txtDestinationLocation.text = Source["Address"] as? String
        strDropoffLocation = Source["Address"] as! String
        doubleDropOffLat = Double(Source["Lat"] as! String)!
        doubleDropOffLng = Double(Source["Lng"] as! String)!
    }
    
    //-------------------------------------------------------------
    // MARK: - Favourites Actions
    //-------------------------------------------------------------
    
    @IBAction func btnHome(_ sender: UIButton) {
        
        
        webserviceOfAddAddressToFavourite(type: "Home")
    }
    
    @IBAction func btnOffice(_ sender: UIButton) {
        
        webserviceOfAddAddressToFavourite(type: "Office")
    }
    
    @IBAction func btnAirport(_ sender: UIButton) {
        
        webserviceOfAddAddressToFavourite(type: "Airport")
    }
    
    @IBAction func btnOthers(_ sender: UIButton) {
        
        webserviceOfAddAddressToFavourite(type: "Others")
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Sound Implement Methods
    //-------------------------------------------------------------
    
    var audioPlayer:AVAudioPlayer!
    
    //    RequestConfirm.m4a
    //    ringTone.mp3
    
    
    func playSound(fileName: String, extensionType: String) {
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: extensionType) else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            audioPlayer.numberOfLoops = 1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound(fileName: String, extensionType: String) {
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: extensionType) else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            audioPlayer.stop()
            audioPlayer = nil
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    
    @IBOutlet weak var lblMinutes: UILabel!
    @IBOutlet weak var lblPrices: UILabel!
    
    
    //MARK:- Collectionview Delegate and Datasource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.arrNumberOfOnlineCars.count == 0 {
            return arrDemoCarList.count
        }
        //
        return self.arrNumberOfOnlineCars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarsCollectionViewCell", for: indexPath as IndexPath) as! CarsCollectionViewCell
        
        if selectedIndexPath == indexPath {
            cell.lblCarType.textColor = UIColor.init (red: 9.0/255.0, green: 149.0/255.0, blue: 184.0/255.0, alpha: 1.0)
            //            cell.selectedArrow.isHidden = false
        }
        else {
            //            cell.selectedArrow.isHidden = true
            cell.lblCarType.textColor = UIColor.white
        }
        
        var dictOnlineCarData:[String:AnyObject] = [:]
        if (self.arrNumberOfOnlineCars.count > 0)
        {
            dictOnlineCarData = (arrNumberOfOnlineCars.object(at: indexPath.row) as! [String : AnyObject])
        }
        else {
            dictOnlineCarData = (arrDemoCarList[indexPath.row]  as [String : AnyObject])
        }
        
        let imageURL = dictOnlineCarData["Image"] as! String
        
        cell.imgCars.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.medium)
        cell.imgCars.sd_setShowActivityIndicatorView(true)
        
        if let CarName = dictOnlineCarData["Name"] as? String {
            cell.lblCarType.text = CarName
        }
        
        cell.imgCars.sd_setImage(with: URL(string: imageURL), completed: { (image, error, cacheType, url) in
            cell.imgCars.sd_setShowActivityIndicatorView(false)
        })
        
        return cell
        
        // Maybe for future testing ///////
        
        
    }
    
    var markerOnlineCars = GMSMarker()
    var aryMarkerOnlineCars = [GMSMarker]()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        MarkerCurrntLocation.isHidden = true
        
        //        if self.arrNumberOfOnlineCars.count == 0 {
        //            // do nothing here
        //        }
        //        else if (arrNumberOfOnlineCars.count != 0 && indexPath.row < self.arrNumberOfOnlineCars.count)
        //        {
        if self.arrNumberOfOnlineCars.count > 0  {
            
            let dictOnlineCarData = (arrNumberOfOnlineCars.object(at: indexPath.row) as! NSDictionary)
            strSpecialRequestFareCharge = dictOnlineCarData.object(forKey: "SpecialExtraCharge") as? String ?? ""
            
            if dictOnlineCarData.object(forKey: "carCount") as! Int != 0 {
                
                self.markerOnlineCars.map = nil
                
                for i in 0..<self.aryMarkerOnlineCars.count {
                    self.aryMarkerOnlineCars[i].map = nil
                }
                
                self.aryMarkerOnlineCars.removeAll()
                
                let available = dictOnlineCarData.object(forKey: "carCount") as! Int
                let checkAvailabla = String(available)
                
                //            var lati = dictOnlineCarData.object(forKey: "Lat") as! Double
                //            var longi = dictOnlineCarData.object(forKey: "Lng") as! Double
                //
                //                let camera = GMSCameraPosition.camera(withLatitude: lati,
                //                                                      longitude: longi,
                //                                                      zoom: 17.5)
                //
                //                self.mapView.camera = camera
                
                let locationsArray = (dictOnlineCarData.object(forKey: "locations") as! [[String:AnyObject]])
                
                for i in 0..<locationsArray.count
                {
                    if( (locationsArray[i]["CarType"] as! String) == (dictOnlineCarData.object(forKey: "Id") as! String))
                    {
                        //                    lati = (locationsArray[i]["Location"] as! [AnyObject])[0] as! Double
                        //                    longi = (locationsArray[i]["Location"] as! [AnyObject])[1] as! Double
                        //                    let position = CLLocationCoordinate2D(latitude: lati, longitude: longi)
                        //                    self.markerOnlineCars = GMSMarker(position: position)
                        //                        self.markerOnlineCars.tracksViewChanges = false
                        //                        self.strSelectedCarMarkerIcon = self.markertIcon(index: indexPath.row)
                        self.strSelectedCarMarkerIcon = "dummyCar"
                        
                        //       this code for set image according to car type
                        //                            self.setCarImage(modelId: dictOnlineCarData.object(forKey: "Id") as! String)
                        
                        
                        //                        self.markerOnlineCars.icon = UIImage(named: self.markertIcon(index: indexPath.row)) // iconCurrentLocation
                        
                        //                    self.aryMarkerOnlineCars.append(self.markerOnlineCars)
                        
                        //                        self.markerOnlineCars.map = nil
                        //                    self.markerOnlineCars.map = self.mapView
                        
                    }
                }
                
                // Show Nearest Driver from Passenger
                if self.aryMarkerOnlineCars.count != 0 {
                    if self.aryMarkerOnlineCars.first != nil {
                        if let nearestDriver = self.aryMarkerOnlineCars.first {
                            
                            let camera = GMSCameraPosition.camera(withLatitude: nearestDriver.position.latitude, longitude: nearestDriver.position.longitude, zoom: 17.5)
                            self.mapView.camera = camera
                        }
                    }
                }
                
                for i in 0..<self.aryMarkerOnlineCars.count {
                    
                    self.aryMarkerOnlineCars[i].position = self.aryMarkerOnlineCars[i].position
                    self.aryMarkerOnlineCars[i].icon = UIImage(named: "")
                    //                    self.setCarImage(modelId: dictOnlineCarData.object(forKey: "Id") as! String)
                    self.aryMarkerOnlineCars[i].map = self.mapView
                }
                
                let carModelID = dictOnlineCarData.object(forKey: "Id") as? String
                let carModelIDConverString: String = carModelID!
                
                let strCarName: String = dictOnlineCarData.object(forKey: "Name") as! String
                
                strCarModelClass = strCarName
                strCarModelID = carModelIDConverString
                
                selectedIndexPath = indexPath
                
                let cell = collectionView.cellForItem(at: indexPath) as! CarsCollectionViewCell
                cell.viewOfImage.layer.borderColor = themeYellowColor.cgColor
                
                let imageURL = dictOnlineCarData.object(forKey: "Image") as! String
                strNavigateCarModel = imageURL
                strCarModelIDIfZero = ""
                
                if checkAvailabla != "0" {
                    strModelId = dictOnlineCarData.object(forKey: "Id") as! String
                }
                //            else {
                //                strModelId = "0"
                //            }
                
                if available != 0 {
                    
                    if self.aryEstimateFareData.count != 0 {
                        
                        if ((self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "duration") as? NSNull) != nil {
                            
                            self.lblMinutes.text = "Approximate arrival time \(0) minutes"
                        }
                        else if let minute = (self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "duration") as? Double {
                            self.lblMinutes.text = "Approximate arrival time \(Int(minute)) minutes"
                        }
                        
                        if ((self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "total") as? NSNull) != nil {
                            
                            self.lblPrices.text = "\(currencySign) \(0.00)"
                        }
                        else if let price = (self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "total") as? Double {
                            
                            self.lblPrices.text = currencySign + String(format: "%.2f", price)
                            //                        "\(currencySign) \(price)"
                            
                        }
                    }
                    else {
                        self.lblMinutes.text = "Approximate arrival time \(0) minutes"
                        self.lblPrices.text = "\(currencySign) \(0.00)"
                    }
                    
                }
                else {
                    self.lblMinutes.text = "Approximate arrival time \(0) minutes"
                    self.lblPrices.text = "\(currencySign) \(0.00)"
                }
                
            }
            else {
                
                for i in 0..<self.aryMarkerOnlineCars.count {
                    
                    self.aryMarkerOnlineCars[i].map = nil
                }
                
                self.aryMarkerOnlineCars.removeAll()
                
                
                let carModelID = dictOnlineCarData.object(forKey: "Id") as? String
                let carModelIDConverString: String = carModelID!
                
                let strCarName: String = dictOnlineCarData.object(forKey: "Name") as! String
                
                strCarModelClass = strCarName
                strCarModelID = carModelIDConverString
                
                let cell = collectionView.cellForItem(at: indexPath) as! CarsCollectionViewCell
                cell.viewOfImage.layer.borderColor = themeGrayColor.cgColor
                
                selectedIndexPath = indexPath
                
                let imageURL = dictOnlineCarData.object(forKey: "Image") as! String
                
                strNavigateCarModel = imageURL
                //                strCarModelID = ""
                strCarModelIDIfZero = carModelIDConverString
                
                let available = dictOnlineCarData.object(forKey: "carCount") as! Int
                let checkAvailabla = String(available)
                
                if checkAvailabla != "0" {
                    strModelId = dictOnlineCarData.object(forKey: "Id") as! String
                }
                //            else {
                //                strModelId = ""
                //            }
                
                
                if available != 0 {
                    
                    if self.aryEstimateFareData.count != 0 {
                        
                        if ((self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "duration") as? NSNull) != nil {
                            
                            self.lblMinutes.text = "Approximate arrival time \(0) minutes"
                        }
                        else if let minute = (self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "duration") as? Double {
                            self.lblMinutes.text = "Approximate arrival time \(Int(minute)) minutes"
                        }
                        
                        if ((self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "total") as? NSNull) != nil {
                            
                            self.lblPrices.text = "\(currencySign) \(0.00)"
                        }
                        else if let price = (self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "total") as? Double {
                            
                            self.lblPrices.text = currencySign + String(format: "%.2f", price)
                            //                        "\(currencySign) \(price)"
                            
                        }
                    }
                    else {
                        self.lblMinutes.text = "Approximate arrival time \(0) minutes"
                        self.lblPrices.text = "\(currencySign) \(0.00)"
                    }
                    
                }
                else {
                    self.lblMinutes.text = "Approximate arrival time \(0) minutes"
                    self.lblPrices.text = "\(currencySign) \(0.00)"
                }
                
            }
            collectionViewCars.reloadData()
        }
        else {
            let dictOnlineCarData = self.arrDemoCarList[indexPath.row]
            let carModelID = dictOnlineCarData["Id"] as? String
            let carModelIDConverString: String = carModelID!
            let strCarName: String = dictOnlineCarData["Name"] as! String
            
            strCarModelClass = strCarName
            strCarModelID = carModelIDConverString
            
            let cell = collectionView.cellForItem(at: indexPath) as! CarsCollectionViewCell
            cell.viewOfImage.layer.borderColor = themeGrayColor.cgColor
            
            selectedIndexPath = indexPath
            
            let imageURL = dictOnlineCarData["Image"] as! String
            strNavigateCarModel = imageURL
            strCarModelIDIfZero = carModelIDConverString
            
            selectedIndexPath = indexPath
            collectionViewCars.reloadData()
        }
        
        //        }
        //        else
        //        {
        //
        //            let PackageVC = self.storyboard?.instantiateViewController(withIdentifier: "PackageViewController")as! PackageViewController
        //            let navController = UINavigationController(rootViewController: PackageVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
        //
        //            PackageVC.strPickupLocation = strPickupLocation
        //            PackageVC.doublePickupLat = doublePickupLat
        //            PackageVC.doublePickupLng = doublePickupLng
        //
        //            self.present(navController, animated:true, completion: nil)
        //
        //        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! CarsCollectionViewCell
        cell.viewOfImage.layer.borderColor = themeGrayColor.cgColor
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let CellWidth = UIScreen.main.bounds.width - 20
        return CGSize(width: CellWidth/3 , height: self.collectionViewCars.frame.size.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if (intShareRide == 1) {
            
            if (self.aryEstimateFareData.count) != 0 {
                if self.aryEstimateFareData.object(at: indexPath.row) as? NSDictionary != nil {
                    
                    if let ride = (self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "share_ride") as? String {
                        
                        if ride == "1" {
                            return true
                        }
                        else if ride == "0" {
                            return false
                        }
                    }
                }
            }            
        }
        
        return true
    }
    
    var carLocationsLat = Double()
    var carLocationsLng = Double()
    //MARK - Set car icons
    func setData()
    {
        var k = 0 as Int
        self.arrNumberOfOnlineCars.removeAllObjects()
        
        aryTempOnlineCars = NSMutableArray()
        
        for j in 0..<self.arrTotalNumberOfCars.count
        {
            if ((self.arrTotalNumberOfCars[j] as! [String:AnyObject])["Status"] as! String) == "1" {
                k = 0
                let tempAryLocationOfDriver = NSMutableArray()
                
                let totalCarsAvailableCarTypeID = (self.arrTotalNumberOfCars.object(at: j) as! NSDictionary).object(forKey: "Id") as! String
                for i in 0..<self.arrNumberOfAvailableCars.count
                {
                    let dictLocation = NSMutableDictionary()
                    
                    let carType = (self.arrNumberOfAvailableCars.object(at: i) as! NSDictionary).object(forKey: "CarType") as! String
                    
                    if (totalCarsAvailableCarTypeID == carType)
                    {
                        k = k+1
                    }
                    
                    carLocationsLat = ((self.arrNumberOfAvailableCars.object(at: i) as! NSDictionary).object(forKey: "Location") as! NSArray).object(at: 0) as! Double
                    carLocationsLng = ((self.arrNumberOfAvailableCars.object(at: i) as! NSDictionary).object(forKey: "Location") as! NSArray).object(at: 1) as! Double
                    dictLocation.setDictionary(((self.arrNumberOfAvailableCars.object(at: i) as! NSDictionary) as! [AnyHashable : Any]))
                    tempAryLocationOfDriver.add(dictLocation)
                    
                }
                
                let tempDict =  NSMutableDictionary(dictionary: (self.arrTotalNumberOfCars.object(at: j) as! NSDictionary))
                tempDict.setObject(k, forKey: "carCount" as NSCopying)
                tempDict.setObject(carLocationsLat, forKey: "Lat" as NSCopying)
                tempDict.setObject(carLocationsLng, forKey: "Lng" as NSCopying)
                tempDict.setObject(tempAryLocationOfDriver, forKey: "locations" as NSCopying)
                aryTempOnlineCars.add(tempDict)
            }
            
        }
        
        SortIdOfCarsType()
        
    }
    
    var aryTempOnlineCars = NSMutableArray()
    var checkTempData = NSArray()
    
    var aryOfOnlineCarsIds = [String]()
    var aryOfTempOnlineCarsIds = [String]()
    
    func SortIdOfCarsType() {
        
        //        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
        
        let sortedArray = (self.aryTempOnlineCars as NSArray).sortedArray(using: [NSSortDescriptor(key: "Sort", ascending: true)]) as! [[String:AnyObject]]
        
        self.arrNumberOfOnlineCars = NSMutableArray(array: sortedArray)
        
        if self.checkTempData.count == 0 {
            
            SingletonClass.sharedInstance.isFirstTimeReloadCarList = true
            self.checkTempData = self.aryTempOnlineCars as NSArray
            
            self.collectionViewCars.reloadData()
        }
        else {
            
            for i in 0..<self.aryTempOnlineCars.count {
                
                let arySwif = self.aryTempOnlineCars.object(at: i) as! NSDictionary
                
                if (self.checkTempData.object(at: i) as! NSDictionary) == arySwif {
                    
                    if SingletonClass.sharedInstance.isFirstTimeReloadCarList == true {
                        SingletonClass.sharedInstance.isFirstTimeReloadCarList = false
                        
                        //                        if self.txtCurrentLocation.text!.count != 0 && self.txtDestinationLocation.text!.count != 0 && self.aryOfOnlineCarsIds.count != 0 {
                        self.postPickupAndDropLocationForEstimateFare()
                        //                        }
                        self.collectionViewCars.reloadData()
                    }
                }
                else {
                    self.checkTempData = self.aryTempOnlineCars as NSArray
                    
                    //                    if self.txtCurrentLocation.text!.count != 0 && self.txtDestinationLocation.text!.count != 0 && self.aryOfOnlineCarsIds.count != 0 {
                    self.postPickupAndDropLocationForEstimateFare()
                    //                    }
                    self.collectionViewCars.reloadData()
                    
                }
            }
        }
        //        })
        
    }
    
    //    func markertIcon(index: Int) -> String {
    //
    //        switch index {
    //        case 0: // "1":
    //            return "imgTaxi"
    //        case 1: // "2":
    //            return "imgTaxi"
    //        case 2: // "3":
    //            return "imgTaxi"
    //        case 3: // "4":
    //            return "imgTaxi"
    //        case 4: // "5":
    //            return "imgTaxi"
    //        case 5: // "6":
    //            return "imgTaxi"
    //        case 6: // "7":
    //            return "imgTaxi"
    //            //        case "8":
    //            //            return "imgTaxi"
    //            //        case "9":
    //            //            return "imgTaxi"
    //            //        case "10":
    //            //            return "imgTaxi"
    //            //        case "11":
    //        //            return "imgTaxi"
    //        default:
    //            return "imgTaxi"
    //        }
    
    func setCarImage(modelId : String) -> String {
        
        var CarModel = String()
        
        switch modelId {
        case "1":
            CarModel = "imgBusinessClass"
            return CarModel
        case "2":
            CarModel = "imgMIni"
            return CarModel
        case "3":
            CarModel = "imgVan"
            return CarModel
        case "4":
            CarModel = "imgNano"
            return CarModel
        case "5":
            CarModel = "imgTukTuk"
            return CarModel
        case "6":
            CarModel = "imgBreakdown"
            return CarModel
        default:
            CarModel = "imgBus"
            return CarModel
        }
    }
    
    /*/
     switch index {
     case 0: // "1":
     return "iconNano"
     case 1: // "2":
     return "iconPremium"
     case 2: // "3":
     return "iconBreakdownServices"
     case 3: // "4":
     return "iconVan"
     case 4: // "5":
     return "iconTukTuk"
     case 5: // "6":
     return "iconMiniCar"
     case 6: // "7":
     return "iconBusRed"
     //        case "8":
     //            return "Motorbike"
     //        case "9":
     //            return "Car Delivery"
     //        case "10":
     //            return "Van / Trays"
     //        case "11":
     //            return "3T truck"
     default:
     return "imgTaxi"
     }
     */
    
    //        switch index {
    //        case 0:
    //            return "imgFirstClass"
    //        case 1:
    //            return "imgBusinessClass"
    //        case 2:
    //            return "imgEconomy"
    //        case 3:
    //            return "imgTaxi"
    //        case 4:
    //            return "imgLUXVAN"
    //        case 5:
    //            return "imgDisability"
    //        default:
    //            return ""
    //        }
    
    
    func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "seguePresentTripDetails")
        {
            let drinkViewController = segue.destination as! TripDetailsViewController
            drinkViewController.arrData = arrDataAfterCompletetionOfTrip
            drinkViewController.BookingID = SingletonClass.sharedInstance.bookingId
            //            if let bookingInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as? NSDictionary {
            //                if let TripBookingID:String = bookingInfo.object(forKey: "Id") as? String {
            //                    drinkViewController.BookingID = TripBookingID
            //                }
            //            }
            drinkViewController.delegate = self
            
        }
        
        if(segue.identifier == "segueDriverInfo")
        {
            //            let deiverInfo = segue.destination as! DriverInfoViewController
        }
        if(segue.identifier == "showRating")
        {
            
            let GiveRatingVC = segue.destination as! GiveRatingViewController
            GiveRatingVC.strBookingType = self.strBookingType
            //            GiveRatingVC.delegate = self
        }
    }
    
    
   /* func BookingConfirmed(dictData : NSDictionary)
    {
        
        let DriverInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSArray).object(at: 0) as! NSDictionary
        let carInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSArray).object(at: 0) as! NSDictionary
        let bookingInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        
        
        //                showDriverInfo(bookingInfo: bookingInfo, DriverInfo: DriverInfo, carInfo: carInfo)
        
    }*/
    
    //MARK: - Socket Methods
    func socketMethods()
    {
        var isSocketConnected = Bool()
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print ("socket is disconnected please reconnect")
        }
        
        socket.on(clientEvent: .reconnect) { (data, ack) in
            print ("socket is reconnected")
        }
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            
            if UserDefaults.standard.bool(forKey: kIsSocketEmited) == false
            {
                // set all socket on method here.....
                UserDefaults.standard.set(true, forKey: kIsSocketEmited)
                UserDefaults.standard.synchronize()
                self.methodsAfterConnectingToSocket()
                
                if self.socket.status != .connected {
                    print("socket.status != .connected")
                }
                
                if (isSocketConnected == false) {
                    isSocketConnected = true
                    self.socketMethodForGettingBookingAcceptNotification()  // Accept Now Req
                    self.onDriverArrviedAtPickupLocation()                  // Arrived Driver in BookNow Request
                    self.socketMethodForGettingBookingRejectNotification()  // Reject Now Req
                    self.socketMethodForGettingPickUpNotification()         // Start Now Req
                    self.socketMethodForGettingTripCompletedNotification()  // CompleteTrip Now Req
                    self.onTripHoldingNotificationForPassengerLater()       // Hold Trip Later
                    self.onReceiveDriverLocationToPassenger()               // Driver Location Receive
                    self.socketMethodForGettingBookingRejectNotificatioByDriver()   // Reject By Driver
                    self.onAcceptBookLaterBookingRequestNotification()              // Accept Later Req
                    self.onDriverArrviedBookLaterAtPickupLocation()                  // Arrived Driver in BookLater Request
                    self.onRejectBookLaterBookingRequestNotification()              // Reject Later Req
                    self.onPickupPassengerByDriverInBookLaterRequestNotification()
                    self.onTripHoldingNotificationForPassenger()                    // Hold Trip Now
                    self.onBookingDetailsAfterCompletedTrip()                       // Booking Details After Complete Trip
                    self.onGetEstimateFare()                                        // Get Estimate
                    self.onAdvanceTripInfoBeforeStartTrip()                         // Start Later Req
                    self.onReceiveNotificationWhenDriverAcceptRequest()
                    
                }
                
                self.socket.on(SocketData.kNearByDriverList, callback: { (data, ack) in
                    print("near by driver list is \(data)")
                    
                    //                var lat : Double!
                    //                var long : Double!
//                    let availablePredicate = NSPredicate(format: "Available like 0")
                    self.arrNumberOfAvailableCars = NSMutableArray(array: ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "driver") as! NSArray)
                    
                    if self.selectedIndexPath == nil && self.arrNumberOfAvailableCars.count > 0 && self.viewCarLists.isHidden == true && self.viewTripActions.isHidden == true {
                        self.mapView.clear()
                        for AvailableCar in self.arrNumberOfAvailableCars {
                            if let AvailableCarInfo = AvailableCar as? NSDictionary {
                                let CarType = AvailableCarInfo.object(forKey: "CarType") as! String
                                
                                var CarImage:String = ""
                                
                                if CarType == "1" || CarType == "2" {
                                    CarImage = "car_icon"
                                } else if CarType == "3" {
                                    CarImage = "van_icon"
                                }
                                
                                var CarLocation = CLLocation()
                                if let CarLocations = AvailableCarInfo.object(forKey: "Location") as? [Any] {
                                    CarLocation = CLLocation(latitude: Double(CarLocations[0] as! Double), longitude: Double(CarLocations[1] as! Double))
                                }
                                //
                                let AvailableCarMarker = GMSMarker(position: CarLocation.coordinate)
                                //                                GMSMarker(position: self.destinationCoordinate)// self.destinationCoordinate  // self.destinationCoordinate
                                AvailableCarMarker.map = self.mapView
                                AvailableCarMarker.icon = UIImage(named: CarImage)
                                //                                GMSMarker.markerImage(with: UIColor.red)
                                AvailableCarMarker.title = ""
                            }
                        }
                    }
                    
                    
                    
                    if (((data as NSArray).object(at: 0) as! NSDictionary).count != 0)
                    {
                        for i in 0..<(((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "driver") as! NSArray).count
                        {
                            
                            let arrayOfCoordinte = ((((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "driver") as! NSArray).object(at: i) as! NSDictionary).object(forKey: "Location") as! NSArray
                            //                        lat = arrayOfCoordinte.object(at: 0) as! Double
                            //                        long = arrayOfCoordinte.object(at: 1) as! Double
                            
                            let DriverId = ((((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "driver") as! NSArray).object(at: i) as! NSDictionary).object(forKey: "DriverId") as! String
                            
                            self.aryOfTempOnlineCarsIds.append(DriverId)
                            self.aryOfOnlineCarsIds = self.uniq(source: self.aryOfTempOnlineCarsIds)
                        }
                    }
                    self.postPickupAndDropLocationForEstimateFare()
                    if self.txtCurrentLocation.text!.count != 0 && self.txtDestinationLocation.text!.count != 0 && self.aryOfOnlineCarsIds.count != 0 {
                        self.setData()
                    }
                })
            }
            else
            {
                //already socket connected
            }
        }
        
        if self.isRequestedToConnectSocket == false {
            self.isRequestedToConnectSocket = true
            socket.connect()
        }
    }
    
    var timesOfAccept = Int()
    @objc func bookingAcceptNotificationMethodCallInTimer() {
        timesOfAccept += 1
        print("ACCCEPT by Timer: \(timesOfAccept)")
        
        self.socketMethodForGettingBookingAcceptNotification()
    }
    
    func scheduledTimerWithTimeInterval(){
        DispatchQueue.global(qos: .background).sync {
            // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
            timerToUpdatePassengerlocation = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimerforUpdatePassengerLatlong(){
        if timerToUpdatePassengerlocation != nil {
            timerToUpdatePassengerlocation.invalidate()
            timerToUpdatePassengerlocation = nil
        }
    }
    
    @objc func updateCounting(){
        let myJSON = ["PassengerId" : SingletonClass.sharedInstance.strPassengerID, "Lat": doublePickupLat, "Long": doublePickupLng, "Token" : SingletonClass.sharedInstance.deviceToken, "ShareRide": SingletonClass.sharedInstance.isShareRide] as [String : Any]
        socket.emit(SocketData.kUpdatePassengerLatLong , with: [myJSON])
    }
    
    
    func methodsAfterConnectingToSocket()
    {
        scheduledTimerWithTimeInterval()
    }
    
    @objc func OffSocket() {
        self.socket.off(SocketData.kReceiveGetEstimateFare)
        self.socket.off(SocketData.kNearByDriverList)
        self.socket.off(SocketData.kAcceptBookingRequestNotification)
        self.socket.off(SocketData.kRejectBookingRequestNotification)
        self.socket.off(SocketData.kCancelTripByDriverNotficication)
        self.socket.off(SocketData.kPickupPassengerNotification)
        self.socket.off(SocketData.kBookingCompletedNotification)
        self.socket.off(SocketData.kAcceptAdvancedBookingRequestNotification)
        self.socket.off(SocketData.kRejectAdvancedBookingRequestNotification)
        self.socket.off(SocketData.kAdvancedBookingPickupPassengerNotification)
        self.socket.off(SocketData.kReceiveHoldingNotificationToPassenger)
        self.socket.off(SocketData.kAdvancedBookingTripHoldNotification)
        self.socket.off(SocketData.kReceiveDriverLocationToPassenger)
        self.socket.off(SocketData.kAdvancedBookingDetails)
        self.socket.off(SocketData.kInformPassengerForAdvancedTrip)
        self.socket.off(SocketData.kAcceptAdvancedBookingRequestNotify)
        self.socket.off(SocketData.kArrivedDriverBookNowRequest)
        self.socket.off(SocketData.kArrivedDriverBookLaterRequest)
    }
    
    func socketMethodForGettingBookingAcceptNotification()
    {
        // Socket Accepted
        self.socket.on(SocketData.kAcceptBookingRequestNotification, callback: { (data, ack) in
            print("AcceptBooking data is \(data)")
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            UtilityClass.setCustomAlert(title: "Booking Confirmed", message: "Your Driver is On The Way.", completionHandler: { (index, status) in
                if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                    (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                }
            })
            
            self.locationManager.startUpdatingLocation()
            self.strBookingType = "BookNow"
            if let getInfoFromData = data as? [[String:AnyObject]] {
                
                if let infoData = getInfoFromData[0] as? [String:AnyObject] {
                    if let bookingInfo = infoData["BookingInfo"] as? [[String:AnyObject]] {
                        var bookingIdIs = String()
                        if let nowBookingID: Int = (bookingInfo[0])["Id"] as? Int {
                            bookingIdIs = "\(nowBookingID)"
                        }
                        else if let nowBookingID: String = (bookingInfo[0])["Id"] as? String {
                            bookingIdIs = nowBookingID
                        }
                        print("bookingIdIs: \(bookingIdIs)")
                        
                        if SingletonClass.sharedInstance.bookingId != "" {
                            if SingletonClass.sharedInstance.bookingId == bookingIdIs {
                                self.DriverInfoAndSetToMap(driverData: NSArray(array: data))
                            }
                        }
                        else {
                            self.DriverInfoAndSetToMap(driverData: NSArray(array: data))
                        }
                    }
                }
            }
            
        })
    }
    
    func DriverInfoAndSetToMap(driverData: NSArray) {
        
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: true)
        
        //        SingletonClass.sharedInstance.isTripContinue = true
        
        self.MarkerCurrntLocation.isHidden = true
        
        self.viewTripActions.isHidden = false
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        //        self.viewShareRideView.isHidden = true
        
        self.viewActivity.stopAnimating()
        self.viewMainActivityIndicator.isHidden = true
        self.btnRequest.isHidden = false
        self.btnCancelStartedTrip.isHidden = true
        
        self.aryRequestAcceptedData = NSArray(array: driverData)
        
        let bookingInfo : NSDictionary!
        let DriverInfo: NSDictionary!
        let carInfo: NSDictionary!
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            DriverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSArray).object(at: 0) as! NSDictionary
        }
        else {
            // print ("Yes its dictionary")
            DriverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSDictionary)
        }
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            bookingInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        }
        else
        {
            // print ("Yes its dictionary")
            bookingInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            carInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "CarInfo") as? NSArray)?.object(at: 0) as? NSDictionary
        }
        else
        {
            // print ("Yes its dictionary")
            carInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        if let passengerType = bookingInfo.object(forKey: "PassengerType") as? String {
            if passengerType == "other" || passengerType == "others" {
                SingletonClass.sharedInstance.passengerTypeOther = true
            }
        }
        
        if let strArrivedTime = (bookingInfo as! [String:Any])["ArrivedTime"] as? String {
            if Int(strArrivedTime)! > 0 {
                self.btnRequest.isHidden = true
                self.btnCancelStartedTrip.isHidden = true
            }
        }
        
        SingletonClass.sharedInstance.dictDriverProfile = DriverInfo
        SingletonClass.sharedInstance.dictCarInfo = (carInfo as? [String: AnyObject])!
        //        showDriverInfo(bookingInfo: bookingInfo, DriverInfo: DriverInfo, carInfo: carInfo)
        
        
        // by Change       self.sendPassengerIDAndDriverIDToGetLocation(driverID: String(describing: DriverInfo.object(forKey: "Id")!) , passengerID: String(describing: bookingInfo.object(forKey: "PassengerId")!))
        
        
//        self.BookingConfirmed(dictData: (driverData[0] as! NSDictionary) )
        
//        let driverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
//        _details = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "Details") as! NSArray).object(at: 0) as! NSDictionary
        
        if let bookID =  bookingInfo.object(forKey: SocketDataKeys.kBookingIdNow) as? String {
            SingletonClass.sharedInstance.bookingId = bookID
        }
        else if let bookID = bookingInfo.object(forKey: "Id") as? String {
            SingletonClass.sharedInstance.bookingId = bookID
        }
        else if let bookID = bookingInfo.object(forKey: "Id") as? Int {
            SingletonClass.sharedInstance.bookingId = "\(bookID)"
        }
        
        txtCurrentLocation.text = bookingInfo.object(forKey: "PickupLocation") as? String
        txtDestinationLocation.text = bookingInfo.object(forKey: "DropoffLocation") as? String
        
        
        //        let PickupLat = defaultLocation.coordinate.latitude
        //        let PickupLng =  defaultLocation.coordinate.longitude
        
        let PickupLat = bookingInfo.object(forKey: "PickupLat") as! String
        let PickupLng =  bookingInfo.object(forKey: "PickupLng") as! String
        
        //        let DropOffLat = driverInfo.object(forKey: "PickupLat") as! String
        //        let DropOffLon = driverInfo.object(forKey: "PickupLng") as! String
        
        let DropOffLat = DriverInfo.object(forKey: "Lat") as! String
        let DropOffLon = DriverInfo.object(forKey: "Lng") as! String
        
        
//        let dummyLatitude = Double(PickupLat)! - Double(DropOffLat)!
//        let dummyLongitude = Double(PickupLng)! - Double(DropOffLon)!
        
//        _ = Double(PickupLat)! - dummyLatitude
//        _ = Double(PickupLng)! - dummyLongitude
        
//        let originalLoc: String = "\(PickupLat),\(PickupLng)"
//        let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
        
        strPickUpLatitude = PickupLat
        strPickUpLongitude = PickupLng
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(DropOffLat)!,
                                              longitude: Double(DropOffLon)!,
                                              zoom: 18)
        
        mapView.camera = camera
        
        //commented for Query Limit Issue //MARK:- Rahul
//        self.getDirectionsAcceptRequest(origin: originalLoc, destination: destiantionLoc) { (index, title) in
//        }
        //        self.callforMapLine(functionname: #function)
        updatePolyLineToMapFromDriverLocation()
        
        NotificationCenter.default.post(name: NotificationForAddNewBooingOnSideMenu, object: nil)
        
    }
    
    func methodAfterStartTrip(tripData: NSArray) {
        
        self.MarkerCurrntLocation.isHidden = true
        
        SingletonClass.sharedInstance.isTripContinue = true
        
        destinationCordinate = CLLocationCoordinate2D(latitude: dropoffLat, longitude: dropoffLng)
        self.stopTimerforUpdatePassengerLatlong()
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: true)
        self.viewTripActions.isHidden = false
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        //        self.viewShareRideView.isHidden = true
        
        self.viewActivity.stopAnimating()
        self.viewMainActivityIndicator.isHidden = true
        self.btnRequest.isHidden = true
        self.btnCancelStartedTrip.isHidden = true
        
        let bookingInfo : NSDictionary!
        let DriverInfo: NSDictionary!
        let carInfo: NSDictionary!
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            DriverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSArray).object(at: 0) as! NSDictionary
        }
        else {
            // print ("Yes its dictionary")
            DriverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSDictionary)
        }
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            bookingInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as? NSDictionary
        }
        else
        {
            // print ("Yes its dictionary")
            bookingInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            carInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSArray).object(at: 0) as? NSDictionary
        }
        else
        {
            // print ("Yes its dictionary")
            carInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        SingletonClass.sharedInstance.dictDriverProfile = DriverInfo
        SingletonClass.sharedInstance.dictCarInfo = carInfo as! [String: AnyObject]
        //        showDriverInfo(bookingInfo: bookingInfo, DriverInfo: DriverInfo, carInfo: carInfo)
        
        // ------------------------------------------------------------
        let DropOffLat = bookingInfo.object(forKey: "DropOffLat") as! String
        let DropOffLon = bookingInfo.object(forKey: "DropOffLon") as! String
        
        let picklat = bookingInfo.object(forKey: "PickupLat") as! String
        let picklng = bookingInfo.object(forKey: "PickupLng") as! String
        
        dropoffLat = Double(DropOffLat)!
        dropoffLng = Double(DropOffLon)!
        
        self.txtDestinationLocation.text = bookingInfo.object(forKey: "DropoffLocation") as? String
        self.txtCurrentLocation.text = bookingInfo.object(forKey: "PickupLocation") as? String
        
        let PickupLat = self.defaultLocation.coordinate.latitude
        let PickupLng = self.defaultLocation.coordinate.longitude
        
        //        let PickupLat = Double(picklat)
        //        let PickupLng = Double(picklng)
        
        
//        let dummyLatitude = Double(PickupLat) - Double(DropOffLat)!
//        let dummyLongitude = Double(PickupLng) - Double(DropOffLon)!
//
//        let waypointLatitude = self.defaultLocation.coordinate.latitude - dummyLatitude
//        let waypointSetLongitude = self.defaultLocation.coordinate.longitude - dummyLongitude
//
        let originalLoc: String = "\(PickupLat),\(PickupLng)"
        let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
        
        let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: Double(picklat)!, longitude: Double(picklng)!), coordinate: CLLocationCoordinate2D(latitude: Double(DropOffLat)!, longitude: Double(DropOffLon)!))
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(100))
        
        self.mapView.animate(with: update)
        
        self.mapView.moveCamera(update)
        
        //commented for Query Limit Issue -
        self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, completionHandler: nil)
        //        self.callforMapLine(functionname: #function)
        
        NotificationCenter.default.post(name: NotificationForAddNewBooingOnSideMenu, object: nil)
        
    }
    
    //MARK:- Show Driver Information
    
    func showDriverInfo(bookingInfo : NSDictionary, DriverInfo: NSDictionary, carInfo : NSDictionary, DriverRate:String) {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "DriverInfoViewController") as! DriverInfoViewController
        
        next.strDriverName = DriverInfo.object(forKey: "Fullname") as! String
        next.strPickupLocation = "Pickup Location : \(bookingInfo.object(forKey: "PickupLocation") as! String)"
        next.DriverRate = DriverRate
        print("driver rate \(#function) -- \(DriverRate) --")
        next.strDropoffLocation = "Dropoff Location : \(bookingInfo.object(forKey: "DropoffLocation") as! String)"
        if let carClass = carInfo.object(forKey: "Model") as? NSDictionary {
            next.strCarClass = carClass.object(forKey: "Name") as! String // String(describing: carInfo.object(forKey: "VehicleModel")!)
        }
        else {
            next.strCarClass = String(describing: carInfo.object(forKey: "VehicleModel")!)
        }
        
        if let carPlateNumber = carInfo.object(forKey: "VehicleRegistrationNo") as? String {
            next.strCarPlateNumber = carPlateNumber
        }
        
        var carCompany:String = ""
        var carModelName:String = ""
        var carRegistrationNo:String = ""
        var carModel:String = ""
        var carColor:String = ""
        
        if let company = carInfo.object(forKey: "Company") as? String {
            carCompany = company
        }
        
        if let modelName = carInfo.object(forKey: "VehicleModelName") as? String {
            carModelName = modelName
        }
        
        if let registrationNumber = carInfo.object(forKey: "VehicleRegistrationNo") as? String {
            carRegistrationNo = registrationNumber
        }
        
        if let ModelDict = (carInfo.object(forKey: "Model") as? NSDictionary) {
            if let Model = ModelDict.object(forKey: "Name") as? String {
                carModel = Model
            }
        }
        
        if let Color = carInfo.object(forKey: "Color") as? String {
            carColor = Color
        }
        
        
        next.strCarInfo = "\(carCompany) \(carModelName)-\(carRegistrationNo)-\(carModel)-\(carColor)"
        next.strCareName = carInfo.object(forKey: "Company") as! String
        next.strDriverImage = WebserviceURLs.kImageBaseURL + (DriverInfo.object(forKey: "Image") as! String)
        next.strCarImage = WebserviceURLs.kImageBaseURL + (carInfo.object(forKey: "VehicleImage") as! String)
        
        //        if (SingletonClass.sharedInstance.passengerTypeOther) {
        //            next.strPassengerMobileNumber = bookingInfo.object(forKey: "PassengerContact") as! String
        //        }
        //        else {
        next.strPassengerMobileNumber = DriverInfo.object(forKey: "MobileNo") as! String
        
        //        }
        //        self.present(next, animated: true, completion: nil)
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
    }
    
    
    func socketMethodForGettingBookingRejectNotification()
    {
        // Socket Accepted
        self.socket.on(SocketData.kRejectBookingRequestNotification, callback: { (data, ack) in
            print("socketMethodForGettingBookingRejectNotification() is \(data)")
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            var bookingId = String()
            self.arrivedRoutePath = nil

            //            self.BookNowDate = nil
            self.strBookingType = "BookNow"
            if let bookingInfoData = (data as! [[String:AnyObject]])[0] as? [String:AnyObject] {
                if let bookingInfo = bookingInfoData["BookingId"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData["BookingId"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        self.viewActivity.stopAnimating()
                        self.viewMainActivityIndicator.isHidden = true
                        UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                            if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                                (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                            }
                        })
                    }
                }
                else {
                    self.viewActivity.stopAnimating()
                    self.viewMainActivityIndicator.isHidden = true
                    UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                        if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                            (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                        }
                    })
                }
            }
            
            //            self.viewActivity.stopAnimating()
            //            self.viewMainActivityIndicator.isHidden = true
            //            UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
            //
            //            })
            
            /*
             [{
             BookingId = 7623;
             message = "Your Booking request has been canceled";
             type = BookingRequest;
             }]
             */
            
            
        })
    }
    
    
    
    func socketMethodForGettingBookingRejectNotificatioByDriver()
    {
        // Socket Accepted
        self.socket.on(SocketData.kCancelTripByDriverNotficication, callback: { (data, ack) in
            print("socketMethodForGettingBookingRejectNotificatioByDriver() is \(data)")
            
            var bookingId = String()
            self.arrivedRoutePath = nil
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            if let bookingInfoData = (data as! [[String:AnyObject]])[0]["BookingInfo"] as? [[String:AnyObject]] {
                if let bookingInfo = bookingInfoData[0]["Id"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData[0]["Id"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        self.viewActivity.stopAnimating()
                        self.viewMainActivityIndicator.isHidden = true
                        //                        self.currentLocationAction()
                        self.getPlaceFromLatLong()
                        self.clearDataAfteCompleteTrip()
                        self.currentLocationAction()
                        //                        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                        
                        self.viewTripActions.isHidden = true
                        SingletonClass.sharedInstance.passengerTypeOther = false
                        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                        UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                            if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                                (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                            }
                        })
                    }
                } else {
                    self.viewActivity.stopAnimating()
                    self.viewMainActivityIndicator.isHidden = true
                    //                    self.currentLocationAction()
                    self.getPlaceFromLatLong()
                    self.clearDataAfteCompleteTrip()
                    self.currentLocationAction()
                    //                    self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                    
                    self.viewTripActions.isHidden = true
                    SingletonClass.sharedInstance.passengerTypeOther = false
                    self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                    UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                        if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                            (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                        }
                    })
                }
            }
        })
    }
    
    func socketMethodForGettingPickUpNotification()
    {
        self.socket.on(SocketData.kPickupPassengerNotification, callback: { (data, ack) in
            print("socketMethodForGettingPickUpNotification() is \(data)")
            //            self.stopTimer()
            /*
             [{
             BookingId = 7625;
             DriverId = 70;
             message = "Your trip has now started.";
             }]
             */
            self.strBookingType = "BookNow"
            var bookingIdIs = String()
            
            if let bookingData = data as? [[String:AnyObject]] {
                if let id = bookingData[0]["BookingId"] as? String {
                    bookingIdIs = id
                }
                else if let id = bookingData[0]["BookingId"] as? Int {
                    bookingIdIs = "\(id)"
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    if SingletonClass.sharedInstance.bookingId == bookingIdIs {
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                            
                        })
                        
                        self.btnRequest.isHidden = true
                        self.btnCancelStartedTrip.isHidden = true
                        
                        self.methodAfterStartTrip(tripData: NSArray(array: data))
                    }
                }
                else {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                        
                    })
                    
                    self.btnRequest.isHidden = true
                    self.btnCancelStartedTrip.isHidden = true
                    
                    self.methodAfterStartTrip(tripData: NSArray(array: data))
                }
                
            }
            
            
            //            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            //            UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
            //
            //            })
            //
            //            self.btnRequest.isHidden = true
            //            self.btnCancelStartedTrip.isHidden = true
            //
            //            self.methodAfterStartTrip(tripData: NSArray(array: data))
            
        })
    }
    
    func socketMethodForGettingTripCompletedNotification()
    {
        self.socket.on(SocketData.kBookingCompletedNotification, callback: { (data, ack) in
            print("socketMethodForGettingTripCompletedNotification() is \(data)")
            
            SingletonClass.sharedInstance.isTripContinue = false
            self.aryCompleterTripData = data as! [[String:Any]]
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            self.strBookingType = "BookNow"
            if let getInfoFromData = data as? [[String:AnyObject]] {
                
                if let infoData = getInfoFromData[0] as? [String:AnyObject] {
                    if let bookingInfo = infoData["Info"] as? [[String:AnyObject]] {
                        var bookingIdIs = String()
                        if let nowBookingID: Int = (bookingInfo[0])["Id"] as? Int {
                            bookingIdIs = "\(nowBookingID)"
                        }
                        else if let nowBookingID: String = (bookingInfo[0])["Id"] as? String {
                            bookingIdIs = nowBookingID
                        }
                        print("bookingIdIs: \(bookingIdIs)")
                        
                        if SingletonClass.sharedInstance.bookingId != "" {
                            if SingletonClass.sharedInstance.bookingId == bookingIdIs {
                                if (SingletonClass.sharedInstance.passengerTypeOther) {
                                    
                                    SingletonClass.sharedInstance.passengerTypeOther = false
                                    var IsPaid:Bool = false
                                    if let paymentStatus = infoData["Payment"] as? String {
                                        IsPaid = paymentStatus == "NotPaid" ? false : true
                                    }
                                    
                                     self.completeTripInfo(isPaid:IsPaid)
                                }
                                else {
                                    var IsPaid:Bool = false
                                    if let paymentStatus = infoData["Payment"] as? String {
                                        IsPaid = paymentStatus == "NotPaid" ? false : true
                                    }
                                    self.completeTripInfo(isPaid:IsPaid)
                                    //                self.performSegue(withIdentifier: "showRating", sender: nil)
                                }
                            }
                        }
                    }
                }
            }
            
            /*
             
             let bookingId = ((((data as! [[String:AnyObject]])[0] as! [String:AnyObject])["Info"] as! [[String:AnyObject]])[0] as! [String:AnyObject])["Id"]
             
             //            self.viewMainFinalRating.isHidden = false
             
             if (SingletonClass.sharedInstance.passengerTypeOther) {
             
             SingletonClass.sharedInstance.passengerTypeOther = false
             self.completeTripInfo()
             }
             else {
             
             self.completeTripInfo()
             //                self.performSegue(withIdentifier: "showRating", sender: nil)
             }
             
             //            let next = self.storyboard?.instantiateViewController(withIdentifier: "GiveRatingViewController") as! GiveRatingViewController
             //            next.strBookingType = self.strBookingType
             //            next.delegate = self
             //            next.modalPresentationStyle = .overCurrentContext
             //            self.present(next, animated: true, completion: nil)
             */
            
        })
    }
    
    
    func completeTripInfo(isPaid:Bool) {
        
        clearMap()
        self.stopTimer()
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        self.scheduledTimerWithTimeInterval()
        
        if isPaid == true {
        UtilityClass.showAlertWithCompletion("Your trip has been completed", message: "", vc: self, completionHandler: { (status) in
            if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
            }
            
            if (status == true)
            {
                
//                self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                
                self.dismiss(animated: true, completion: nil)
                //                    self.socket.off(SocketData.kBookingCompletedNotification)
                
                self.arrDataAfterCompletetionOfTrip = self.aryCompleterTripData
                //                    NSMutableArray(array: (self.aryCompleterTripData[0] as! NSDictionary).object(forKey: "Info") as! NSArray)
                
//                self.viewTripActions.isHidden = true
//                self.viewCarLists.isHidden = false
//                self.ConstantViewCarListsHeight.constant = 230
//                self.viewMainFinalRating.isHidden = true
//                SingletonClass.sharedInstance.passengerTypeOther = false

//                self.currentLocationAction()
//                self.getPlaceFromLatLong()
//                self.getRaringNotification()
//                self.clearDataAfteCompleteTrip()
                
                //                if (SingletonClass.sharedInstance.passengerTypeOther) {
                //                }
                //                else {
                //
                //                    self.openRatingView()
                //                }
                self.perform(#selector(HomeViewController.showTripReceipt), with: nil, afterDelay: 1.0)
                
            }
        })
        } else {
            UtilityClass.setCustomAlert(title: "Message", message: "Your account might be blocked within sometime as you haven't paid the trip fare.") { (Index, responseString) in
                self.dismiss(animated: true, completion: nil)
                self.arrDataAfterCompletetionOfTrip = self.aryCompleterTripData
                self.perform(#selector(HomeViewController.showTripReceipt), with: nil, afterDelay: 1.0)
            }
        }
    }
    
    @objc func showTripReceipt() {
        let TripViewController = self.storyboard?.instantiateViewController(withIdentifier: "TripDetailsViewController") as! TripDetailsViewController
        TripViewController.arrData = arrDataAfterCompletetionOfTrip
        TripViewController.BookingID = SingletonClass.sharedInstance.bookingId
        TripViewController.delegate = self
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(TripViewController, animated: true, completion: nil)
        
        //          self.performSegue(withIdentifier: "seguePresentTripDetails", sender: nil)
    }
    
    
    func clearSetupMapForNewBooking() {
        
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
        clearMap()
        self.currentLocationAction()
        self.viewTripActions.isHidden = true
        //        self.viewCarLists.isHidden = false
        //        self.ConstantViewCarListsHeight.constant = 150
        clearDataAfteCompleteTrip()
    }
    
    func clearDataAfteCompleteTrip() {
        
        self.MarkerCurrntLocation.isHidden = false
        selectedIndexPath = nil
        self.lblMinutes.text = "Approximate arrival time \(0) minutes"
        self.lblPrices.text = "\(currencySign) \(0.00)"
        self.collectionViewCars.reloadData()
        self.txtCurrentLocation.text = ""
        self.txtDestinationLocation.text = ""
        self.dropoffLat = 0
        self.doublePickupLng = 0
        
        //        SingletonClass.sharedInstance.strPassengerID = ""
        
        self.strModelId = ""
        self.strPickupLocation = ""
        self.strDropoffLocation = ""
        self.ReceiptType = ""
        self.intNumberOfPassengerOnShareRiding = 1
        self.doublePickupLat = 0
        self.doublePickupLng = 0
        self.doubleDropOffLat = 0
        self.doubleDropOffLng = 0
        self.txtNote.text = "Additional Information"
        self.txtNote.textColor = UIColor.lightGray
        self.txtFeedbackFinal.text = ""
        self.txtHavePromocode.text = ""
        //        self.txtSelectPaymentOption.text = ""
        SingletonClass.sharedInstance.isTripContinue = false
        SingletonClass.sharedInstance.bookingId = ""
        
    }
    
    func getRaringNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CallToRating"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.openRatingView), name: Notification.Name("CallToRating"), object: nil)
    }
    
    @objc func openRatingView() {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "GiveRatingViewController") as! GiveRatingViewController
        
        let bookingInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        next.strBookingType = self.strBookingType
        if let Bookid = bookingInfo.object(forKey: "Id") as? String {
            next.strBookingID = Bookid
        }
        next.Delegate = self
        
        //        next.delegate = self
        //            self.presentingViewController?.modalPresentationStyle
        
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
        
        //        self.present(next, animated: true, completion: nil)
    }
    
    func DidCompletedRating() {
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
        self.viewTripActions.isHidden = true
        self.viewCarLists.isHidden = false
        self.ConstantViewCarListsHeight.constant = 230
        self.viewMainFinalRating.isHidden = true
        SingletonClass.sharedInstance.passengerTypeOther = false
        self.currentLocationAction()
        self.getPlaceFromLatLong()
        self.getRaringNotification()
        self.clearDataAfteCompleteTrip()
    }
    
    func socketMethodForCancelRequestTrip()
    {
        
        let myJSON = [SocketDataKeys.kBookingIdNow : SingletonClass.sharedInstance.bookingId] as [String : Any]
        socket.emit(SocketData.kCancelTripByPassenger , with: [myJSON])
        stopTimer()
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
        self.viewCarLists.isHidden = true
        self.arrivedRoutePath = nil

        //        self.viewShareRideView.isHidden = true
        
    }
    
    
    // ------------------------------------------------------------
    
    func onAcceptBookLaterBookingRequestNotification() {
        
        self.socket.on(SocketData.kAcceptAdvancedBookingRequestNotification, callback: { (data, ack) in
            print("onAcceptBookLaterBookingRequestNotification() is \(data)")
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            //            self.playSound(fileName: "RequestConfirm", extensionType: "mp3")
            
            //            UtilityClass.showAlertWithCompletion("", message: "Your request has been Accepted.", vc: self, completionHandler: { ACTION in
            //
            //                self.stopSound(fileName: "RequestConfirm", extensionType: "mp3")
            //            })
            self.strBookingType = "BookLater"
            var bookingId = String()
            
            if let bookingInfoData = (data as! [[String:AnyObject]])[0]["BookingInfo"] as? [[String:AnyObject]] {
                if let bookingInfo = bookingInfoData[0]["Id"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData[0]["Id"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        print("Request Accepted")
                        UtilityClass.setCustomAlert(title: "\(appName)", message: "Your request has been Accepted.") { (index, title) in
                            if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                                (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                            }
                            //               self.stopSound(fileName: "RequestConfirm", extensionType: "mp3")
                        }
                        self.strBookingType = "BookLater"
                        self.DriverInfoAndSetToMap(driverData: NSArray(array: data))
                    }
                }
                else {
                    print("Request has Accepted2")
                    UtilityClass.setCustomAlert(title: "\(appName)", message: "Your request has been Accepted.") { (index, title) in
                        if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                            (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                        }
                        //               self.stopSound(fileName: "RequestConfirm", extensionType: "mp3")
                    }
                    self.strBookingType = "BookLater"
                    self.DriverInfoAndSetToMap(driverData: NSArray(array: data))
                }
            }
        })
    }
    
    func onRejectBookLaterBookingRequestNotification() {
        
        self.socket.on(SocketData.kRejectAdvancedBookingRequestNotification, callback: { (data, ack) in
            print("onRejectBookLaterBookingRequestNotification() is \(data)")
            self.strBookingType = "BookLater"
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            //            self.playSound(fileName: "PickNGo", extensionType: "mp3")
            self.arrivedRoutePath = nil

            let alert = UIAlertController(title: nil, message: "Your request has been rejected.", preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: { (ACTION) in
                if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                    (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                }
                //                self.stopSound(fileName: "PickNGo", extensionType: "mp3")
            })
            alert.addAction(OK)
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
            
        })
    }
    
    func onPickupPassengerByDriverInBookLaterRequestNotification() {
        
        self.socket.on(SocketData.kAdvancedBookingPickupPassengerNotification, callback: { (data, ack) in
            print("onPickupPassengerByDriverInBookLaterRequestNotification() is \(data)")
            self.strBookingType = "BookLater"
            var bookingId = String()
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            if let bookingInfoData = (data as! [[String:AnyObject]])[0]["BookingInfo"] as? [[String:AnyObject]] {
                if let bookingInfo = bookingInfoData[0]["Id"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData[0]["Id"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        self.strBookingType = "BookLater"
                        let alert = UIAlertController(title: nil, message: "Your trip has now started.", preferredStyle: .alert)
                        let OK = UIAlertAction(title: "OK", style: .default , handler: { (UIAlertAction) in
                            if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                                (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                            }
                        })
                        alert.addAction(OK)
                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        self.btnRequest.isHidden = true
                        self.btnCancelStartedTrip.isHidden = true
                        //            SingletonClass.sharedInstance.isTripContinue = true
                        self.methodAfterStartTrip(tripData: NSArray(array: data))
                        
                    }
                }
                else {
                    self.strBookingType = "BookLater"
                    let alert = UIAlertController(title: nil, message: "Your trip has now started.", preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        
                        if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                            (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                        }
                    })
                    alert.addAction(OK)
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    self.btnRequest.isHidden = true
                    self.btnCancelStartedTrip.isHidden = true
                    //            SingletonClass.sharedInstance.isTripContinue = true
                    self.methodAfterStartTrip(tripData: NSArray(array: data))
                }
            }
            
        })
    }
    
    func onTripHoldingNotificationForPassenger() {
        
        self.socket.on(SocketData.kReceiveHoldingNotificationToPassenger, callback: { (data, ack) in
            print("onTripHoldingNotificationForPassenger() is \(data)")
            
            var message = String()
            message = "Trip on Hold"
            
            if let resAry = NSArray(array: data) as? NSArray {
                message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                //                UtilityClass.showAlert("", message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
            }
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(OK)
            
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
            
        })
    }
    
    func onTripHoldingNotificationForPassengerLater() {
        
        self.socket.on(SocketData.kAdvancedBookingTripHoldNotification, callback: { (data, ack) in
            print("onTripHoldingNotificationForPassengerLater() is \(data)")
            
            var message = String()
            message = "Trip on Hold"
            
            if let resAry = NSArray(array: data) as? NSArray {
                message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                //                UtilityClass.showAlert("", message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
            }
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(OK)
            
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
            
            
        })
    }
    
    func onReceiveDriverLocationToPassenger() {
        
        self.socket.on(SocketData.kReceiveDriverLocationToPassenger, callback: { (data, ack) in
            print("onReceiveDriverLocationToPassenger() is \(data)")
            
            if SingletonClass.sharedInstance.bookingId != "" {
                SingletonClass.sharedInstance.driverLocation = (data as NSArray).object(at: 0) as! [String : AnyObject]
                
                var DoubleLat = Double()
                var DoubleLng = Double()
                
                if let lat = SingletonClass.sharedInstance.driverLocation["Location"]! as? [Double] {
                    DoubleLat = lat[0]
                    DoubleLng = lat[1]
                }
                else if let lat = SingletonClass.sharedInstance.driverLocation["Location"]! as? [String] {
                    DoubleLat = Double(lat[0])!
                    DoubleLng = Double(lat[1])!
                }
                
                var DriverCordinate = CLLocationCoordinate2D(latitude: DoubleLat , longitude: DoubleLng)
                
                
                //            var DriverCordinate = CLLocationCoordinate2D(latitude: Double("23.076701577176262")! , longitude: Double("72.51612203357585")!)
                
                DriverCordinate = CLLocationCoordinate2DMake(DriverCordinate.latitude, DriverCordinate.longitude)
                
                if(self.destinationCordinate == nil)
                {
                    self.destinationCordinate = CLLocationCoordinate2DMake(DriverCordinate.latitude, DriverCordinate.longitude)
                }
                
                if self.driverMarker == nil {
                    
                    self.driverMarker = GMSMarker(position: DriverCordinate) // self.originCoordinate
                    
                    self.driverMarker.map = self.mapView
                    var vehicleID = Int()
                    if let vID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? Int {
                        
                        if vID == 0 {
                            vehicleID = 7
                        }
                        else {
                            vehicleID = vID
                        }
                    }
                    else if let sID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? String
                    {
                        
                        if sID == "" {
                            vehicleID = 7
                        }
                        else {
                            vehicleID = Int(sID)!
                        }
                    }
                    
                    self.driverMarker.icon = UIImage(named: "dummyCar")
                    //                    UIImage(named: self.markerCarIconName(modelId: vehicleID))
                }
                
                
                self.moveMent.ARCarMovement(marker: self.driverMarker, oldCoordinate: self.destinationCordinate, newCoordinate: DriverCordinate, mapView: self.mapView, bearing: Float(SingletonClass.sharedInstance.floatBearing))
                
//                let newCordinate = DriverCordinate
                self.driverMarker.position = DriverCordinate// = GMSMarker(position: DriverCordinate) // self.originCoordinate
                self.driverMarker.map = self.mapView
//                var vehicleID = Int()
//                if let vID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? Int {
//
//                    if vID == 0 {
//                        vehicleID = 7
//                    }
//                    else {
//                        vehicleID = vID
//                    }
//                }
//                else if let sID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? String
//                {
//
//                    if sID == "" {
//                        vehicleID = 7
//                    }
//                    else {
//                        vehicleID = Int(sID)!
//                    }
//                }
                self.driverMarker.icon = UIImage(named:"dummyCar")
                //                UIImage(named: self.markerCarIconName(modelId: vehicleID))
                
                self.destinationCordinate = DriverCordinate
                self.MarkerCurrntLocation.isHidden = true
                
                let camera = GMSCameraPosition.camera(withLatitude: DriverCordinate.latitude,longitude: DriverCordinate.longitude, zoom: 17)
                self.mapView.animate(to: camera)
                if (self.arrivedRoutePath != nil && !(GMSGeometryIsLocationOnPathTolerance(self.driverMarker.position, self.arrivedRoutePath!, true, 100)))
                {
                    print("reDraw")
                    self.reRoute(DriverCordinate: DriverCordinate)
                }
                //                .animate(to: camera)
                
                /* ----------------------------------------------------------------------
                 
                 CATransaction.begin()
                 CATransaction.setAnimationDuration(0.5)
                 CATransaction.setValue(Int(2.0), forKey: kCATransactionAnimationDuration)
                 CATransaction.setCompletionBlock({() -> Void in
                 if self.driverMarker != nil {
                 self.driverMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
                 }
                 //New bearing value from backend after car movement is done
                 })
                 
                 UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                 if self.driverMarker != nil {
                 self.driverMarker.position = newCordinate
                 self.driverMarker.map = self.mapView
                 //     self.updatePolyLineToMapFromDriverLocation()
                 }
                 })
                 
                 CATransaction.commit()
                 */ // ----------------------------------------------------------------------
                
            }
        })
    }
    
    func reRoute(DriverCordinate: CLLocationCoordinate2D)
    {
        self.mapView.clear()
        
        if self.driverMarker == nil {
            self.driverMarker = GMSMarker(position: DriverCordinate)
            self.driverMarker.map = self.mapView
            self.driverMarker.icon = UIImage(named: "dummyCar")
        }
            //Rahul
            if(SingletonClass.sharedInstance.dictDriverProfile.count != 0) {
                
                var dropOffCoordinate = CLLocationCoordinate2D()
                var dictDataOfBookingInfo = NSDictionary()
                
               if let dictDataOfBookingInfo2 = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSArray)?.firstObject as? NSDictionary
                {
                   dictDataOfBookingInfo = dictDataOfBookingInfo2
               }
                else if let dictDataOfBookingInfo2 = ((self.aryRequestAcceptedData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "BookingInfo") as? NSDictionary
                {
                    dictDataOfBookingInfo = dictDataOfBookingInfo2

                }
                
                let status = (dictDataOfBookingInfo.object(forKey: "Status") as? String ?? "")

                if ((status == "pending" || status == "accepted") && SingletonClass.sharedInstance.isTripContinue == false)
                {
                    let pickupLat = Double("\(dictDataOfBookingInfo.object(forKey: "PickupLat") as? String ?? "")")
                    let pickupLng = Double("\(dictDataOfBookingInfo.object(forKey: "PickupLng") as? String ?? "")")
                    
                    dropOffCoordinate = CLLocationCoordinate2D(latitude: pickupLat ?? 0.0, longitude: pickupLng ?? 0.0)
                }
                else if (SingletonClass.sharedInstance.isTripContinue == true)
                {
                    let dictDataOfBookingInfo3 = NSMutableDictionary()
                    
                    
                    dictDataOfBookingInfo3["PickupLat"] = dictDataOfBookingInfo["DropOffLat"] as? String ?? ""
                    dictDataOfBookingInfo3["PickupLng"] = dictDataOfBookingInfo["DropOffLon"] as? String ?? ""
                    
                    let pickupLat = Double("\(dictDataOfBookingInfo3.object(forKey: "PickupLat") as? String ?? "")")
                    let pickupLng = Double("\(dictDataOfBookingInfo3.object(forKey: "PickupLng") as? String ?? "")")
                    
                    dropOffCoordinate = CLLocationCoordinate2D(latitude: pickupLat ?? 0.0, longitude: pickupLng ?? 0.0)
                }
      
                
                let PickupLat = self.driverMarker.position.latitude  // Double("\(strLat )")
                let PickupLng = self.driverMarker.position.longitude // Double("\(strLng )")
                
                let DropOffLat = dropOffCoordinate.latitude
                let DropOffLon = dropOffCoordinate.longitude
                
//                let tempLat = Double("\(aryFilterData.first?["PickupLat"]! ?? "0")")
//                let tempLon = Double("\(aryFilterData.first?["PickupLng"]! ?? "0")")
                
                let originalLoc: String = "\(PickupLat ),\(PickupLng)"
                var destiantionLoc: String = "\(DropOffLat ),\(DropOffLon )"
                
                if !SingletonClass.sharedInstance.isTripContinue {
                    destiantionLoc = "\(DropOffLat),\(DropOffLon)"
                }
                
                self.btnCurrentLocation(UIButton())
                
                DispatchQueue.main.async {
                    self.setDirectionLineOnMapForSourceAndDestinationShow(origin: originalLoc, destination: destiantionLoc, completionHandler: nil)
                }
            }
    
        
    }
    
    var driverIDTimer : String!
    var passengerIDTimer : String!
    func sendPassengerIDAndDriverIDToGetLocation(driverID : String , passengerID: String) {
        
        DispatchQueue.global(qos: .background).sync {
            driverIDTimer = driverID
            passengerIDTimer = passengerID
            if timerToGetDriverLocation == nil {
                timerToGetDriverLocation = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(HomeViewController.getDriverLocation), userInfo: nil, repeats: true)
            }
        }
        
    }
    
    func stopTimer() {
        if timerToGetDriverLocation != nil {
            timerToGetDriverLocation.invalidate()
            timerToGetDriverLocation = nil
        }
    }
    
    @objc func getDriverLocation()
    {
        let myJSON = ["PassengerId" : passengerIDTimer,  "DriverId" : driverIDTimer] as [String : Any]
        socket.emit(SocketData.kSendDriverLocationRequestByPassenger , with: [myJSON])
    }
    
    
    func postPickupAndDropLocationForEstimateFare()
    {
        if txtCurrentLocation.text!.count != 0 && txtDestinationLocation.text!.count != 0 && aryOfOnlineCarsIds.count != 0 {
            let driverID = aryOfOnlineCarsIds.compactMap{ $0 }.joined(separator: ",")
            let myJSON = ["PassengerId" : SingletonClass.sharedInstance.strPassengerID,  "PickupLocation" : strPickupLocation ,"PickupLat" :  self.doublePickupLat , "PickupLong" :  self.doublePickupLng, "DropoffLocation" : strDropoffLocation,"DropoffLat" : self.doubleDropOffLat, "DropoffLon" : self.doubleDropOffLng,"Ids" : driverID, "ShareRiding": intShareRide ] as [String : Any]
            
            //        if(strDropoffLocation.count == 0)
            //        {
            //            myJSON = ["PassengerId" : SingletonClass.sharedInstance.strPassengerID,  "PickupLocation" : strPickupLocation ,"PickupLat" :  self.doublePickupLat , "PickupLong" :  self.doublePickupLng, "DropoffLocation" : strPickupLocation,"DropoffLat" : self.doubleDropOffLng, "DropoffLon" : self.doubleDropOffLng,"Ids" : driverID, "ShareRiding": intShareRide] as [String : Any]
            //        }
            socket.emit(SocketData.kSendRequestForGetEstimateFare , with: [myJSON])
        }
    }
    
    func onBookingDetailsAfterCompletedTrip() {
        
        self.socket.on(SocketData.kAdvancedBookingDetails, callback: { (data, ack) in
            print("onBookingDetailsAfterCompletedTrip() is \(data)")
            self.strBookingType = "BookLater"
            SingletonClass.sharedInstance.isTripContinue = false
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            self.aryCompleterTripData = (data as! [[String : Any]])
            
            //            self.viewMainFinalRating.isHidden = false
            
            var bookingId = String()
            if let bookingData = data as? [[String:AnyObject]] {
                
                if let info = bookingData[0]["Info"] as? [[String:AnyObject]] {
                    
                    if let infoId = info[0]["Id"] as? String {
                        bookingId = infoId
                    }
                    else if let infoId = info[0]["Id"] as? Int {
                        bookingId = "\(infoId)"
                    }
                    
                    if SingletonClass.sharedInstance.bookingId != "" {
                        if SingletonClass.sharedInstance.bookingId == bookingId {
                            
                            if (SingletonClass.sharedInstance.passengerTypeOther) {
                                
                                SingletonClass.sharedInstance.passengerTypeOther = false
                                
                                var IsPaid:Bool = false
                                if let paymentStatus = bookingData[0]["Payment"] as? String {
                                    IsPaid = paymentStatus == "NotPaid" ? false : true
                                }
                                self.completeTripInfo(isPaid:IsPaid)
//                                self.completeTripInfo(isPaid: true)
                            }
                            else {
                                var IsPaid:Bool = false
                                if let paymentStatus = bookingData[0]["Payment"] as? String {
                                    IsPaid = paymentStatus == "NotPaid" ? false : true
                                }
                                self.completeTripInfo(isPaid:IsPaid)
//                                self.completeTripInfo(isPaid: true)
                                //                let next = self.storyboard?.instantiateViewController(withIdentifier: "GiveRatingViewController") as! GiveRatingViewController
                                //                next.strBookingType = self.strBookingType
                                //                next.delegate = self
                                //                //            self.presentingViewController?.modalPresentationStyle
                                //                self.present(next, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        })
    }
    
    func CancelBookLaterTripAfterDriverAcceptRequest() {
        
        let myJSON = [SocketDataKeys.kBookingIdNow : SingletonClass.sharedInstance.bookingId] as [String : Any]
        socket.emit(SocketData.kAdvancedBookingCancelTripByPassenger , with: [myJSON])
        
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
        
        clearDataAfteCompleteTrip()
        
    }
    
    func onAdvanceTripInfoBeforeStartTrip() {
        
        self.socket.on(SocketData.kInformPassengerForAdvancedTrip, callback: { (data, ack) in
            print("onAdvanceTripInfoBeforeStartTrip() is \(data)")
            
            var message = String()
            message = "Trip on Hold"
            
            if let resAry = NSArray(array: data) as? NSArray {
                message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
            }
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(OK)
            
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
            
        })
        
    }
    
    func onReceiveNotificationWhenDriverAcceptRequest() {
        
        self.socket.on(SocketData.kAcceptAdvancedBookingRequestNotify, callback: { (data, ack) in
            print("onReceiveNotificationWhenDriverAcceptRequest is \(data)")
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            var bookingId = String()
            
            if let bookingInfoData = (data as! [[String:AnyObject]])[0]["BookingInfo"] as? [[String:AnyObject]] {
                if let bookingInfo = bookingInfoData[0]["Id"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData[0]["Id"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        var message = String()
                        message = "Trip on Hold"
                        
                        if let resAry = NSArray(array: data) as? NSArray {
                            message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                        }
                        
                        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let OK = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                            if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                                (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                            }
                        })
                        //                            UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OK)
                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    var message = String()
                    message = "Trip on Hold"
                    
                    if let resAry = NSArray(array: data) as? NSArray {
                        message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                    }
                    
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                            (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                        }
                    })
                    //                        UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OK)
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
            
        })
        
    }
    
    func onDriverArrviedAtPickupLocation(){
        self.socket.on(SocketData.kArrivedDriverBookNowRequest, callback: { (data, ack) in
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            print("kArrivedDriverBookNowRequest is \(data)")
            
            if let arrivedDriver:[[String:Any]] = data as? [[String:Any]] {
                let driverMsg = arrivedDriver[0]["message"]
                UtilityClass.setCustomAlert(title: "\(appName)", message: driverMsg as! String) { (index, title) in
                    if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                        (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                    }
                }
                self.btnRequest.isHidden = true
                self.btnCancelStartedTrip.isHidden = true
            }
        })
        
    }
    
    func onDriverArrviedBookLaterAtPickupLocation(){
        self.socket.on(SocketData.kArrivedDriverBookLaterRequest, callback: { (data, ack) in
            (UIApplication.shared.delegate as! AppDelegate).playSound(fileName: "new_sms", extensionType: "mp3")
            if let arrivedDriver:[[String:Any]] = data as? [[String:Any]] {
                let driverMsg = arrivedDriver[0]["message"]
                UtilityClass.setCustomAlert(title: "\(appName)", message: driverMsg as! String) { (index, title) in
                    if (UIApplication.shared.delegate as! AppDelegate).audioPlayer != nil {
                        (UIApplication.shared.delegate as! AppDelegate).audioPlayer.stop()
                    }
                }
                self.btnRequest.isHidden = true
                self.btnCancelStartedTrip.isHidden = true
            }
        })
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Auto Suggession on Google Map
    //-------------------------------------------------------------
    
    var BoolCurrentLocation = Bool()
    
    
    @IBAction func txtDestinationLocation(_ sender: UITextField) {
        
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        acController.autocompleteBounds = bounds
        
        BoolCurrentLocation = false
        
        present(acController, animated: true, completion: nil)
        
    }
    
    @IBAction func txtCurrentLocation(_ sender: UITextField) {
        
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        acController.autocompleteBounds = bounds
        
        BoolCurrentLocation = true
        
        present(acController, animated: true, completion: nil)
    }
    
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.MarkerCurrntLocation.isHidden = false
        self.btnDoneForLocationSelected.isHidden = false
        if self.selectedIndexPath != nil {
            self.selectedIndexPath = nil
        }
        
        print(#function + "\(Date())")
        self.isAutoCompleteSelected = true
        
        if BoolCurrentLocation {
            self.strLocationType = currentLocationMarkerText
            self.ConstantViewCarListsHeight.constant = 0
            self.viewCarLists.isHidden = true
            //            self.viewShareRideView.isHidden = true
            if let PlaceName = place.name, let PlaceAddress = place.formattedAddress {
                txtCurrentLocation.text = PlaceName + " " + PlaceAddress
            //                place.formattedAddress
                strPickupLocation = PlaceName + " " + PlaceAddress
            }
            //                place.formattedAddress!
            doublePickupLat = place.coordinate.latitude
            doublePickupLng = place.coordinate.longitude
            
            currentLocationMarker.map = nil
            
            _ = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,longitude: place.coordinate.longitude, zoom: 17.5)
            self.mapView.camera = camera
            mapView.animate(to: camera)
            
        }
        else {
            
            strLocationType = destinationLocationMarkerText
            self.strLocationType = destinationLocationMarkerText
            self.ConstantViewCarListsHeight.constant = 0
            self.viewCarLists.isHidden = true
            //            self.viewShareRideView.isHidden = true
            
            if let PlaceName = place.name, let PlaceAddress = place.formattedAddress {
                txtDestinationLocation.text = PlaceName + " " + PlaceAddress
                strDropoffLocation = PlaceName + " " + PlaceAddress
            }
                
            doubleDropOffLat = place.coordinate.latitude
            doubleDropOffLng = place.coordinate.longitude
            
            destinationLocationMarker.map = nil
            
            _ = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            
            let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,longitude: place.coordinate.longitude, zoom: 17.5)
            self.mapView.camera = camera
            mapView.animate(to: camera)
            
        }
        
        //        if txtCurrentLocation.text!.count != 0 && txtDestinationLocation.text!.count != 0 && aryOfOnlineCarsIds.count != 0 {
        postPickupAndDropLocationForEstimateFare()
        //        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setupBothCurrentAndDestinationMarkerAndPolylineOnMap() {
        
        if  txtCurrentLocation.text != "" && txtDestinationLocation.text != "" {
            
            MarkerCurrntLocation.isHidden = true
            
            var PickupLat = doublePickupLat
            var PickupLng = doublePickupLng
            
            if(SingletonClass.sharedInstance.isTripContinue)
            {
                PickupLat = doubleUpdateNewLat
                PickupLng = doubleUpdateNewLng
            }
            
            
            let DropOffLat = doubleDropOffLat
            let DropOffLon = doubleDropOffLng
            
//            let dummyLatitude = Double(PickupLat) - Double(DropOffLat)
//            let dummyLongitude = Double(PickupLng) - Double(DropOffLon)
            
//            let waypointLatitude = Double(PickupLat) - dummyLatitude
//            let waypointSetLongitude = Double(PickupLng) - dummyLongitude

            let originalLoc: String = "\(PickupLat),\(PickupLng)"
            let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
            
            
            let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: PickupLat, longitude: PickupLng), coordinate: CLLocationCoordinate2D(latitude: DropOffLat, longitude: DropOffLon))
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(100))
            
            self.mapView.animate(with: update)
            
            self.mapView.moveCamera(update)
            
            //commented for Query Limit Issue -
            setDirectionLineOnMapForSourceAndDestinationShow(origin: originalLoc, destination: destiantionLoc, completionHandler: nil)
            //            self.callforMapLine(functionname: #function)
        }
    }
    
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        //print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }
    
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnClearPickupLocation(_ sender: UIButton) {
        //        txtCurrentLocation.text = ""
        clearMap()
        clearCurrentLocation()
    }
    
    @IBAction func btnClearDropOffLocation(_ sender: UIButton) {
        //        txtDestinationLocation.text = ""
        clearMap()
        clearDestinationLocation()
    }
    
    func clearCurrentLocation() {
        
        MarkerCurrntLocation.isHidden = false
        txtCurrentLocation.text = ""
        strPickupLocation = ""
        doublePickupLat = 0
        doublePickupLng = 0
        self.currentLocationMarker.map = nil
        self.destinationLocationMarker.map = nil
        self.strLocationType = self.currentLocationMarkerText
        self.routePolyline.map = nil
        
        self.btnDoneForLocationSelected.isHidden = false
        if self.selectedIndexPath != nil {
            self.selectedIndexPath = nil
        }
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        //        self.viewShareRideView.isHidden = true
    }
    
    func clearDestinationLocation() {
        
        MarkerCurrntLocation.isHidden = false
        txtDestinationLocation.text = ""
        strDropoffLocation = ""
        doubleDropOffLat = 0
        doubleDropOffLng = 0
        self.destinationLocationMarker.map = nil
        self.currentLocationMarker.map = nil
        self.strLocationType = self.destinationLocationMarkerText
        self.routePolyline.map = nil
        self.btnDoneForLocationSelected.isHidden = false
        if self.selectedIndexPath != nil {
            self.selectedIndexPath = nil
        }
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        //        self.viewShareRideView.isHidden = true
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    
    
    
    func updatePolyLineToMapFromDriverLocation() {
        
        var DoubleLat = Double()
        var DoubleLng = Double()
        
        if !SingletonClass.sharedInstance.driverLocation.isEmpty {
            
            if let lat = SingletonClass.sharedInstance.driverLocation["Location"]! as? [Double] {
                DoubleLat = lat[0]
                DoubleLng = lat[1]
            }
            else if let lat = SingletonClass.sharedInstance.driverLocation["Location"]! as? [String] {
                DoubleLat = Double(lat[0])!
                DoubleLng = Double(lat[1])!
            }
                 
            if strPickUpLatitude != "" {
                
                let PickupLat = "\(DoubleLat)"
                let PickupLng = "\(DoubleLng)"
                let DropOffLat = strPickUpLatitude
                let DropOffLon = strPickUpLongitude
              

                let originalLoc: String = "\(PickupLat),\(PickupLng)"
                let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
                
                
                DispatchQueue.global(qos: .background).async {
                    //commented for Query Limit Issue
                    self.getDirectionsChangedPolyLine(origin: originalLoc, destination: destiantionLoc, completionHandler: nil)
                    
                    //                    self.callforMapLine(functionname: #function)
                }
                
                
            }
        }
        //
    }
    
    //-------------------------------------------------------------
    // MARK: - Map Draw Line
    //-------------------------------------------------------------
    
    func setLineData() {
        
        let singletonData = SingletonClass.sharedInstance.dictIsFromPrevious
        
        txtCurrentLocation.text = singletonData.object(forKey: "PickupLocation") as? String
        txtDestinationLocation.text = singletonData.object(forKey: "DropoffLocation") as? String
        
        let DropOffLat = singletonData.object(forKey: "DropOffLat") as! Double
        let DropOffLon = singletonData.object(forKey: "DropOffLon") as! Double
        
        let PickupLat = singletonData.object(forKey: "PickupLat") as! Double
        let PickupLng = singletonData.object(forKey: "PickupLng")as! Double
        
//        let dummyLatitude: Double = Double(PickupLat) - Double(DropOffLat)
//        let dummyLongitude: Double = Double(PickupLng) - Double(DropOffLon)
        
//        let waypointLatitude = PickupLat - dummyLatitude
//        let waypointSetLongitude = PickupLng - dummyLongitude
        
        let originalLoc: String = "\(PickupLat),\(PickupLng)"
        let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
        
        //commented for Query Limit Issue -
        self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, completionHandler: nil)
        //        self.callforMapLine(functionname: #function)
    }
    
    func clearMap() {
        
        self.mapView.clear()
        self.driverMarker = nil
        self.mapView.delegate = self
        
        self.destinationLocationMarker.map = nil
        
        //        self.mapView.stopRendering()
        //        self.mapView = nil
    }
    
    
    
    
    // ------------------------------------------------------------
    func getDirectionsSeconMethod(origin: String!, destination: String!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?)
    {
        
        clearMap()
        
        MarkerCurrntLocation.isHidden = true
        
        UtilityClass.showACProgressHUD()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + getGoogleApiKey(functionName: "\(#function)", URL: "", LineNumber: "\(#line)")

                    // .addingPercentEscapes(using: String.Encoding.utf8)!
                    
                    print("directionsURLString: \(directionsURLString) line number \(#line)")
                    
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    
                    // .addingPercentEscapes(using: String.Encoding.utf8)!
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        do{
                            let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                            
                            let status = dictionary["status"] as! String
                            
                            if status == "OK" {
                                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                
                                let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                
                                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                
                                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                
                                self.locationManager.startUpdatingLocation()
                                
                                let originAddress = legs[0]["start_address"] as! String
                                let destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                //                                if(SingletonClass.sharedInstance.isTripContinue)
                                //                                {
                                if self.driverMarker == nil {
                                    
                                    self.driverMarker = GMSMarker(position: self.originCoordinate) // self.originCoordinate
                                    self.driverMarker.map = self.mapView
                                    var vehicleID = Int()
                                    //                                    var vehicleID = Int()
                                    if let vID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? Int {
                                        
                                        if vID == 0 {
                                            vehicleID = 7
                                        }
                                        else {
                                            vehicleID = vID
                                        }
                                    }
                                    else if let sID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? String
                                    {
                                        
                                        if sID == "" {
                                            vehicleID = 7
                                        }
                                        else {
                                            vehicleID = Int(sID)!
                                        }
                                    }
                                    
                                    self.driverMarker.icon = UIImage(named: "dummyCar")
                                    //                                        UIImage(named: self.markerCarIconName(modelId: vehicleID))
                                    
                                    self.driverMarker.title = originAddress
                                }
                                
                                let destinationMarker = GMSMarker(position: self.destinationCoordinate)// self.destinationCoordinate  // self.destinationCoordinate
                                destinationMarker.map = self.mapView
                                destinationMarker.icon = UIImage(named: "Destination_flag")
                                
                                //                                GMSMarker.markerImage(with: UIColor.red)
                                destinationMarker.title = destinationAddress
                                
                                
                                var aryDistance = [String]()
                                var finalDistance = Double()
                                
                                
                                for i in 0..<legs.count
                                {
                                    let legsData = legs[i]
                                    let distanceKey = legsData["distance"] as! Dictionary<String, AnyObject>
                                    let distance = distanceKey["text"] as! String
                                    //                                    print(distance)
                                    
                                    let stringDistance = distance.components(separatedBy: " ")
                                    //                                    print(stringDistance)
                                    
                                    if stringDistance[1] == "m"
                                    {
                                        finalDistance += Double(stringDistance[0])! / 1000
                                    }
                                    else
                                    {
                                        finalDistance += Double(stringDistance[0].replacingOccurrences(of: ",", with: ""))!
                                    }
                                    
                                    aryDistance.append(distance)
                                    
                                }
                                
                                if finalDistance == 0 {
                                    
                                }
                                else
                                {
                                    self.sumOfFinalDistance = finalDistance
                                    
                                    
                                }
                                
                                let route = self.overviewPolyline["points"] as! String
                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                let routePolyline = GMSPolyline(path: path)
                                routePolyline.map = self.mapView
                                routePolyline.strokeColor = themeYellowColor
                                routePolyline.strokeWidth = 3.0
                                self.arrivedRoutePath = GMSPath(fromEncodedPath: route)!
                                UtilityClass.hideACProgressHUD()
                                
                                //                                UtilityClass.showAlert("", message: "Line Drawn", vc: self)
                                //  print("Line Drawn")
                            }
                            else {
                                UtilityClass.hideACProgressHUD()
                                print("status")
                                
                                print("OVER_QUERY_LIMIT")
                            }
                        }
                        catch {
                            print("catch")
                            
                            
                            UtilityClass.hideACProgressHUD()
                            
                            UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, please restart app") { (index, title) in
                            }
                            // completionHandler(status: "", success: false)
                        }
                    })
                }
                else {
                    print("Destination is nil.")
                    
                    UtilityClass.hideACProgressHUD()
                    
                    UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location Destination, please restart app") { (index, title) in
                    }
                    //completionHandler(status: "Destination is nil.", success: false)
                }
            }
            else {
                print("Origin is nil")
                
                UtilityClass.hideACProgressHUD()
                
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location Origin, please restart app") { (index, title) in
                }
                //completionHandler(status: "Origin is nil", success: false)
            }
        }
    }
    
    var demoPolyline = GMSPolyline()
    //    var demoPolylineOLD = GMSPolyline()
    
    func getDirectionsChangedPolyLine(origin: String!, destination: String!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?)
    {
        
        //        clearMap()
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + getGoogleApiKey(functionName: "\(#function)", URL: "", LineNumber: "\(#line)")
                    
                    print("directionsURLString: \(directionsURLString)")
                    
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        do{
                            let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                            
                            let status = dictionary["status"] as! String
                            if status == "OK" {
                                
                                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                
                                let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                self.locationManager.startUpdatingLocation()
                                
                                let route = self.overviewPolyline["points"] as! String
                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                self.arrivedRoutePath = GMSPath(fromEncodedPath: route)!

                              
                                DispatchQueue.main.async {
                                    
                                    self.demoPolylineOLD = self.demoPolyline
                                    self.demoPolylineOLD.strokeColor = themeYellowColor
                                    self.demoPolylineOLD.strokeWidth = 3.0
                                    self.demoPolylineOLD.map = self.mapView
                                    self.demoPolyline.map = nil
                                    
                                    self.demoPolyline = GMSPolyline(path: path)
                                    self.demoPolyline.map = self.mapView
                                    self.demoPolyline.strokeColor = themeYellowColor
                                    self.demoPolyline.strokeWidth = 3.0
                                    self.demoPolylineOLD.map = nil
                                    
                                }
                                
                                
                                
                                //                                if GMSGeometryIsLocationOnPath(self.destinationCoordinate, path, true) {
                                //                                    print("GMSGeometryIsLocationOnPath")
                                //                                } else {
                                //                                    print("Else")
                                //                                }
                                
                                
                                //                                UIView.animate(withDuration: 3.0, delay: 0, options: .curveLinear, animations: {
                                //                                    self.demoPolyline = GMSPolyline(path: path)
                                //                                    self.demoPolyline.map = self.mapView
                                //                                    self.demoPolyline.strokeColor = themeYellowColor
                                //                                    self.demoPolyline.strokeWidth = 3.0
                                //                                    self.demoPolylineOLD.map = nil
                                //                                }, completion: { (status) in
                                //
                                //                                })
                                
                                
                                print("Line Drawn")
                                
                                
                                UtilityClass.hideACProgressHUD()
                            } else {
                                UtilityClass.hideACProgressHUD()
                            }
                        } catch {
                            UtilityClass.hideACProgressHUD()
                        }
                    })
                } else {
                    UtilityClass.hideACProgressHUD()
                }
            } else {
                UtilityClass.hideACProgressHUD()
            }
        }
    }
    
    
    
   /* func changePolyLine(origin: String!, destination: String!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?)
    {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + getGoogleApiKey(functionName: "\(#function)", URL: "", LineNumber: "\(#line)")
                print("directionsURLString: \(directionsURLString)")
                directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                let directionsURL = NSURL(string: directionsURLString)
                DispatchQueue.main.async( execute: { () -> Void in
                    let directionsData = NSData(contentsOf: directionsURL! as URL)
                    do{
                        let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            
                            self.locationManager.startUpdatingLocation()
                            
                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                            
                            let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                            
                            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                            self.dummyOriginCordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                            
                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                            self.dummyDestinationCordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                            
                            self.locationManager.startUpdatingLocation()
                            
                            if self.dummyOriginCordinateMarker == nil {
                                self.dummyOriginCordinateMarker = GMSMarker(position: self.dummyOriginCordinate)// self.destinationCoordinate  // self.destinationCoordinate
                                self.dummyOriginCordinateMarker.map = self.mapView
                                self.dummyOriginCordinateMarker.icon = GMSMarker.markerImage(with: UIColor.green)
                                //                            destinationMarker.title = destinationAddres
                                
                                //                                let route = self.overviewPolyline["points"] as! String
                                //                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                //                                self.routePolyline = GMSPolyline(path: path)
                                //                                self.routePolyline.map = self.mapView
                                //                                self.routePolyline.strokeColor = UIColor.blue // themeYellowColor
                                //                                self.routePolyline.strokeWidth = 3.0
                                //                                self.demoPolylineOLD.map = nil
                            }
                            
                            if self.dummyDestinationCordinateMarker == nil {
                                self.dummyDestinationCordinateMarker = GMSMarker(position: self.dummyDestinationCordinate)// self.destinationCoordinate  // self.destinationCoordinate
                                self.dummyDestinationCordinateMarker.map = self.mapView
                                self.dummyDestinationCordinateMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
                            }
                            
                            //                            if self.routePolyline.map == nil {
                            //                                self.demoPolylineOLD = self.routePolyline
                            //                                self.demoPolylineOLD.map = self.mapView
                            //                                self.demoPolylineOLD.strokeColor = themeYellowColor
                            //                                self.demoPolylineOLD.strokeWidth = 5.0
                            //                               self.routePolyline.map = nil
                            
                            
                            
                            //                                let route = self.overviewPolyline["points"] as! String
                            //                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                            //                                self.routePolyline = GMSPolyline(path: path)
                            //                                self.routePolyline.map = self.mapView
                            //                                self.routePolyline.strokeColor = UIColor.blue // themeYellowColor
                            //                                self.routePolyline.strokeWidth = 3.0
                            //                                self.demoPolylineOLD.map = nil
                            
                            
                            // ----------------------------------------------------------------------
                            //                            self.demoPolylineOLD = self.routePolyline
                            //                            self.demoPolylineOLD.map = self.mapView
                            //
                            //                            self.demoPolylineOLD.strokeColor = UIColor.green
                            //                            self.demoPolylineOLD.strokeWidth = 3.0
                            //                            self.routePolyline.map = nil
                            
                            let route = self.overviewPolyline["points"] as! String
                            let path: GMSPath = GMSPath(fromEncodedPath: route)!
                            
                            self.routePolyline = GMSPolyline(path: path)
                            self.routePolyline.map = self.mapView
                            self.routePolyline.strokeColor = UIColor.blue
                            self.routePolyline.strokeWidth = 3.0
                            self.demoPolylineOLD.map = nil
                            // ----------------------------------------------------------------------
                            
                            
                            print("Line Drawn")
                            
                        }
                        else {
                            print("status")
                            
                            //                            self.changePolyLine(origin: origin, destination: destination, waypoints: waypoints, travelMode: nil, completionHandler: nil)
                            print("changePolyLine OVER_QUERY_LIMIT")
                        }
                    }
                    catch {
                        print("catch")
                        
                        
                        UtilityClass.hideACProgressHUD()
                        
                        UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, please restart app") { (index, title) in
                            //                            self.changePolyLine(origin: origin, destination: destination, waypoints: waypoints, travelMode: nil, completionHandler: nil)
                        }
                        // completionHandler(status: "", success: false)
                    }
                })
            }
            else {
                print("Destination is nil.")
                
                UtilityClass.hideACProgressHUD()
                
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location Destination, please restart app") { (index, title) in
                    //                    self.changePolyLine(origin: origin, destination: destination, waypoints: waypoints, travelMode: nil, completionHandler: nil)
                }
                //completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            print("Origin is nil")
            
            UtilityClass.hideACProgressHUD()
            
            UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location Origin, please restart app") { (index, title) in
                //                self.changePolyLine(origin: origin, destination: destination, waypoints: waypoints, travelMode: nil, completionHandler: nil)
            }
            //completionHandler(status: "Origin is nil", success: false)
        }
    }
    func getDirectionsAcceptRequest(origin: String!, destination: String!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?)
    {
        
        clearMap()
        
        MarkerCurrntLocation.isHidden = true
        
        UtilityClass.showACProgressHUD()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + getGoogleApiKey(functionName: "\(#function)", URL: "", LineNumber: "\(#line)")
                    
              
                    
                    // .addingPercentEscapes(using: String.Encoding.utf8)!
                    
                     print("directionsURLString: \(directionsURLString)")
                    
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    
                    // .addingPercentEscapes(using: String.Encoding.utf8)!
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        do{
                            let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>//cresh
                            
                            let status = dictionary["status"] as! String
                            
                            if status == "OK" {
                                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                
                                let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                
                                
                                
                                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                
                                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                
                                self.locationManager.startUpdatingLocation()
                                
                                let originAddress = legs[0]["start_address"] as! String
                                let destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                if(SingletonClass.sharedInstance.isTripContinue)
                                {
                                    if self.driverMarker == nil {
                                        
                                        self.driverMarker = GMSMarker(position: self.destinationCoordinate) // self.originCoordinate
                                        self.driverMarker.map = self.mapView
                                        var vehicleID = Int()
                                        //                                    var vehicleID = Int()
                                        if let vID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? Int {
                                            
                                            if vID == 0 {
                                                vehicleID = 7
                                            }
                                            else {
                                                vehicleID = vID
                                            }
                                        }
                                        else if let sID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? String
                                        {
                                            
                                            if sID == "" {
                                                vehicleID = 7
                                            }
                                            else {
                                                vehicleID = Int(sID)!
                                            }
                                        }
                                        
                                        self.driverMarker.icon = UIImage(named: "dummyCar")
                                        //                                            UIImage(named: self.markerCarIconName(modelId: vehicleID))
                                        
                                        self.driverMarker.title = originAddress
                                    }
                                    
                                }
                                
                                let destinationMarker = GMSMarker(position: self.originCoordinate)// self.destinationCoordinate  // self.destinationCoordinate
                                destinationMarker.map = self.mapView
                                destinationMarker.icon = UIImage(named: "Destination_flag")
                                //                                    GMSMarker.markerImage(with: UIColor.red)
                                destinationMarker.title = destinationAddress
                                
                                
                                var aryDistance = [String]()
                                var finalDistance = Double()
                                
                                
                                for i in 0..<legs.count
                                {
                                    let legsData = legs[i]
                                    let distanceKey = legsData["distance"] as! Dictionary<String, AnyObject>
                                    let distance = distanceKey["text"] as! String
                                    //                                    print(distance)
                                    
                                    let stringDistance = distance.components(separatedBy: " ")
                                    //                                    print(stringDistance)
                                    
                                    if stringDistance[1] == "m"
                                    {
                                        finalDistance += Double(stringDistance[0])! / 1000
                                    }
                                    else
                                    {
                                        finalDistance += Double(stringDistance[0].replacingOccurrences(of: ",", with: ""))!
                                    }
                                    
                                    aryDistance.append(distance)
                                }
                                
                                if finalDistance == 0 {
                                }
                                else {
                                    self.sumOfFinalDistance = finalDistance
                                }
                                
                                //                                let route = self.overviewPolyline["points"] as! String
                                //                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                //                                let routePolyline = GMSPolyline(path: path)
                                //                                routePolyline.map = self.mapView
                                //                                routePolyline.strokeColor = themeYellowColor
                                //                                routePolyline.strokeWidth = 3.0
                                
                                UtilityClass.hideACProgressHUD()
                                
                                //                                UtilityClass.showAlert("", message: "Line Drawn", vc: self)
                                
                                print("Line Drawn")
                                
                            }
                            else {
                                print("status")
                                UtilityClass.hideACProgressHUD()
                                //                                self.getDirectionsAcceptRequest(origin: origin, destination: destination, waypoints: waypoints, travelMode: nil, completionHandler: nil)
                                print("OVER_QUERY_LIMIT")
                            }
                        }
                        catch {
                            print("catch")
                            
                            
                            UtilityClass.hideACProgressHUD()
                            
                            UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, please restart app") { (index, title) in
                            }
                            // completionHandler(status: "", success: false)
                        }
                    })
                }
                else {
                    print("Destination is nil.")
                    
                    UtilityClass.hideACProgressHUD()
                    
                    UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get Destination location, please restart app") { (index, title) in
                    }
                    //completionHandler(status: "Destination is nil.", success: false)
                }
            }
            else {
                print("Origin is nil")
                
                UtilityClass.hideACProgressHUD()
                
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get  Origin location, please restart app") { (index, title) in
                }
                //completionHandler(status: "Origin is nil", success: false)
            }
        }
    }*/
    
    
    func setDirectionLineOnMapForSourceAndDestinationShow(origin: String!, destination: String!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?)
    {
        //        clearMap()
        //        UtilityClass.showACProgressHUD()
        //
        //        self.routePolyline.map = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + getGoogleApiKey(functionName: "\(#function)", URL: "", LineNumber: "\(#line)")
                    print("directionsURLString: \(directionsURLString)")
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        guard let directionsData = NSData(contentsOf: directionsURL! as URL) else {return}
                        do{
                            let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                            
                            if let status = dictionary["status"] as? String {
                                
                                if status == "OK" {
                                    self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                    self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                    
                                    let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                    
                                    let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                    self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                    
                                    let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                    self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                    
                                    self.locationManager.startUpdatingLocation()
                                    
                                    //                                if SingletonClass.sharedInstance.isTripContinue {
                                    
                                    
                                    // Set currentLocationMarker
                                    self.currentLocationMarker = GMSMarker(position: self.originCoordinate) // destinationCoordinate
                                    self.currentLocationMarker.map = self.mapView
                                    self.currentLocationMarker.snippet = self.currentLocationMarkerText
                                    self.currentLocationMarker.icon = UIImage(named: "iconCurrentLocation")
                                    //                                self.currentLocationMarker.isDraggable = true
                                    
                                    // Set destinationLocationMarker
                                    self.destinationLocationMarker = GMSMarker(position: self.destinationCoordinate) // originCoordinate
                                    self.destinationLocationMarker.map = self.mapView
                                    self.destinationLocationMarker.snippet = self.destinationLocationMarkerText
                                    self.destinationLocationMarker.icon = UIImage(named: "Destination_flag")
                                    
                                    //                                     }
                                    
                                    let route = self.overviewPolyline["points"] as! String
                                    let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                    self.routePolyline = GMSPolyline(path: path)
                                    self.routePolyline.map = self.mapView
                                    self.routePolyline.strokeColor = themeYellowColor
                                    self.routePolyline.strokeWidth = 3.0
                                    self.arrivedRoutePath = GMSPath(fromEncodedPath: route)!

                                    
                                    UtilityClass.hideACProgressHUD()
                                    
                                    print("Line Drawn")
                                    
                                }
                                else {
                                    print("status")
                                    UtilityClass.hideACProgressHUD()
                                    //completionHandler(status: status, success: false)
                                    
                                    print("OVER_QUERY_LIMIT")
                                }
                            }
                            else {
                                print("OVER_QUERY_LIMIT")
                                UtilityClass.hideACProgressHUD()
                            }
                        }
                        catch {
                            print("catch")
                            
                            
                            UtilityClass.hideACProgressHUD()
                            
                            UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, please restart app") { (index, title) in
                            }
                            // completionHandler(status: "", success: false)
                        }
                    })
                }
                else {
                    print("Destination is nil.")
                    
                    UtilityClass.hideACProgressHUD()
                    
                    UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get Destination location, please restart app") { (index, title) in
                    }
                    //completionHandler(status: "Destination is nil.", success: false)
                }
            }
            else {
                print("Origin is nil")
                
                UtilityClass.hideACProgressHUD()
                
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get  Origin location, please restart app") { (index, title) in
                }
                //completionHandler(status: "Origin is nil", success: false)
            }
        }
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice Current Booking Methods
    //-------------------------------------------------------------
    
    var dictCurrentBookingInfoData = NSDictionary()
    var dictCurrentDriverInfoData = NSDictionary()
    var aryCurrentBookingData = NSMutableArray()
    var checkBookingType = String()
    
    var bookingIDNow = String()
    var advanceBookingID = String()
    var passengerId = String()
    
    var strBookingType = String()
    
    func webServiceOfCheckPromoCode() {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        var dictData = [String:AnyObject]()
        if self.btnSelectPromocode.currentTitle != "Select Promocode" {
            if let Promodetail:String = self.btnSelectPromocode.currentTitle {
                let promocode = Promodetail.components(separatedBy: " ")[0]
                dictData["PromoCode"] = promocode as AnyObject
            }
        }
        //        dictData["PromoCode"] = self.btnSelectPromocode.currentTitle as AnyObject
        webserviceForCheckPromocode(dictData as AnyObject) { (result, status) in
            if (status) {
                self.startProcessToSendRequest()
            } else {
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
    
    
    func webserviceOfCurrentBooking() {
        
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        
        if let Token = UserDefaults.standard.object(forKey: "Token") as? String {
            SingletonClass.sharedInstance.deviceToken = Token
            print("SingletonClass.sharedInstance.deviceToken : \(SingletonClass.sharedInstance.deviceToken)")
        }
        
        let param = SingletonClass.sharedInstance.strPassengerID + "/" + SingletonClass.sharedInstance.deviceToken
        
        webserviceForCurrentTrip(param as AnyObject) { (result, status) in
            
            
            
            if (status) {
                // print(result)
                
                self.clearMap()
                
                let resultData = (result as! NSDictionary)
                
                SingletonClass.sharedInstance.strCurrentBalance = (resultData.object(forKey: "balance") as AnyObject).doubleValue
                
                SingletonClass.sharedInstance.passengerRating = (resultData.value(forKey: "rating") as! NSString).floatValue
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rating"), object: nil)
                
                self.aryCurrentBookingData.add(resultData)
                self.aryRequestAcceptedData = self.aryCurrentBookingData
                
                let bookingType = (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "BookingType") as! String
                
                if bookingType != "" {
                    
                    self.MarkerCurrntLocation.isHidden = true
                    
                    if bookingType == "BookNow" {
                        
                        self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
                        let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                        
                        self.strBookingType = bookingType
                        
                        if statusOfRequest == "accepted" {
                            
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            self.bookingTypeIsBookNowAndAccepted()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            SingletonClass.sharedInstance.isTripContinue = true
                            
                            self.bookingTypeIsBookNowAndTraveling()
                        }
                        
                    }
                    else if bookingType == "BookLater" {
                        
                        self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
                        let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                        
                        self.strBookingType = bookingType
                        
                        if statusOfRequest == "accepted" {
                            
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            self.bookingTypeIsBookNowAndAccepted()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            SingletonClass.sharedInstance.isTripContinue = true
                            
                            self.bookingTypeIsBookNowAndTraveling()
                        }
                    }
                    
                    NotificationCenter.default.post(name: NotificationForAddNewBooingOnSideMenu, object: nil)
                    
                }
            }
            else {
                
                let resultData = (result as! NSDictionary)
                SingletonClass.sharedInstance.strCurrentBalance = (resultData.object(forKey: "balance") as AnyObject).doubleValue
                SingletonClass.sharedInstance.passengerRating = (resultData.value(forKey: "rating") as! NSString).floatValue
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rating"), object: nil)
                
            }
        }
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods Running TripTrack
    //-------------------------------------------------------------
    
    @objc func webserviceOfRunningTripTrack() {
        if Connectivity.isConnectedToInternet() == false {
            
                        UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
            }
            return
        }
        
        webserviceForTrackRunningTrip(SingletonClass.sharedInstance.bookingId as AnyObject) { (result, status) in
            
            if (status) {
                // print(result)
                
                self.clearMap()
                
                let resultData = (result as! NSDictionary)
                
                //                SingletonClass.sharedInstance.passengerRating = resultData.object(forKey: "rating") as! String
                //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rating"), object: nil)
                self.aryCurrentBookingData.removeAllObjects()
                self.aryCurrentBookingData.add(resultData)
                self.aryRequestAcceptedData = self.aryCurrentBookingData
                
                let bookingType = (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "BookingType") as! String
                
                if bookingType != "" {
                    
                    self.MarkerCurrntLocation.isHidden = true
                    
                    if bookingType == "BookNow" {
                        
                        self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
                        let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                        
                        self.strBookingType = bookingType
                        
                        if statusOfRequest == "accepted" {
                            
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            self.bookingTypeIsBookNowAndAccepted()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            SingletonClass.sharedInstance.isTripContinue = true
                            
                            self.bookingTypeIsBookNowAndTraveling()
                        }
                        
                    }
                    else if bookingType == "BookLater" {
                        
                        self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
                        let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                        
                        self.strBookingType = bookingType
                        
                        if statusOfRequest == "accepted" {
                            
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            self.bookingTypeIsBookNowAndAccepted()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            SingletonClass.sharedInstance.isTripContinue = true
                            
                            self.bookingTypeIsBookNowAndTraveling()
                        }
                    }
                }
            }
            else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OK)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    // ----------------------------------------------------------------------
    
    // ----------------------------------------------------------------------
    // Book Now Accept Request
    // ----------------------------------------------------------------------
    func bookingTypeIsBookNowAndAccepted() {
        
        
        if let vehicleModelId = (((aryCurrentBookingData.object(at: 0) as? NSDictionary)?.object(forKey: "CarInfo") as? NSArray)?.object(at: 0) as? NSDictionary)?.object(forKey: "VehicleModel") as? String {
            
            for i in 0..<self.arrTotalNumberOfCars.count {
                
                let indexOfCar = self.arrTotalNumberOfCars.object(at: i) as! NSDictionary
                if vehicleModelId == indexOfCar.object(forKey: "Id") as! String {
                    strSelectedCarMarkerIcon = markertIconName(carType: indexOfCar.object(forKey: "Name") as! String)
                }
            }
        }
        
        //        SingletonClass.sharedInstance.isTripContinue = true
        self.DriverInfoAndSetToMap(driverData: NSArray(array: aryCurrentBookingData))
        
    }
    
    func bookingTypeIsBookNowAndTraveling() {
        
        //        clearMap()
        
        if let vehicleModelId = (((aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSArray).object(at: 0) as! NSDictionary).object(forKey: "VehicleModel") as? String {
            
            for i in 0..<self.arrTotalNumberOfCars.count {
                
                let indexOfCar = self.arrTotalNumberOfCars.object(at: i) as! NSDictionary
                if vehicleModelId == indexOfCar.object(forKey: "Id") as! String {
                    strSelectedCarMarkerIcon = markertIconName(carType: indexOfCar.object(forKey: "Name") as! String)
                }
            }
        }
        
        self.methodAfterStartTrip(tripData: NSArray(array: aryCurrentBookingData))
    }
    
    func markertIconName(carType: String) -> String {
        
        switch carType {
        case "First Class":
            return "iconFirstClass"
        case "Business Class":
            return "iconBusinessClass"
        case "Economy":
            return "iconEconomy"
        case "Taxi":
            return "iconTaxi"
        case "LUX-VAN":
            return "iconLuxVan"
        case "Disability":
            return "iconDisability"
        default:
            return "dummyCar"
        }
        
    }
    
    //    func markerCarIconName(modelId: Int) -> String {
    //
    //        var CarModel = String()
    //
    //        switch modelId {
    //        case 1:
    //            CarModel = "imgBusinessClass"
    //            return CarModel
    //        case 2:
    //            CarModel = "imgMIni"
    //            return CarModel
    //        case 3:
    //            CarModel = "imgVan"
    //            return CarModel
    //        case 4:
    //            CarModel = "imgNano"
    //            return CarModel
    //        case 5:
    //            CarModel = "imgTukTuk"
    //            return CarModel
    //        case 6:
    //            CarModel = "imgBreakdown"
    //            return CarModel
    //        default:
    //            CarModel = "dummyCar"
    //            return CarModel
    //        }
    //
    //    }
    
    func markerCarIconName(modelId: Int) -> String {
        
        var CarModel = String()
        
        switch modelId {
        case 1:
            CarModel = "imgBusinessClass"
            return CarModel
        case 2:
            CarModel = "imgMIni"
            return CarModel
        case 3:
            CarModel = "imgVan"
            return CarModel
        case 4:
            CarModel = "imgNano"
            return CarModel
        case 5:
            CarModel = "imgTukTuk"
            return CarModel
        case 6:
            CarModel = "imgBreakdown"
            return CarModel
        default:
            CarModel = "dummyCar"
            return CarModel
        }
        
    }
    
    func sortCarListFirstTime() {
        
        let sortedArray = (aryTempOnlineCars as NSArray).sortedArray(using: [NSSortDescriptor(key: "Sort", ascending: true)]) as! [[String:AnyObject]]
        arrNumberOfOnlineCars = NSMutableArray(array: sortedArray)
        self.collectionViewCars.reloadData()
    }
    
    //-------------------------------------------------------------
    // MARK: - ARCar Movement Delegate Method
    //-------------------------------------------------------------
    func ARCarMovementMoved(_ Marker: GMSMarker) {
        driverMarker = Marker
        driverMarker.map = mapView
    }
    
    var destinationCordinate: CLLocationCoordinate2D!
    
    func didSelectCard(dictData: [String : AnyObject]) {
        print(dictData)
        CardID = dictData["Id"] as! String
        let CardType = dictData["Type"] as! String
        let CardNumber = dictData["CardNum2"] as! String
        self.lblCardTitle.text = "\(CardType) \(CardNumber)"
        self.SetPaymentOption(SelectionIndex: 0)
    }
    
    
    
    //    func callforMapLine(functionname:String) {
    //        print("Call for map line" + functionname)
    //    }
    
}

extension HomeViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Additional Information" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Additional Information"
            textView.textColor = UIColor.lightGray
        }
    }
}


// Delegates to handle events for the location manager.
extension HomeViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        //        print("Location: \(location)")
        
        defaultLocation = location
        
        SingletonClass.sharedInstance.currentLatitude = "\(location.coordinate.latitude)"
        SingletonClass.sharedInstance.currentLongitude = "\(location.coordinate.longitude)"
        
        if(SingletonClass.sharedInstance.isFirstTimeDidupdateLocation)
        {
            SingletonClass.sharedInstance.isFirstTimeDidupdateLocation = false
        }
        
        if SingletonClass.sharedInstance.isTripContinue {
//            let currentCordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            
            if(destinationCordinate == nil)
            {
                destinationCordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            }
            
            
            if driverMarker == nil {
                driverMarker = GMSMarker(position: destinationCordinate)
                
                var vehicleID = Int()
                //                                    var vehicleID = Int()
                if SingletonClass.sharedInstance.dictCarInfo.count != 0 {
                    if let vID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? Int {
                        
                        if vID == 0 {
                            vehicleID = 7
                        }
                        else {
                            vehicleID = vID
                        }
                    }
                    else if let sID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? String
                    {
                        
                        if sID == "" {
                            vehicleID = 7
                        }
                        else {
                            vehicleID = Int(sID)!
                        }
                    }
                    self.driverMarker.icon = UIImage(named: "dummyCar")
                    //                        UIImage(named: self.markerCarIconName(modelId: vehicleID))
                    
                }
                else {
                    driverMarker.icon = UIImage(named: "iconActiveDriver")
                }
                
                
                driverMarker.map = mapView
            }
            
            //            self.moveMent.ARCarMovement(marker: driverMarker, oldCoordinate: destinationCordinate, newCoordinate: currentCordinate, mapView: mapView, bearing: Float(SingletonClass.sharedInstance.floatBearing))
//            destinationCordinate = currentCordinate
            self.MarkerCurrntLocation.isHidden = true
        }
        
        
        if mapView.isHidden {
            mapView.isHidden = false
            self.getPlaceFromLatLong()
            self.socketMethods()
            
            mapView.delegate = self
            
//            _ = CLLocationCoordinate2D(latitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude)
//            _
            MarkerCurrntLocation.isHidden = false
            
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude, zoom: 17)
            mapView.animate(to: camera)
            
            
        }
        
        let latitude: CLLocationDegrees = (location.coordinate.latitude)
        let longitude: CLLocationDegrees = (location.coordinate.longitude)
        
        let locations = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
        geocoder.reverseGeocodeLocation(locations, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                return
            }else if let _ = placemarks?.first?.country,
                let city = (placemarks?.first?.addressDictionary as! [String : AnyObject])["City"] {
                
                SingletonClass.sharedInstance.strCurrentCity = city as! String
            }
            else {
            }
        })
        
        //        updatePolyLineToMapFromDriverLocation()
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
        //            mapView.isHidden = true
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways:
            //            mapView.isHidden = false
            locationManager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            //            mapView.isHidden = false
            locationManager.startUpdatingLocation()
            
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        return touch.view == gestureRecognizer.view
    }
    
}


extension UILabel {
    func setSizeFont (sizeFont: Double) {
        self.font =  UIFont(name: self.font.fontName, size: CGFloat(sizeFont))!
        self.sizeToFit()
    }
}

