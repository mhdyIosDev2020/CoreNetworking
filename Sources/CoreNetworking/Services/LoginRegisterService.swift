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
    
    case register(email : String, password : String, userType : Int)
    case login(email : String, password : String)
    case resetPassword(email : String)
    
    var path: URLPath {
        
        switch self {
            
        case .register: return .baseURL / .authentication / .LoginWithEmailandPassword
        case .login: return .baseURL / .authentication / .LoginWithEmailandPassword
        case .resetPassword: return .baseURL
            
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
        }
    }
    
    var headers:  [String : String] {
        let customHeaders = [
            "Content-Type": "application/json",
        ]
        return customHeaders
    }
    
    
    var parameters: Parameters? {
        
        switch self {
            
        case .login(email: let email, password : let password):
            return ["email" : email , "Password" : password]
            
        case .resetPassword(email: let email):
            return ["Email" : email]
            
        case .register(email: let email, password : let password, userType : let userType):
            return ["Email" : email , "Password" : password, "userType" : userType]
            
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
