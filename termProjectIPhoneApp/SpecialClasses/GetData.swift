//
//  GetData.swift
//  W10JSONRemoteParsing
//
//  Created by Davinder on 2017-12-17.
//  Copyright © 2017 Davinder. All rights reserved.
//

import UIKit

class GetData: NSObject {
    
    var postRequest : Double?
    
    var latitude : Double?
    
    var longitude : Double?
    
    var title : String = ""
    
    
    
    func setLongNLat(long : Double, lat : Double){
        
        self.longitude = long
        
        self.latitude = lat
        
    }
    
    var dbData : [NSDictionary]?
    
    enum JSONError : String, Error{
        case NoData = "Error, no data"
        case ConversionFailed = "Error, conversion from JSON failed"
    }
    
    func jsonParser(){
        
        let myURL = "https://api.darksky.net/forecast/f902367c487a43267e02a81e5ac0c58b/\(latitude!),\(longitude!)"
        
        print(myURL)
        
        guard let endpoint = URL(string: myURL) else {
            print("Error creating connection")
            return
        }
        
        let request = URLRequest(url: endpoint)
        
        URLSession.shared.dataTask(with: request){
            (data,response,error) in
            
            /*do {
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
                print(dataString)
                
                
                guard let data = data else {
                    throw JSONError.NoData
                }
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary] else{
                    throw JSONError.ConversionFailed
                }
                
                print(json)
                
                self.dbData = json
                
                
            }catch let error as JSONError{
                print(error.rawValue)
                
            }catch let error as NSError{
                print(error.debugDescription)
            }*/
            
            if let url = NSURL(string:myURL){
            
            if let data = NSData(contentsOf: url as URL){
                
                do{
                    
                    let parsed = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    let newDict = parsed as? NSDictionary
                    
                    let cityForecast = newDict?["currently"] as? NSDictionary
                    
                    self.title = "\(cityForecast!["temperature"]!) "
                    
                    print(self.title)
                    
                    if( !self.title.isEmpty){
                        
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                        
                    }
                    
                    
                    
                }catch let error as NSError{
                    
                    self.title = "A JSON parsing error has occurred!"
                    //summary = error.localizedDescription
                    
                }
                
            }
            }
        
    }.resume()
        
        
        
        
    }
    
    
    
    func postToBrian (fname : String , lname : String, loc : String , temp : Double, realTemp: Int, statusUpdate: String){
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        let parameters = ["fname": fname, "lname": lname, "location":loc , "realtemp" : temp , "accuracy" : realTemp, "comment" : statusUpdate ] as [String : Any]
        
        //create the url with URL
        let url = URL(string: "http://weather.brianmorris.info/api/posts/")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    
                    print("Great Sucess")
                    
                    self.postRequest = 200
                    
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier2"), object: nil)
                    
                    
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
