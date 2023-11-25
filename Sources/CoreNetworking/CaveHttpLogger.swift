//
//  CaveHttpLogger.swift
//  CoreNetworking
//
//  Created by Cave on 6/16/23.
//


import Alamofire
import SwiftUI
import Foundation

class CaveHttpLogger: EventMonitor {
    
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        guard let data = response.data, let responseBody = String(data: data, encoding: .utf8) else {
               return
           }
           
           print("Response Body:")
           print(responseBody)
    }
    
    func requestDidFinish(_ request: Alamofire.Request) {
        print("Request URL: \(request.description)")
        
        if let headers = request.response?.headers {
                 print("Request Headers:")
            
                 headers.forEach { key in
                     print("\(key)")
                 }
             }
        
        
        if let requestBody = request.request?.httpBody {
            if let requestBodyString = String(data: requestBody, encoding: .utf8) {
                print("Request Body: \(requestBodyString)")
            }
        }
        
//        if let response = request.response {
//                   if let responseData = response.url?.dataRepresentation {
//                       if let responseString = String(data: responseData, encoding: .utf8) {
//                           print("Response Data: \(responseString)")
//                       }
//                   }
//
//                   print("Response: \(response.description)")
//               }
        
        
        if let response = request.response?.url?.dataRepresentation {
            print("Response: \(response.description)")
        }
        
        
        
        if let response = request.response?.statusCode {
            print("StatusCode: \(response)")
        }
        
        print("------------------------------------")
    }
}
