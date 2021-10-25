//
//  InternationalRequestDetailCell.swift
//  RoadStarRider
//
//  Created by Faizan Ali  on 2021/6/26.
//  Copyright © 2021 Faizan Ali . All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SDWebImage

class InternationalRequestDetailCell: UITableViewCell {

    @IBOutlet weak var theButton: PrimaryButton!
    @IBOutlet weak var txtItemName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDeliveryFrom: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDeliveryTo: SkyFloatingLabelTextField!
    @IBOutlet weak var txtArrivalDate: SkyFloatingLabelTextField!
    @IBOutlet weak var txtItemSize: SkyFloatingLabelTextField!
    @IBOutlet weak var txtItemType: SkyFloatingLabelTextField!
    @IBOutlet weak var txtViewParcelDetail: PrimaryTextView!
    @IBOutlet var imgAttachments: [UIImageView]!
    
    
    var request: InternationalRequest? = nil
    var theRequest: ScheduledTripResponse? = nil
    var parent: InternationalRequestDetailVC!
    
    func setUp(request: InternationalRequest, parent: InternationalRequestDetailVC) {

        theButton.setTitle("ADD BID", for: .normal)
        self.request = request
        self.parent = parent
        let itemName = request.item ?? ""
        let deliveryFrom = request.tripfrom ?? ""
        let deliveryTo = request.tripto ?? ""
        let arrivalData = request.arrivalDate ?? ""
        let itemSize = request.itemSize ?? ""
        let itemType = request.itemType ?? ""
        let parcelDetail = request.otherInformation ?? ""
        
        txtItemName.text = itemName
        txtDeliveryFrom.text = deliveryFrom
        txtDeliveryTo.text = deliveryTo
        txtArrivalDate.text = arrivalData
        txtItemSize.text = itemSize
        txtItemType.text = itemType
        txtViewParcelDetail.text = parcelDetail
        
        let img1 = request.picture1
        let img2 = request.picture2
        let img3 = request.picture3
        
        if let img = img1 {
            if let url = URL(string: img) {
                imgAttachments[0].sd_imageIndicator = SDWebImageActivityIndicator.gray
                imgAttachments[0].sd_setImage(with: url, placeholderImage: UIImage(named: "manPHIcon"))
            }
        }
        
        if let img = img2 {
            if let url = URL(string: img) {
                imgAttachments[1].sd_imageIndicator = SDWebImageActivityIndicator.gray
                imgAttachments[1].sd_setImage(with: url, placeholderImage: UIImage(named: "manPHIcon"))
            }
        }
        
        if let img = img3 {
            if let url = URL(string: img) {
                imgAttachments[2].sd_imageIndicator = SDWebImageActivityIndicator.gray
                imgAttachments[2].sd_setImage(with: url, placeholderImage: UIImage(named: "manPHIcon"))
            }
        }
        
    }
    
    func getButtonTitle() -> String {
        
        guard let req = self.theRequest else { return "START PROCESS" }
        
        if req.tripStatus == "SCHEDULED" {
            return "START PROCESS"
        } else if req.tripStatus == "ARRIVED" {
            return "TAP WHEN ARRIVED"
        } else if req.tripStatus == "PICKEDUP" {
            return "PICKUP PACKAGE"
        } else if req.tripStatus == "DROPPED" {
            return "TAP WHEN DELIVERED"
        }
        return "START PROCESS"
    }
    
    func setUpTheRequest(request: ScheduledTripResponse, parent: InternationalRequestDetailVC) {

        self.theRequest = request
        theButton.setTitle(getButtonTitle(), for: .normal)
        theButton.isHidden = request.tripStatus == "COMPLETED"
        
        self.parent = parent
        let itemName = request.item ?? ""
        let deliveryFrom = request.tripfrom ?? ""
        let deliveryTo = request.tripto ?? ""
        let arrivalData = request.arrivalDate ?? ""
        let itemSize = request.itemSize ?? ""
        let itemType = request.itemType ?? ""
        let parcelDetail = request.otherInformation ?? ""
        
        txtItemName.text = itemName
        txtDeliveryFrom.text = deliveryFrom
        txtDeliveryTo.text = deliveryTo
        txtArrivalDate.text = arrivalData
        txtItemSize.text = itemSize
        txtItemType.text = itemType
        txtViewParcelDetail.text = parcelDetail
        
        let img1 = request.picture1
        let img2 = request.picture2
        let img3 = request.picture3
        
        if let img = img1 {
            if let url = URL(string: img) {
                imgAttachments[0].sd_imageIndicator = SDWebImageActivityIndicator.gray
                imgAttachments[0].sd_setImage(with: url, placeholderImage: UIImage(named: "manPHIcon"))
            }
        }
        
        if let img = img2 {
            if let url = URL(string: img) {
                imgAttachments[1].sd_imageIndicator = SDWebImageActivityIndicator.gray
                imgAttachments[1].sd_setImage(with: url, placeholderImage: UIImage(named: "manPHIcon"))
            }
        }
        
        if let img = img3 {
            if let url = URL(string: img) {
                imgAttachments[2].sd_imageIndicator = SDWebImageActivityIndicator.gray
                imgAttachments[2].sd_setImage(with: url, placeholderImage: UIImage(named: "manPHIcon"))
            }
        }
        
    }
    
    @IBAction func btnBidNowTapped(_ sender: UIButton) {
        
        if let req = request {
            if let id = req.id {
                let vc = InternationalSubmitRequestVC.instantiateMenu()
                vc.setup(id: String(id)) {
                    self.parent.navigationController?.popToRootViewController(animated: true)
                }
                parent.present(vc, animated: true, completion: nil)
            }
        } else if let theReq = theRequest {
            
            if theReq.tripStatus == "SCHEDULED" {
                if theReq.serviceType == "By Air" {
                    let vc = InternationalProcessStartVC.instantiateMenu()
                    vc.initialize(delegate: parent)
                    parent.present(vc, animated: true, completion: nil)
                } else if theReq.serviceType == "" {}
                
            } else if theReq.tripStatus == "ARRIVED" {
                if let status = parent.getStatus() {
                    parent.changeRequestStatus(status: status, airport: nil, flightNo: nil, vesselId: nil, sourcePortId: nil, destinationPortId: nil, imgKey: nil, img: nil) { (msg, success) in
                        
                        self.parent.theTableView.reloadData()
                    }
                }
            } else if theReq.tripStatus == "PICKEDUP" {
                
                self.parent.imagePicker.present(from: sender, showCamera: true, showLibrary: true)
            } else if theReq.tripStatus == "DROPPED" {
                self.parent.imagePicker.present(from: sender, showCamera: true, showLibrary: true)
            }
            
        }
        
        
        
    }
}

//ARRIVED
//PICKEDUP
//DROPPED
//COMPLETED
//RATE
