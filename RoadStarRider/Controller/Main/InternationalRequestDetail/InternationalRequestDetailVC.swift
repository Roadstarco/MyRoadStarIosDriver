//
//  InternationalRequestDetailVC.swift
//  RoadStarRider
//
//  Created by Faizan Ali  on 2021/6/26.
//  Copyright © 2021 Faizan Ali . All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SDWebImage
import Cosmos

class InternationalRequestDetailVC: BaseViewController, Storyboarded {
    
    @IBOutlet weak var theTableView: UITableView!
    
    @IBOutlet weak var vwPayment: UIView!
    @IBOutlet weak var lblDeducted: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblBaseFare: UILabel!
    @IBOutlet weak var lblInvoiceNo: UILabel!
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var vwRating: UIView!
    @IBOutlet weak var txtViewComments: PrimaryTextView!
    
    var showPaymentView: Bool = false
    var rated: Bool = false
    
    var request: InternationalRequest? = nil
    var theRequest: ScheduledTripResponse? = nil
    
    var imagePicker: ImagePicker!
    
    func initialize(request: InternationalRequest?, theRequest: ScheduledTripResponse?) {
        self.request = request
        self.theRequest = theRequest
    }
    
    override func setupUI() {

        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        registerXibs()
        checkSetup()
    }
    
    func registerXibs() {
        
        let nib = UINib.init(nibName: "InternationalRequestDetailCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "InternationalRequestDetailCell")
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnConfirmTapped(_ sender: Any) {
        
        showPaymentView = false
        checkSetup()
    }
    
    func checkSetup() {
        
        self.vwRating.isHidden = true
        self.vwPayment.isHidden = true
        guard let req = self.theRequest else { return }
        
        
        
        if showPaymentView {
            guard let req = self.theRequest else { return }
            guard let payment = req.payment else { return }
            
            self.vwPayment.isHidden = false
            self.lblInvoiceNo.text = "Invoice: \(payment.id ?? 0)"
            self.lblBaseFare.text = "Invoice: \(payment.fixed ?? 0)"
            self.lblTotal.text = "Invoice: \(payment.total ?? 0)"
            self.lblDeducted.text = "Invoice: \(payment.total ?? 0)"
            return
        }
        
        if rated { return }
        
        if req.providerRated == 0 && req.tripStatus == "COMPLETED" {
            self.vwRating.isHidden = false
            
        }
        
    }
    
    @IBAction func btnSubmitRatingTapped(_ sender: Any) {
        
        sendRating { (msg, success) in
            
            if success {
                self.rated = true
                self.checkSetup()
                self.navigationController?.popViewController(animated: true)
            } else if let msg = msg {
                Toast.showError(message: "\(msg)")
            }
        }
    }
    
    func sendRating(block: @escaping (String?, Bool)-> Void){
        
        guard let req = self.theRequest else { return }
        
        let rating = self.ratingView.rating
        let note = self.txtViewComments.text ?? ""
        guard let reqId = req.id else {
            return
        }

        let pi = ProgressIndicator.show(message: "loading...")
        TheRoute.rateTripUser(tripId: String(reqId), rating: String(rating), comment: note).send(NormalSimpleResponse.self, data: nil, multipleData: nil) { (progress) in
            print(progress)
        } then: { (results) in
            pi.close()
            switch results {
            case .failure(let error):
                print(error)
                block(error.localizedDescription, false)
                
                
            case .success( _ ):
                block(nil, true)
            }
        }
    }

    
}


extension InternationalRequestDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InternationalRequestDetailCell") as! InternationalRequestDetailCell
        
        if let req = self.request {
            cell.setUp(request: req, parent: self)
        } else if let theReq = self.theRequest {
            cell.setUpTheRequest(request: theReq, parent: self)
        }
        
        return cell
    }
    
    
    
    
    
}


extension InternationalRequestDetailVC: InternationalRequestDetailProtocol {
    
    func getData(airport: AirpoartResponse, flight: String) {
        
        if let status = getStatus() {
            changeRequestStatus(status: status, airport: airport.ident, flightNo: flight, vesselId: nil, sourcePortId: nil, destinationPortId: nil, imgKey: nil, img: nil) { (msg, success) in
                
                self.theTableView.reloadData()
            }
        }
    }
    
    func setupTheUI() {
        
        
    }
    
    
}


extension InternationalRequestDetailVC {
    
    func changeRequestStatus(status: String, airport: String?, flightNo: String?, vesselId: String?, sourcePortId: String?, destinationPortId: String?, imgKey: String?, img: UIImage?, block: @escaping (String?, Bool)-> Void){
        
        guard let req = self.theRequest else { return }
        guard let reqId = req.id else { return }
        
        var data: UploadData? = nil
        if let img = img {
            if let key = imgKey {
                data = UploadData(data: img.pngData()!, fileName: "\(Date().timeIntervalSince1970).png", mimeType: "png", name: key)
            }
        }
        
        let pi = ProgressIndicator.show(message: "loading...")
        TheRoute.acceptInternationalRequest(reqId: String(reqId), method: "PATCH", status: status, airport: airport, flightNo: flightNo, vesselId: vesselId, sourcePortId: sourcePortId, destinationPortId: destinationPortId).send(ScheduledTripResponse.self, data: data, multipleData: nil) { (progress) in
            print(progress)
        } then: { (results) in
            pi.close()
            switch results {
            case .failure(let error):
                print(error)
                block(error.localizedDescription, false)
                
                
            case .success(let data ):
                print(data)
                self.theRequest = data
                block(nil, true)
            }
        }
    }
    
    
    func getStatus() -> String? {
        
        guard let req = self.theRequest else { return nil }
        
        if req.tripStatus == "SCHEDULED" {
            return "ARRIVED"
        } else if req.tripStatus == "ARRIVED" {
            return "PICKEDUP"
        } else if req.tripStatus == "PICKEDUP" {
            return "DROPPED"
        } else if req.tripStatus == "DROPPED" {
            return "COMPLETED"
        }
        return nil
    }
    
    func getImgKey() -> String? {
        
        guard let req = self.theRequest else { return nil }
        
        if req.tripStatus == "SCHEDULED" {
            return nil
        } else if req.tripStatus == "ARRIVED" {
            return nil
        } else if req.tripStatus == "PICKEDUP" {
            return "pickedUpImage"
        } else if req.tripStatus == "DROPPED" {
            return "droppedOfImage"
        }
        return nil
    }
}



extension InternationalRequestDetailVC: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        
        if let img = image {
            if let status = getStatus() {
                if let key = getImgKey() {
                    self.changeRequestStatus(status: status, airport: nil, flightNo: nil, vesselId: nil, sourcePortId: nil, destinationPortId: nil, imgKey: key, img: img) { (msg, success) in
                        
                        self.theTableView.reloadData()
                        
                        guard let req = self.theRequest else { return }
                        
                        if req.tripStatus == "COMPLETED" {
                            self.showPaymentView = true
                        }
                        self.checkSetup()
                    }
                }
            }
        }
    }
    
    func didSelect(videoUrl: NSURL?) {
    }
}
