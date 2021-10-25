//
//  RequestMapDetailVC.swift
//  RoadStarRider
//
//  Created by Faizan Ali  on 2021/6/15.
//  Copyright © 2021 Faizan Ali . All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMaps
import CoreLocation
import MapKit
import Polyline
import Alamofire
import SwiftyJSON
import Cosmos

class RequestMapDetailVC: BaseViewController, Storyboarded {
    
    @IBOutlet weak var btnNext: PrimaryButton!
    @IBOutlet weak var googleMapView: GMSMapView!
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var vwRating: UIView!
    @IBOutlet weak var txtViewComments: PrimaryTextView!
    
    //var status: RequestStatus = .beforeArrived
    
    var locationManager: CLLocationManager!
    var localRequest: TripRequestUserData!
    
    var currentLat = 33.5969
    var currentLng = 73.0528
    var destinationLat = 33.6973
    var destinationLng = 73.0515
    
    func initialize(localRequest: TripRequestUserData) {
        self.localRequest = localRequest
    }
    
    let sourceMarker = GMSMarker()
    var imagePicker: ImagePicker!
    
    override func setupUI() {
        vwRating.alpha = 0
        guard let request = self.localRequest else { return }
        if request.status == "COMPLETED" {
            if request.providerRated == 0 {
                UIView.animate(withDuration: 1) {
                    self.vwRating.alpha = 1
                }
            }
            self.btnNext.isHidden = true
            return
        }
        
        startUI()
//        if request.status == "SEARCHING" {
//
//            self.updateRequestStatus(img: nil, status: nil, method: nil) { (msg, success) in
//                self.setupButtons()
//                self.startUI()
//            }
//        } else {
//            self.updateRequestStatus(img: nil, status: request.status ?? "ARRIVED", method: "PATCH") { (msg, success) in
//                self.setupButtons()
//                self.startUI()
//            }
//        }
//
//
    }
    
    func startUI() {
        
        vwRating.alpha = 0
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        locationManager = CLLocationManager()
        self.locationSetup()
        self.googleMapView.clear()
        setupMaps()
        
        let camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLng), zoom: 11)
        self.googleMapView.animate(to: camera)
        self.setupButtons()
        self.showRatingView()
    }
    
    func setupButtons() {
        
        btnNext.setTitle(self.getButtonTitle(), for: .normal)
    }
    
    func updateStatus(img: UIImage?) {
        
        guard let request = self.localRequest else { return }
        
        if request.status == "SEARCHING" {
            
            self.updateRequestStatus(img: img, status: nil, method: nil) { (msg, success) in
                self.setupButtons()
            }
        } else if request.status == "STARTED" {
            
            self.updateRequestStatus(img: img, status: "ARRIVED", method: "PATCH") { (msg, success) in
            
                self.googleMapView.clear()
                self.setupMaps()
                self.setupButtons()
            }
            
        } else if request.status == "ARRIVED" {
            
            self.updateRequestStatus(img: img, status: "PICKEDUP", method: "PATCH") { (msg, success) in
            
                self.googleMapView.clear()
                self.setupMaps()
                self.setupButtons()
            }
            
        } else if request.status == "PICKEDUP" {
            
            self.updateRequestStatus(img: img, status: "DROPPED", method: "PATCH") { (msg, success) in
                self.setupButtons()
                self.showRatingView()
            }
        } else if request.status == "DROPPED" {
            
            self.showRatingView()
//            self.updateRequestStatus(img: img, status: "COMPLETED", method: "PATCH") { (msg, success) in
//                self.showRatingView()
//                self.setupButtons()
//            }
        }
        
    }
    
    func showRatingView() {
        vwRating.alpha = 0
        
        guard let request = self.localRequest else { return }
        
        if request.providerRated == 0 && request.status == "COMPLETED" {
            UIView.animate(withDuration: 1) {
                self.vwRating.alpha = 1
            }
        }
    }


    @IBAction func btnSubmitTapped(_ sender: Any) {
        
        sendRating { (msg, success) in
            
            if success {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
//        let pi = ProgressIndicator.show(message: "loading...")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//            pi.close()
//            self.navigationController?.popToRootViewController(animated: true)
////            self.dismiss(animated: true, completion: nil)
//        }
        
    }
    
    @IBAction func btnNextTapped(_ sender: UIButton) {
        
        guard let request = self.localRequest else { return }
        
        if request.status == "ARRIVED" {
            self.imagePicker.present(from: sender, showCamera: true, showLibrary: true)
            
        } else if request.status == "PICKEDUP" {
            self.imagePicker.present(from: sender, showCamera: true, showLibrary: true)
            
        } else {
            updateStatus(img: nil)
        }
        
    }
    
    func setupMaps() {
        sourceMarker.position = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLng)
        sourceMarker.title = ""
        sourceMarker.snippet = ""
        sourceMarker.icon = UIImage.init(named: "Skoter@0.25x")
        sourceMarker.map = self.googleMapView
        
        guard let request = self.localRequest else { return }
        
        if request.status == "STARTED" {
            destinationLat = request.sLatitude ?? 33.6973
            destinationLng = request.sLongitude ?? 73.0515
            
        } else if request.status == "PICKEDUP" {
            destinationLat = request.dLatitude ?? 33.6973
            destinationLng = request.dLongitude ?? 73.0515
        } else {
            return
        }
        // MARK: Marker for destination location
        
        let destinationMarker = GMSMarker()
        destinationMarker.position = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLng)
        destinationMarker.title = ""
        destinationMarker.snippet = ""
        destinationMarker.map = self.googleMapView
        
        drawMap(SourceCordinate: sourceMarker.position, destinationcordinate: destinationMarker.position)
        
//        getRoute(from: sourceMarker.position, to: destinationMarker.position)
    }
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: to))

        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: { (response, error) in
            if let res = response {
                //the function to convert the result and show
                self.show(polyline: self.googlePolylines(from: res))
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    private func googlePolylines(from response: MKDirections.Response) -> GMSPolyline {

        let route = response.routes[0]
        var coordinates = [CLLocationCoordinate2D](
            repeating: kCLLocationCoordinate2DInvalid,
            count: route.polyline.pointCount)

        route.polyline.getCoordinates(
            &coordinates,
            range: NSRange(location: 0, length: route.polyline.pointCount))

        let polyline = Polyline(coordinates: coordinates)
        let encodedPolyline: String = polyline.encodedPolyline
        let path = GMSPath(fromEncodedPath: encodedPolyline)
        return GMSPolyline(path: path)
        
    }
    
    func show(polyline: GMSPolyline) {

        //add style to polyline
        polyline.strokeColor = UIColor.red
        polyline.strokeWidth = 3
        
        //add to map
        polyline.map = googleMapView
    }
    
    
    
    
    func drawMap(SourceCordinate : CLLocationCoordinate2D, destinationcordinate :CLLocationCoordinate2D)
       {
           self.googleMapView.clear()
           let str = String(format:"https://maps.googleapis.com/maps/api/directions/json?origin=\(SourceCordinate.latitude),\(SourceCordinate.longitude)&destination=\(destinationcordinate.latitude),\(destinationcordinate.longitude)&key=\("AIzaSyCO--TQ_iF9WC2_Gv7KgjasEmnEoxwbF-E")")
           print(str)
           AF.request(str).responseJSON { (response) -> Void in
            
            switch response.result {
            case let .success(value):
                
                print(value)
                if let resJson = value as? NSDictionary {
                    guard let routes = resJson["routes"] as? NSArray else {
                        print("No")
                        return
                    }
                    if(resJson["status"] as? String == "ZERO_RESULTS"){
                        print("ZERO_RESULTS")
                    } else if(resJson["status"] as? String == "NOT_FOUND"){
                        print("NOT_FOUND")
                    } else if routes.count == 0{
                        print("ZERO")
                    } else{
                        
                        let position = CLLocationCoordinate2D(latitude: SourceCordinate.latitude, longitude: SourceCordinate.longitude)
                        
                                           let pathv : NSArray = routes.value(forKey: "overview_polyline") as! NSArray
                                           let paths : NSArray = pathv.value(forKey: "points") as! NSArray
                                           let newPath = GMSPath.init(fromEncodedPath: paths[0] as! String)
                                           let polyLine = GMSPolyline(path: newPath)
                                           polyLine.strokeWidth = 5
                                           polyLine.strokeColor =  .black
                                           let ThemeOrange = GMSStrokeStyle.solidColor( .black)
                                           let OrangeToBlue = GMSStrokeStyle.gradient(from:  .black, to:  .black)
                                           polyLine.spans = [GMSStyleSpan(style: ThemeOrange),
                                                             GMSStyleSpan(style: ThemeOrange),
                                                             GMSStyleSpan(style: OrangeToBlue)]
                                           polyLine.map = self.googleMapView
                        
                    }
                }
                
                
                
            case let .failure(error):
                print(error.localizedDescription)
        }
            

           }
       }
    
    func updateRequestStatus(img: UIImage?, status: String?, method: String?, block: @escaping (String?, Bool)-> Void){
        
        guard let reqId = self.localRequest.id else {
            return
        }
        
        var data: UploadData? = nil
        if img != nil {
            data = UploadData(data: img!.pngData()!, fileName: "\(Date().timeIntervalSince1970).png", mimeType: "png", name: self.getImgNameString())
        }
        
        let pi = ProgressIndicator.show(message: "loading...")
        TheRoute.acceptRequest(reqId: String(reqId), method: method, status: status, airport: nil, flightNo: nil, vesselId: nil, sourcePortId: nil, destinationPortId: nil).send(TripRequestUserData.self, data: data, multipleData: nil) { (progress) in
            print(progress)
        } then: { (results) in
            pi.close()
            switch results {
            case .failure(let error):
                print(error)
                block(error.localizedDescription, false)
                
                
            case .success(let data):
            
                self.localRequest = data
                block(nil, true)
            }
        }
    }
    
    func sendRating(block: @escaping (String?, Bool)-> Void){
        
        let rating = Int(self.ratingView.rating)
        let note = self.txtViewComments.text ?? ""
        guard let reqId = self.localRequest.id else {
            return
        }
        
        let header: HTTPHeaders =
            [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-Requested-With": "XMLHttpRequest",
                "Authorization": "Bearer \(UserSession.shared.user?.accessToken ?? "")",
            ]
        
        let url = "https://myroadstar.org/api/provider/trip/\(reqId)/rate"
        let pi = ProgressIndicator.show(message: "loading...")
        
        AF.request(url, method: .post, parameters: ["rating": String(rating), "comment": note], encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            pi.close()
                switch response.result {
                case let .success(value):
                    
                    if let valueData = value as? [String:Any] {
                        print(valueData)
                        block(nil, true)
                    }else{
                        block(nil, false)
                    }
                case let .failure(error):
                    block(error.localizedDescription, false)
            }
        }

//        TheRoute.rateLocalTripUser(tripId: String(reqId), rating: String(rating), comment: note).send(NormalMsgSimpleResponse.self, data: nil, multipleData: nil) { (progress) in
//            print(progress)
//        } then: { (results) in
//            
//            switch results {
//            case .failure(let error):
//                print(error)
//                block(error.localizedDescription, false)
//                
//                
//            case .success( _ ):
//                block(nil, true)
//            }
//        }
    }
    
}


extension RequestMapDetailVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                
                let currentlocation = CLLocation(latitude: currentLat, longitude: currentLng)
                let distanceInMeters =  currentlocation.distance(from: location)
                if distanceInMeters > 10 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.currentLat = location.coordinate.latitude
                        self.currentLng = location.coordinate.longitude
                        self.googleMapView.clear()
                        self.setupMaps()
                    }
                    
                    print("Found user's location: \(location)")
                }
                
                print("Found user's location NOOO: \(location)")
//                manager.stopUpdatingLocation()
            }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationSetup(showAlert: Bool = false){
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if status == .denied || status == .restricted {
            if showAlert {
            
                let alert = UIAlertController(title: "Oops", message: "We need your location to show you on Maps", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {_ in
                    
                    
                }))
                alert.addAction(UIAlertAction(
                    title: "Settings",
                    style: UIAlertAction.Style.default,
                                    handler: {_ in
                                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                                        
                                        if UIApplication.shared.canOpenURL(settingsUrl) {
                                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                                print("Settings opened: \(success)") // Prints true
                                            })
                                        }
                                        
                                    }))

                self.present(alert, animated: true, completion: nil)

            }
        }
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func getButtonTitle() -> String {
        
        guard let request = self.localRequest else { return ""}
        
        switch request.status {
        case "SEARCHING":
            return ""
        case "STARTED":
            return "TAP WHEN ARRIVED"
        case "ARRIVED":
            return "PICKUP PACKAGE"
        case "PICKEDUP":
            return "TAP WHEN DELIVERED"
        case "DROPPED":
            return ""
        default:
            return ""
        }
    }
    
    func getImgNameString() -> String {
        
        guard let request = self.localRequest else { return ""}
        
        switch request.status {
        case "SEARCHING":
            return ""
        case "ARRIVED":
            return "pickedUpImage"
        case "PICKEDUP":
            return "droppedOfImage"
        case "DROPPED":
            return ""
        case "COMPLETED":
            return ""
        default:
            return ""
        }
        
    }
}


//enum RequestStatus {
//    case beforeArrived
//    case arrived
//    case pickPackage
//    case rateExperience
//
//    func title() -> String {
//
//        switch self {
//        case .beforeArrived:
//            return "TAP WHEN ARRIVED"
//        case .arrived:
//            return "PICKUP PACKAGE"
//        case .pickPackage:
//            return "TAP WHEN DELIVERED"
//        case .rateExperience:
//            return "SUBMIT"
//        }
//    }
//
//    func statusString() -> String {
//
//        switch self {
//        case .beforeArrived:
//            return ""
//        case .arrived:
//            return "ARRIVED"
//        case .pickPackage:
//            return "PICKED"
//        case .rateExperience:
//            return "RATE"
//        }
//    }
//
//    func imgNameString() -> String {
//
//        switch self {
//        case .beforeArrived:
//            return ""
//        case .arrived:
//            return "pickedUpImage"
//        case .pickPackage:
//            return "droppedOfImage"
//        case .rateExperience:
//            return ""
//        }
//    }
//}



extension RequestMapDetailVC: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        
        if let img = image {
            self.updateStatus(img: img)
        }
    }
    
    func didSelect(videoUrl: NSURL?) {
    }
    
    
    
}
