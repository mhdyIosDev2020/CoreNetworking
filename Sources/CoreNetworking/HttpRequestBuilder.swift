//
//  HttpRequestBuilder.swift
//  CoreNetworking
//
//  Created by Mahdi_iOS on 24/08/23.
//

import Foundation

public class HttpRequestBuilder {
    private var url: URL
    private var httpMethod: String = "GET"
    private var headers: [String: String] = [:]
    private var httpBody: Data?  // Added property for HTTP body
    private var queryParams: [String: Any] = [:]
    
    public init(url: URL) {
        self.url = url
    }
    
    public func setHTTPMethod(_ method: String) -> Self {
        httpMethod = method
        return self
    }
    
    public func addHeaders(_ headersToAdd: [String: String]) -> Self {
        headers.merge(headersToAdd) { (_, new) in new }
        return self
    }
    public func addQueryParameters(_ parameters: [String: Any]?) -> Self {
        if let parameters = parameters {
            queryParams.merge(parameters) { (_, new) in new }
        }
        return self
    }
    public func addAuthentication(token: String) -> Self {
        headers["Authorization"] = "Bearer \(token)"
        return self
    }
    public func setHTTPBody(_ body: [String: Any]?) -> Self {
        if let body = body {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body)
                httpBody = jsonData
            } catch {
                print("Error encoding HTTP body:", error)
            }
        }
        return self
    }
    public func setJSONBody(_ dictionary: [String: Any]) -> Self {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
            self.httpBody = jsonData
//            return setHTTPBody(jsonData)
            return self
        } catch {
            print("Error encoding JSON body:", error)
            return self
        }
        
    }
    public func build() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = httpBody
        request.allHTTPHeaderFields = headers
        
        if !queryParams.isEmpty {
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = components.url
            }
        }
        
        
        return request
    }
}
/*
// Usage
if let url = URL(string: "https://example.com/api/endpoint") {
    let customHeaders = [
        "Content-Type": "application/json",
        "Custom-Header": "custom value"
    ]
    
    let request = HttpRequestBuilder(url: url)
        .setHTTPMethod("POST")
        .addHeaders(customHeaders)
        .addAuthentication(token: "your_auth_token_here")
        .build()
    
    // Now you can use the 'request' to make your network call
    // For example: URLSession.shared.dataTask(with: request) { ... }.resume()
}
*/

