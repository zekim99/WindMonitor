//
//  StatusMenuController.swift
//  WindMonitor
//
//  Created by Zed on 11/11/15.
//  Copyright © 2015 Zed. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, WeatherAPIDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    
    var weatherAPI: WeatherAPI!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let interval: Double = 2.0
    
    // Update Menu click handler
    @IBAction func updateClicked(_ sender: AnyObject) {
        weatherAPI.fetchWeather()
    }

    // Quit Menu click handler
    @IBAction func quitClicked(_ sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }
    
    @IBOutlet weak var windSpeedMenu: NSMenuItem!
    
    @IBOutlet weak var windDirectionMenu: NSMenuItem!
    
    @IBOutlet weak var windGustMenu: NSMenuItem!
    
    override func awakeFromNib() {
        
        statusItem.menu = statusMenu
        
        let icon = NSImage(named: "StatusBarImageEmpty")
        icon?.isTemplate = true
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarImageEmpty")
            button.imagePosition = NSCellImagePosition.imageLeft
            button.title = "- -"
        }
        
        weatherAPI = WeatherAPI(delegate: self)
        updateWeather()
        
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(StatusMenuController.updateWeather), userInfo: nil, repeats: true)
        
    }
    
    func updateWeather() {
        weatherAPI.fetchWeather()
    }
    
    func resetTopGust() {
        
    }

    func weatherDidUpdate(_ weather: Weather) {
        
        let directionInfo:(dirString:NSString, image:NSImage) = calculateDirection(weather.windDir)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        //dateFormatter.timeZone = TimeZone()
        let topWindGustTime = dateFormatter.string(from: weather.topWindGustTime as Date)
        
        if let statusButton = self.statusItem.button {
            statusButton.highlight(false)
            statusButton.title = NSString(format: "%.1f", weather.windSpeedMph) as String
            statusButton.image = directionInfo.image
            statusButton.image?.isTemplate = true
            statusButton.highlight(weather.isTopGust)
        }
        
        
        windSpeedMenu.title = NSString(format: "Wind Speed: %.1f mph", weather.windSpeedMph) as String
        windDirectionMenu.title = NSString(format: "Wind Direction: \(directionInfo.dirString)" as NSString) as String
        windGustMenu.title = NSString(format: "Top Wind Gust: %.1f mph at %@", weather.topWindGustMph, topWindGustTime) as String
    }
    
    func calculateDirection(_ degrees: Int) -> (dirString:NSString, image:NSImage) {
        
        switch degrees {
        case 338..<360:
            return ("North", NSImage(named: "StatusBarImageNorth")!)
        case 0..<23:
            return ("North", NSImage(named: "StatusBarImageNorth")!)
        case 23..<68:
            return ("Northeast", NSImage(named: "StatusBarImageNorthEast")!)
        case 68..<113:
            return ("East", NSImage(named: "StatusBarImageEast")!)
        case 113..<158:
            return ("Southeast", NSImage(named: "StatusBarImageSouthEast")!)
        case 158..<203:
            return ("South", NSImage(named: "StatusBarImageSouth")!)
        case 203..<248:
            return ("Southwest", NSImage(named: "StatusBarImageSouthWest")!)
        case 248..<293:
            return ("West", NSImage(named: "StatusBarImageWest")!)
        case 293..<338:
            return ("Northwest", NSImage(named: "StatusBarImageNorthWest")!)
        default:
            return ("None", NSImage(named: "StatusBarImageEmpty")!)
        }
        
    }
    
}
    
