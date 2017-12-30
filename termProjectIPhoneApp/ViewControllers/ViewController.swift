//
//  ViewController.swift
//  termProjectIPhoneApp
//
//  Created by Davinder on 2017-12-28.
//  Copyright © 2017 Davinder. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController , CLLocationManagerDelegate{
    
    var tempToPost : Double? = nil
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var cityDeets = GetData()
    
    var latitude : Double? = nil
    var longitude : Double? = nil
    
    var tempVal : String? = "loading..."
    
    var cityName : String?
    var countryName : String?
    
    var feelsLikeInt : Int?
    
    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var locationLbl: UILabel!
    
    @IBOutlet weak var tempLbl: UILabel!
    
    @IBOutlet weak var feelsLikeSeg: UISegmentedControl!
    
    
    @IBAction func feelsLikeAction(_ sender: UISegmentedControl) {
        
        switch feelsLikeSeg.selectedSegmentIndex
        {
        case 0:
            feelsLikeInt = 0
        case 1:
            feelsLikeInt = 1
        case 2:
            feelsLikeInt = 2
        default:
            feelsLikeInt = 0
            
        }
        print (" \(feelsLikeInt!)" )
    }
    
    
    @IBOutlet weak var statusTxt: UITextField!
    
    let locValue: CLLocationCoordinate2D? = nil
    
    @IBAction func postUpdate(_ sender: Any) {
        
        //validate all entries and that fetched data has arrived
        
        if ((firstName.text?.isEmpty)! || (lastName.text?.isEmpty)! ){
            
            let alert = UIAlertController(title: "Alert", message: "Please enter your first name and last name!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        if (locationLbl.text == "loading..." || tempLbl.text == "loading..."){
            
            let alert = UIAlertController(title: "Alert", message: "Please wait for weather data to be fetched", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        if (statusTxt.text?.isEmpty)!{
            
            let alert = UIAlertController(title: "Alert", message: "Please share a status update about this weather!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }
    
        //everything checks out, prepare post request
        var fname = firstName.text
        var lname = lastName.text
        var loc = locationLbl.text
        var temp = self.tempToPost
        var realTemp = feelsLikeSeg.selectedSegmentIndex
        var statusUpdate = statusTxt.text
        
        cityDeets.postToBrian(fname: fname!, lname: lname!, loc: loc!, temp: temp!, realTemp: realTemp, statusUpdate: statusUpdate!)
        
        
        
        
    }
    
    var locationManager = CLLocationManager()
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)

        
        activityIndicator.startAnimating()
        
        //pull in location coordinates and determine city
        // Ask for Authorisation from the User.
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
        
        
        
        // make the weather api request with those coordinates
        // set temperature value to label
        
        

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedPostNotification(notification:)), name: Notification.Name("NotificationIdentifier2"), object: nil)
        
        
        
        
    }
    
    func fillLocation(){
    
        
        if( longitude != nil && latitude != nil){
            
            
            var locale = self.getLocation(longitudee: self.longitude!, latitudee: self.latitude!) as [String]
            
            
        }
        
        if(self.cityName != nil && self.countryName != nil){
        
            self.locationLbl.text = " \(self.cityName!) , \(self.countryName!) "
            
            
            getWeather()
            
        }
        
        
    }
    
    func getWeather(){
        
        print("in Get weather" )
        
        cityDeets.setLongNLat(long: self.longitude!, lat: self.latitude!)
        
        cityDeets.jsonParser()
        
    }
    
    @objc func methodOfReceivedPostNotification(notification: Notification){
        
        let alert = UIAlertController(title: "Sweet", message: "Your status has been shared", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        
        DispatchQueue.main.async { // Correct
            
            var tempCelc = (self.cityDeets.title as NSString).doubleValue
            
            print (tempCelc)
            print(String(format: "%.3f", tempCelc))

            
            if ( tempCelc != nil){
                tempCelc = (tempCelc - 32) * ( 5 / 9)
                self.tempToPost = tempCelc
                var tempRounded = (String(format: "%.3f", tempCelc))
                self.tempLbl.text = tempRounded + " deg Celcius"
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                
            }
            
        }
        
    }
    
    
    
    func getLocation( longitudee : Double, latitudee : Double ) -> [String] {
        
        var cityAndCountry = [String]()
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        geoCoder.reverseGeocodeLocation(location)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // Address dictionary
            //print(placeMark.addressDictionary)
            
            // City
            if let city = placeMark.addressDictionary?["City"] as? NSString
            {
                print("CITTTTYYYY ")
                print(city)
                
                self.cityName = city as String!
                
                cityAndCountry.append(city as String!)
                
            }
            
            // Country
            if let country = placeMark.addressDictionary?["Country"] as? NSString
            {
                print(country)
                
                self.countryName = country as String!
                
                cityAndCountry.append(country as String!)
            }
        }
        
        return cityAndCountry
        
        
    }
    
    
    // Print out the location to the console
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
            self.longitude = location.coordinate.longitude
            self.latitude = location.coordinate.latitude
            
            
            
            if(self.cityName != nil && self.countryName != nil){
                
                self.locationManager.stopUpdatingLocation()
                
                
            }
            self.fillLocation()
            
        }
    }
    
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "I really need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

