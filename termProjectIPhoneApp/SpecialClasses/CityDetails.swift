//
//  CityDetails.swift
//  W11TVWeather
//
//  Created by Davinder on 2017-12-20.
//  Copyright © 2017 Davinder. All rights reserved.
//

import UIKit

class CityDetails: NSObject {
    
    var latitude : Double?
    
    var longitude : Double?
    
    var title : String = ""
    
    
    
    func setLongNLat(long : Double, lat : Double){
        
        self.longitude = long
        
        self.latitude = lat
        
    }
    
    
    func getDataFromJSON(){
        
        let url = "https://api.darksky.net/forecast/f902367c487a43267e02a81e5ac0c58b/\(latitude),\(longitude)"
        
        if let url = NSURL(string:url){
        
            if let data = NSData(contentsOf: url as URL){
                
                do{
                    
                    let parsed = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    let newDict = parsed as? NSDictionary
                    
                    let cityForecast = newDict?["currently"] as? NSDictionary
                    
                    title = "\(cityForecast!["temperature"]!) "
                    
                    
                    
                }catch let error as NSError{
                    
                    title = "A JSON parsing error has occurred!"
                    //summary = error.localizedDescription
                    
                }
                
            }
        }
        
        
        
    }
    

}
