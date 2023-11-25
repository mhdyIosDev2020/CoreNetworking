//
//  URLPath.swift
//  CoreNetworking
//
//  Created by Mahdi_iOS on 21/08/23.
//


import Foundation

//MARK: Base URL


private var _baseURL: String {
    guard let BaseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
        fatalError("BASE URL not set in plist for this environment")
    }
    return BaseURL
}

private let v02 :String = "/0.2"
private let APIA :String = "/APIA"
private let https: String = "https://"
private let http: String = "http://"
private let wss: String = "wss://"


//private var _wsBaseURL: String {
//    return Environment.wsBaseURL
//}

//MARK: URLPath
struct URLPath: Equatable {
    
    var stringValue: String
    var getURL: URL? {
        return URL(string: stringValue) ?? URL(string: stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
    
    var getURLRequest: URLRequest? {
        guard let url = getURL else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    init(_ rawValue: String) {
        self.stringValue = rawValue
    }
    
    //MARK: Operators
    static func / (lhs: URLPath, rhs: URLPath) -> URLPath {
        return URLPath("\(lhs.stringValue)/\(rhs.stringValue)")
    }
    
    static func / (lhs: URLPath, rhs: String) -> URLPath {
        return lhs / URLPath(rhs)
    }
    
    static func / <T: Numeric>(lhs: URLPath, rhs: T) -> URLPath {
        return lhs / URLPath("\(rhs)")
    }
    
    static func & (lhs: URLPath, rhs: String) -> URLPath {
        return URLPath(lhs.stringValue + rhs)
    }

    //MARK: - URLs
    private (set) static var baseURL = URLPath(_baseURL)
//    private (set) static var wsBaseURL = URLPath(_wsBaseURL)
    static let imageBaseURL = URLPath("")
    static let images = URLPath("images")
    static let x64 = URLPath("64x64")
    static let x32 = URLPath("32x32")
    static let LoginWithEmailandPassword = URLPath("LoginWithEmailandPassword")
    static let authentication = URLPath("authentication")

    
}

