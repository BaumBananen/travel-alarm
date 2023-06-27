//
//  ContentView.swift
//  S-Bahn Wecker
//
//  Created by Enno Nussbaum on 29.03.23.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @State private var notifyDistance=500 //Abstand bei dem benachrichtigt wird
    @State public var destinationCoords: CLLocation?
    @State private var destinationName: String?
    @State private var distanceDestination: CLLocationDistance? //speichert den Abstand vom Ziel
    @StateObject private var mapAPI = MapAPI()
    @State private var text = ""
    @State private var currentMapCoords: CLLocationCoordinate2D?
    @State private var currentMapRegion = MKCoordinateRegion(center:CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(2.8*Double(500)/110574), longitudeDelta: CLLocationDegrees(2.8*Double(500)/110574))) //damit die Map am Ende verschiebbar ist
    @State private var selecting=false
    @State private var statusText = "enter approximate Location, then press Search"
    @State private var tracking = false
    @FocusState private var addressFinderIsFocused: Bool//um das keyboard zu schließen, https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfieldö_-_
    let locationManager = LocationManager()

    var body: some View {
        VStack{
            VStack{
                Text("Travel Alarm")
                    .font(.largeTitle)
                
                TextField("Enter an address", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .focused($addressFinderIsFocused)
            }
            Text(statusText)
                .font(.system(size: 16))
                .italic()
                .foregroundColor(.gray)
            
            Button("Search") {//button locate?
                if(text.count>2){
                    mapAPI.failed=false
                    mapAPI.getLocation(address: text, delta: 2.8*Double(notifyDistance)/110574)
                    currentMapCoords=nil
                    selecting=false
                    statusText = "loading"
                    self.tracking=false
                    addressFinderIsFocused=false
                    

                }
                else{
                    statusText="try something longer"
                }
            }
            if(mapAPI.hasCorrectLocation){
                Text("location found")
                    .onAppear{
                        selecting=true
                        statusText="move pin to desired destination, then press select"
                    }
            }
            if(selecting){
                Button("select"){
                    destinationName = mapAPI.locations[0].name
                    print("DestName is "+(destinationName ?? "not set"))
                    destinationCoords = CLLocation(latitude: mapAPI.region.center.latitude , longitude: mapAPI.region.center.longitude)
                    currentMapCoords=destinationCoords!.coordinate
                    selecting=false
                    statusText="now select your preferred distance"
                    mapAPI.hasCorrectLocation=false
                    self.tracking=true
                    self.currentMapRegion=MKCoordinateRegion(center:currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(2.8*Double(notifyDistance)/110574), longitudeDelta: CLLocationDegrees(2.8*Double(notifyDistance)/110574))) //setzt die neue Map auf die Region
                }
            }
            if(mapAPI.failed){
                Text("Suche fehlgeschlagen :(")
                    .onAppear{
                        statusText="try another location"
                    }
            }
            if(selecting&&addressFinderIsFocused==false){
                Map(coordinateRegion: $mapAPI.region, showsUserLocation: true, annotationItems: mapAPI.locations) {
                    location in MapMarker(coordinate: mapAPI.region.center, tint: .blue)
                }
                .ignoresSafeArea()
                .frame(width: 400, height: 400)
            }
            
            if((currentMapCoords != nil)&&addressFinderIsFocused==false){
                ZStack{
                    Map(coordinateRegion: $currentMapRegion, showsUserLocation: true, annotationItems: [Location(name: "", coordinate: CLLocationCoordinate2D(latitude: currentMapCoords!.latitude, longitude: currentMapCoords!.longitude))]) {location in MapMarker(coordinate: location.coordinate, tint: .blue)}
                        .frame(width: 400, height: 400)
                    if(currentMapRegion.center.latitude==currentMapCoords?.latitude&&currentMapRegion.center.longitude==currentMapCoords?.longitude){
                        Circle()
                            .strokeBorder(.red, lineWidth: 2)
                            .frame(width: 2*400/2.8, height: 2*400/2.8)
                            .padding()
                    }
                }
            }
            
            Menu{
                Button(action: {
                    notifyDistance=50
                    if(tracking){
                        statusText="You're all set! :)"
                        self.currentMapRegion=MKCoordinateRegion(center: currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: 2.8*Double(notifyDistance)/110574, longitudeDelta: 2.8*Double(notifyDistance)/110574)) //aktualisiert die Karte sodass sie automatisch auf das Ziel und den neuen Radius eingestellt wird
                    }
                }, label: {
                    Text("50m")
                })
                Button(action: {
                    notifyDistance=100
                    if(tracking){
                        statusText="You're all set! :)"
                        self.currentMapRegion=MKCoordinateRegion(center: currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: 2.8*Double(notifyDistance)/110574, longitudeDelta: 2.8*Double(notifyDistance)/110574)) //aktualisiert die Karte sodass sie automatisch auf das Ziel und den neuen Radius eingestellt wird
                    }}, label: {
                    Text("100m")
                })
                Button(action: {
                    notifyDistance=200
                    if(tracking){
                        statusText="You're all set! :)"
                        self.currentMapRegion=MKCoordinateRegion(center: currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: 2.8*Double(notifyDistance)/110574, longitudeDelta: 2.8*Double(notifyDistance)/110574)) //aktualisiert die Karte sodass sie automatisch auf das Ziel und den neuen Radius eingestellt wird
                    }}, label: {
                    Text("200m")
                })
                Button(action: {
                    notifyDistance=500
                    if(tracking){
                        statusText="You're all set! :)"
                        self.currentMapRegion=MKCoordinateRegion(center: currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: 2.8*Double(notifyDistance)/110574, longitudeDelta: 2.8*Double(notifyDistance)/110574)) //aktualisiert die Karte sodass sie automatisch auf das Ziel und den neuen Radius eingestellt wird
                    }}, label: {
                    Text("500m")
                })
                Button(action: {
                    notifyDistance=1000
                    if(tracking){
                        statusText="You're all set! :)"
                        self.currentMapRegion=MKCoordinateRegion(center: currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: 2.8*Double(notifyDistance)/110574, longitudeDelta: 2.8*Double(notifyDistance)/110574)) //aktualisiert die Karte sodass sie automatisch auf das Ziel und den neuen Radius eingestellt wird
                    }}, label: {
                    Text("1000m")
                })
                Button(action: {notifyDistance=2000
                    if(tracking){
                        statusText="You're all set! :)"
                        self.currentMapRegion=MKCoordinateRegion(center: currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: 2.8*Double(notifyDistance)/110574, longitudeDelta: 2.8*Double(notifyDistance)/110574)) //aktualisiert die Karte sodass sie automatisch auf das Ziel und den neuen Radius eingestellt wird
                    }}, label: {
                    Text("2000m")
                })
                Button(action: {
                    notifyDistance=5000
                    if(tracking){
                        statusText="You're all set! :)"
                        self.currentMapRegion=MKCoordinateRegion(center: currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: 2.8*Double(notifyDistance)/110574, longitudeDelta: 2.8*Double(notifyDistance)/110574)) //aktualisiert die Karte sodass sie automatisch auf das Ziel und den neuen Radius eingestellt wird
                    }}, label: {
                    Text("5000m")
                })
                Button(action: {
                    notifyDistance=10000
                    if(tracking){
                        statusText="You're all set! :)"
                        self.currentMapRegion=MKCoordinateRegion(center: currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: 2.8*Double(notifyDistance)/110574, longitudeDelta: 2.8*Double(notifyDistance)/110574)) //aktualisiert die Karte sodass sie automatisch auf das Ziel und den neuen Radius eingestellt wird
                    }}, label: {
                    Text("10000m")
                })
                Button(action: {
                    notifyDistance=100000
                    if(tracking){
                        statusText="Thats a big radius"
                        self.currentMapRegion=MKCoordinateRegion(center: currentMapCoords!, span: MKCoordinateSpan(latitudeDelta: 2.8*Double(notifyDistance)/110574, longitudeDelta: 2.8*Double(notifyDistance)/110574)) //aktualisiert die Karte sodass sie automatisch auf das Ziel und den neuen Radius eingestellt wird
                    }
                }, label: {
                    Text("100km")
                })
                Button(action: {
                    notifyDistance=0
                    if(tracking){
                        statusText="notification deactivated"
                    }
                }, label: {
                    Text("disable notification")
                })
                
            } label: {
                Label(
                    title: {Text("select distance (\(notifyDistance)m)")},
                    icon: {Image(systemName: "plus")}
                )
            }
            if(destinationName != nil){
                Text("\((Int(distanceDestination ?? 0)))m away from "+(destinationName ?? "no destination selected"))
                    .onAppear {
                        // Set up location updates
                        locationManager.onLocationUpdate = { location in
                            // Calculate distance to destination
                            if(destinationCoords != nil){
                                
                                // Update state with the distance
                                distanceDestination=location.distance(from: destinationCoords!)
                                //send notification
                                if((Int(distanceDestination!))<notifyDistance){//prev distanceDest
                                    if(distanceDestination != 0){//prev distanceDest
                                        let content = UNMutableNotificationContent()
                                        content.title = "You're close"
                                        content.body = "\(Int(distanceDestination!))m away from "+destinationName!
                                        content.sound = .defaultRingtone
                                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                                        
                                        let request = UNNotificationRequest(identifier: "myNotification", content: content, trigger: trigger)
                                        
                                        UNUserNotificationCenter.current().add(request) { error in
                                            if let error = error {
                                                print("Failed to add notification: \(error.localizedDescription)")
                                            } else {
                                                print("Notification scheduled")
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                        locationManager.startUpdatingLocation()
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
