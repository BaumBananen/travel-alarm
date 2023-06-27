//
//  MapAPI.swift
//  S-Bahn Wecker
//
//  Created by Enno Nussbaum on 14.06.23.
//

import Foundation
import MapKit

struct Address: Codable {
    let data: [Datum]
}

struct Datum: Codable {
    let latitude, longitude: Double
    let name: String?
}

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

class MapAPI: ObservableObject {
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "fb215a06a783a7d90715e2f6dd41e0bc"
    
    @Published var region: MKCoordinateRegion
    @Published var coordinates: [Double] = []
    @Published var locations: [Location] = []
    @Published var hasCorrectLocation = false//new
    @Published var failed = false//new
    
    init(){
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.50, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
        
        self.locations.insert(Location(name: "Pin", coordinate: CLLocationCoordinate2D(latitude: 51.50, longitude: -0.1275)), at: 0)
    }
    
    func getLocation(address: String, delta: Double) {
        self.hasCorrectLocation=false//new
        self.failed=false
        let pAddress = address.replacingOccurrences(of: " ", with: "%20")
            .replacingOccurrences(of: "ß", with: "%C3%9F")
            .replacingOccurrences(of: "ä", with: "%C3%A4")
            .replacingOccurrences(of: "ö", with: "%C3%B6")
            .replacingOccurrences(of: "ü", with: "%C3%BC")
            .replacingOccurrences(of: "-", with: "%2D")
        let url_string = "\(BASE_URL)?access_key=\(API_KEY)&query=\(pAddress)"
        
        guard let url = URL(string: url_string) else {
            print("Invalid URL")
            failed=true
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error!.localizedDescription)
                self.failed=true
                return
            }
            
            guard let newCoordinates = try? JSONDecoder().decode(Address.self, from: data) else {return}
            
            if newCoordinates.data.isEmpty {
                print("Could not find the address...")
                self.failed=true
                return
            }
            
            DispatchQueue.main.async {
                let details = newCoordinates.data[0]
                let lat = details.latitude
                let lon = details.longitude
                let name = details.name
                
                self.coordinates = [lat, lon]
                self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
                
                let new_location = Location(name: name ?? "destination", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                self.locations.removeAll()
                self.locations.insert(new_location, at: 0)
                
                print("Successfully loaded the location!")
                self.hasCorrectLocation=true//new
                self.failed=false
            }
            
        }
        .resume()
    }
}
