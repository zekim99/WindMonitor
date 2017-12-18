//
//  WeatherAPI.swift
//  WindMonitor
//
//  Created by Zed on 11/11/15.
//  Copyright © 2015 Zed. All rights reserved.
//

import Foundation

struct Weather {
    var windDir: Int
    var windSpeedMph: Float
    var windGustMph: Float
    var topWindGustMph: Float = 0.0
    var topWindGustTime: Date = Date()
    var isTopGust: Bool = false
}

protocol WeatherAPIDelegate {
    func weatherDidUpdate(_ weather: Weather)
}

class WeatherAPI {
    
    let BASE_URL: String = "http://fishwheel.com:8080/wx"
    var delegate: WeatherAPIDelegate?
    var _topWindGustMph: Float = 0.0
    var _topWindGustTime: Date = Date()
    var _isTopGust: Bool = false
    
    init(delegate: WeatherAPIDelegate) {
        self.delegate = delegate
    }
    

    func fetchWeather() {
        
        let session = URLSession.shared
        let url = URL(string: "\(BASE_URL)")
        
        
        do {
            let task = try session.dataTask(with: url!, completionHandler: { data, response, err in
                if let error = err {
                    NSLog("Unable to fetch weather data: \(error)")
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        if let weather = self.weatherFromJSONData(data!) {
                            self.delegate?.weatherDidUpdate(weather)
                        }
                    default:
                        NSLog("Unable to request weather data: %d %@", httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                    }
                }
            }) 
            
            task.resume()
            
        } catch {
            NSLog("Error fetching weather data")
        }
        
    }
    
    func weatherFromJSONData(_ data: Data) -> Weather? {
        
        //let x = NSCalendar.isDateInToday((NSCalendar)_topWindGustTime)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            
            let windDir = (json["windDir"] as? Int) ?? -1
            let windSpeedMph = (json["windSpeed"] as! Float)
            let windGustMph = (json["windSpeed"] as! Float)
            let windGustTime = (json["dateTime"] as! String) + " GMT"
            
            debugPrint(windGustMph)
            debugPrint(_topWindGustMph)
            
            _isTopGust = false
            if windGustMph >= _topWindGustMph {
                _topWindGustMph = windGustMph
                _topWindGustTime = dateFormatter.date(from: windGustTime)!
                _isTopGust = true
            }
            
            // use -1 for null direction
            let weather = Weather(
                windDir: windDir,
                windSpeedMph: windSpeedMph,
                windGustMph: windGustMph,
                topWindGustMph: _topWindGustMph,
                topWindGustTime: _topWindGustTime,
                isTopGust: _isTopGust)
            
            
            debugPrint(weather)
            
            return weather
            
    
        } catch {
            print("Unable to parse JSON: \(error)")
        }
        
        return nil
    }
}
