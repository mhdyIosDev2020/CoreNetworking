//
//  LoginRegisterService.swift
//  CoreNetworking
//
//  Created by Mahdi_iOS on 24/08/23.
//

import Foundation
import Alamofire
import CodeClanCore

public enum AuthService: URLRequestConvertible {
    case sendFcmToken(deviceType:Int = 1 /*ios = 1*/,firebaseToken:String,model:String)
    case register(Email:String,FirstName:String,LastName:String,Password:String,Phone:String,Role:String,WayToKnow:String)

    case verificaionEmail(callbackUrl:String)
    case login(email : String, password : String)
    case resetPassword(email : String)
    
    var path: URLPath {
        
        switch self {
            
        case .register: return .baseURL / .authentication / .register
        case .login: return .baseURL / .authentication / .LoginWithEmailandPassword
        case .resetPassword: return .baseURL
            
        case .verificaionEmail:
            return .baseURL / .SendVerificationEmail
        case .sendFcmToken:
            return .baseURL / .SendUserDevice
        }
    }
    
    var timeInterval: TimeInterval {
        return 100000
    }
    
    var method: HTTPMethod {
        
        switch self {
        case .register:
            return .post
        case .login:
            return .post
        case .resetPassword:
            return .post
        case .verificaionEmail:
            return .post
        case .sendFcmToken:
            return .post
        }
    }
    
    var headers:  [String : String] {
        switch self {
            
        case .verificaionEmail,.sendFcmToken:
            return ["Content-Type": "application/json","Authorization": "Bearer \(Tokens.accessToken ?? "")"]
        default: return ["Content-Type": "application/json"]
        }
        
    }
    
    
    var parameters: Parameters? {
        
        switch self {
            
        case .login(email: let email, password : let password):
            return ["email" : email , "Password" : password]
            
        case .resetPassword(email: let email):
            return ["Email" : email]
            
        
        case .register(Email: let email, FirstName: let firstName, LastName: let lastName, Password: let Password, Phone: let phone, Role: let role, WayToKnow: let wayToKnow):
            
        return ["Email":email,"FirstName":firstName,"LastName":lastName,"Password":Password,"Phone":phone,"Role":role,"WayToKnow":wayToKnow]
            
        case .verificaionEmail(callbackUrl: let callbackUrl):
            return ["CallbackUrl" : callbackUrl]
        case .sendFcmToken(deviceType: let deviceType, firebaseToken: let firebaseToken, model: let model):
            return ["DeviceType" : deviceType , "FirebaseToken" : firebaseToken, "Model" : model]
        }
    }
    public func asURLRequest() throws -> URLRequest {
        
        guard let url =  path.getURL else {
            return URLRequest(url: URLPath.baseURL.getURL!)
        }
        let customHeaders = [
            "Content-Type": "application/json",
//            "Custom-Header": "custom value"
        ]
        
        var request = HttpRequestBuilder(url: url)
            .setHTTPMethod(method.rawValue)
            .addHeaders(customHeaders)
            .addAuthentication(token: "your_auth_token_here")
            .build()
        
        request.timeoutInterval = timeInterval//TimeInterval(10*1000)
        return try JSONEncoding.default.encode(request, with: parameters)
        
    }
    
    
    /***
     
     func request<T: Decodable>()
     usage:
     let result: Result<Your Data Type, NetworkError>? = try await Network.shared.request(request)
     .
     .
     .
     switch result {
     case .success(let response):
     // Handle successful response
     case .failure(let error):
     // Handle error
     case nil:
     // Handle nil result (network error or other)
     }
     
     ***/
    
    
    /// func request<T: Decodable>()
    ///usage:
    ///let result: Result<Your Data Type, NetworkError>? = try await Network.shared.request(request)
    public func request<T: Decodable>() async -> Result<T, NetworkError>? {
        //        return .failure(NetworkError(Message: "no url found!"))
        guard let url =  path.getURL else {
            return .failure(NetworkError(Message: "no url found!"))
        }
        let request = HttpRequestBuilder(url: url)
            .setHTTPMethod(method.rawValue)
            .addHeaders(headers)
//            .setHTTPBody(parameters)
            .setJSONBody(parameters!)
//            .addQueryParameters(parameters)
            .build()
        
        return await Network.shared.request(request)
    }
}
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
