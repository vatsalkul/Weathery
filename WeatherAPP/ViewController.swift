//
//  ViewController.swift
//  WeatherAPP
//
//  Created by Vatsal Kulshreshtha on 12/07/19.
//  Copyright © 2019 Vatsal Kulshreshtha. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import SwiftVideoBackground

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var rainSound = AVAudioPlayer()
    var drizzleSound = AVAudioPlayer()
    var thunderSound = AVAudioPlayer()
    var windSound = AVAudioPlayer()
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var skyImageView: UIImageView!
    
    var latitude:String = ""
    var longitude:String = ""
    var currentLocation: CLLocation!
    var myLink:String = ""
    
    let manager = CLLocationManager()
    let date = Date()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            rainSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "rain", ofType: "mp3")!))
        }
        catch {
            print(error)
        }
        do{
            drizzleSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "drizzle", ofType: "mp3")!))
        }
        catch {
            print(error)
        }
        do{
            thunderSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "thunder", ofType: "mp3")!))
        }
        catch {
            print(error)
        }
        do{
            windSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "wind", ofType: "mp3")!))
        }
        catch {
            print(error)
        }
        
        tempLabel.text = "-"
        cityLabel.text = "-"
        countryLabel.text = "-"
        descLabel.text = "-"
        minTempLabel.text = "-"
        maxTempLabel.text = "-"
        humidityLabel.text = "-"
        
        getLocation()
        fetchData()
        getTime()
        
    }
    
    
    
    
    func fetchData(){
        
        let url = URL(string: myLink)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print("ERROR")
            }
            else{
                if let content = data{
                    do{
                        print(self.myLink)
                        guard let myJson = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as? [String: Any] else {return}
                        guard let weatherDetails = myJson["weather"] as? [[String: Any]] else {return}
                        let weatherMain = myJson["main"] as? [String: Any]
                        let temp = Int(weatherMain!["temp"] as? Double ?? 0)
                        let humidity = Int(weatherMain!["humidity"] as? Int ?? 0)
                        let minTemp = Int(weatherMain!["temp_min"] as? Double ?? 0)
                        let maxTemp = Int(weatherMain!["temp_max"] as? Double ?? 0)
                        let weatherSys = myJson["sys"] as? [String: Any]
                        let country = weatherSys!["country"] as? String ?? ""
                        let place = myJson["name"] as? String
                        
                        let description = (weatherDetails.first?["description"] as? String)?.capitalisingFirst()
                        DispatchQueue.main.async {
                            
                            self.setLabels(weather: weatherDetails.first?["main"] as? String, description: description, temp: temp, country: country, place: place, minTemp: minTemp, maxTemp: maxTemp, humidity: humidity)
                        }
                    }
                    catch{
                        print("Error in retriving data")
                    }
                }
            }
        }
        task.resume()
   
    }
    
    
    func setLabels(weather: String?, description: String?, temp: Int, country: String?, place: String?, minTemp: Int, maxTemp: Int, humidity: Int){
        countryLabel.text = country ?? "error"
        cityLabel.text = place ?? "error"
        descLabel.text = description ?? "error"
        tempLabel.text = "\(temp-273)°C"
        humidityLabel.text = "Humidity:  \(humidity)%"
        minTempLabel.text = "Min. Temp:  \(minTemp-273)°C"
        maxTempLabel.text = "Max. Temp:  \(maxTemp-273)°C"
        
        switch weather {
        case "Rain":
            rainSound.play()
            rainSound.numberOfLoops = -1
            try? VideoBackground.shared.play(view: videoView, videoName: "Rain_anim", videoType: "mov")
        case "Thunderstorm":
            try? VideoBackground.shared.play(view: videoView, videoName: "Thunder_anim", videoType: "mov")
            thunderSound.play()
            thunderSound.numberOfLoops = -1
        case "Drizzle":
            try? VideoBackground.shared.play(view: videoView, videoName: "Rain_anim", videoType: "mov")
            drizzleSound.play()
            drizzleSound.numberOfLoops = -1
        default:
            try? VideoBackground.shared.play(view: videoView, videoName: "Cloud_anim", videoType: "mov")
            windSound.play()
            windSound.numberOfLoops = -1
        }
    }
    
    
    func getTime(){
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        if hour >= 6 && hour <= 11 {
            self.skyImageView.image = UIImage(named: "morningSky")
        }
        else if hour >= 12 && hour <= 16 {
            self.skyImageView.image = UIImage(named: "sunSky")
        }
        else if hour >= 17 && hour <= 19 {
            self.skyImageView.image = UIImage(named: "duskSky")
        }
        else if hour >= 20 && hour <= 23 {
            self.skyImageView.image = UIImage(named: "nightSky")
        }
        else {
            self.skyImageView.image = UIImage(named: "midnightSky")
        }
    }
    
    func getLocation(){
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            
            currentLocation = manager.location
            latitude = "\(currentLocation.coordinate.latitude)"
            longitude = "\(currentLocation.coordinate.longitude)"
            myLink = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=1adb1bffef7251f243e33c97566f9c2a"
            
        }
    }
    
}
extension String {
    func capitalisingFirst() -> String{
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
