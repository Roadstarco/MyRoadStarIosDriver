//
//  TheRoute.swift
//  RoadStarRider
//
//  Created by Faizan Ali  on 2021/4/7.
//  Copyright © 2021 Faizan Ali . All rights reserved.
//

import Foundation
import Alamofire


enum TheRoute: URLRequestBuilder {

    case signup(user:SingupModel)
    case login(user:LoginModel)
    case updateProfile(firstName: String, secName: String, email: String, mobile: String)
    case updatePassword(pass: String, confPass: String, oldPass: String)
    case sendSupport(subject: String, message: String)
    case summary
    case history
    case document
    case trip(latitude: String, longitude: String)
    case acceptRequest(reqId: String, method: String?, status: String?, airport: String?, flightNo: String?, vesselId: String?, sourcePortId: String?, destinationPortId: String?)
    case acceptInternationalRequest(reqId: String, method: String, status: String, airport: String?, flightNo: String?, vesselId: String?, sourcePortId: String?, destinationPortId: String?)
    
    case rateTripUser(tripId: String, rating: String, comment: String)
    case rateLocalTripUser(tripId: String, rating: String, comment: String)
    case bidUser(tripId: String, serviceType: String, travellerResponse: String, amount: String)
    case scheduledTrips
    case uploadDocument(documentId: String, documentName: String)
    
    
    internal var path: String {
        switch self {
        case .signup:
            return "register"
        case .login:
            return "oauth/token"
        case .updateProfile:
            return "profile"
        case .updatePassword:
            return "profile/password"
        case .sendSupport:
            return "support/message"
        case .summary:
            return "summary"
        case .history:
            return "requests/history"
        case .document:
            return "documents/display-provider-documents"
        case .trip:
            return "trip"
        case .acceptRequest(let id, _, _, _, _, _, _, _):
            return "trip/\(id)"
        case .acceptInternationalRequest:
            return "update-trip"
        case .rateTripUser:
            return "rate-trip-user"
        case .bidUser:
            return "bid-user-trip"
        case .scheduledTrips:
            return "provider-trips"
        case .rateLocalTripUser(let id, _, _):
            return "trip/\(id)/rate"
        case .uploadDocument:
            return "documents/upload"
        }
    }
    
    // MARK: - Parameters
    internal var parameters: Parameters? {
        var params = Parameters.init()
        switch self {
        
        case .login(let user):
            
            params["grant_type"] = user.grantType
            params["client_id"] = user.clientID
            params["client_secret"] = user.clientSecret
            params["email"] = user.email
            params["password"] = user.password
            params["scope"] = user.scope
            
        case .signup(let user):
            
            params["password"] = user.password
            params["email"] = user.email
            params["password_confirmation"] = user.password_confirmation
            params["first_name"] = user.first_name
            params["last_name"] = user.last_name
            params["home_address"] = user.home_address
            params["mobile"] = user.mobile
            params["login_by"] = user.login_by
            
        case .updateProfile(let fName, let sName, let email, let mobile):
            
            params["first_name"] = fName
            params["last_name"] = sName
            params["email"] = email
            params["mobile"] = mobile
            
        case .updatePassword(let pass, let confPass, let oldPass):
            
            params["password"] = pass
            params["password_confirmation"] = confPass
            params["password_old"] = oldPass
            
        case .sendSupport(let subject, let message):
            
            params["subject"] = subject
            params["message"] = message
            
        case .summary:
            break
            
        case .history:
            break
            
        case .document:
            break
            
        case .trip(let latitude, let longitude):
            
            params["latitude"] = latitude
            params["longitude"] = longitude
            
        case .acceptRequest(_, let method, let status, let airport, let flightNo, let vesselId, let sourcePortId, let destinationPortId):
            
            if method != nil {
                params["_method"] = method
            }
            if status != nil {
                params["status"] = status
            }
            if airport != nil {
                params["airport"] = airport
            }
            if flightNo != nil {
                params["flight_no"] = flightNo
            }
            if vesselId != nil {
                params["vessel_id"] = vesselId
            }
            if sourcePortId != nil {
                params["source_port_id"] = sourcePortId
            }
            if destinationPortId != nil {
                params["destination_port_id"] = destinationPortId
            }
            
        case .acceptInternationalRequest(let id, _, let status, let airport, let flightNo, let vesselId, let sourcePortId, let destinationPortId):
            
            params["trip_id"] = id
            params["trip_status"] = status
            if airport != nil {
                params["airport"] = airport
            }
            if flightNo != nil {
                params["flight_no"] = flightNo
            }
            if vesselId != nil {
                params["vessel_id"] = vesselId
            }
            if sourcePortId != nil {
                params["source_port_id"] = sourcePortId
            }
            if destinationPortId != nil {
                params["destination_port_id"] = destinationPortId
            }
            
        case .rateTripUser(let tripId, let rating, let comment):
            params["trip_id"] = tripId
            params["rating"] = rating
            params["comment"] = comment
            
        case .bidUser(let tripId, let serviceType, let travellerResponse, let amount):
            params["trip_id"] = tripId
            params["service_type"] = serviceType
            params["traveller_response"] = travellerResponse
            params["amount"] = amount
            
        case .scheduledTrips:
            break
            
        case .rateLocalTripUser(_, let rating, let comment):
            params["rating"] = rating
            params["comment"] = comment
            
        case .uploadDocument(let documentId, let documentName):
            params["document_id"] = ["\(documentId)"]
            params["document_name"] = ["\(documentName)"]
            
            
        }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        params["device_id"] = deviceId
        params["device_type"] = "ios"
        params["device_token"] = UserDefaults.standard.getDeviceToken() ?? "deviceId"
        print(params)
        return params
    }
    
    // MARK: - Methods
    internal var method: HTTPMethod {
        switch self {
        
        case .history, .document, .trip:
            return .get
        default:
            return .post
        }
    }
    // MARK: - HTTPHeaders
    internal var headers: HTTPHeaders {
        let header:HTTPHeaders =
            [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-Requested-With": "XMLHttpRequest",
                "Authorization": "Bearer \(UserSession.shared.user?.accessToken ?? "")",
            ]
        switch self {
        default:
            return header
        }
    }
    
}
