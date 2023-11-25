//
//  WebService.swift
//  CoreNetworking
//
//  Created by Mahdi_iOS on 21/08/23.
//
import CodeClanCore
import Foundation
//
//  Webservice.swift
//  JOBSIOS
//
//  Created by mhdyHashemloo on 11/22/1401 AP.
//

import Foundation
import Alamofire
public class NetworkState {
    
    static func isConnected() ->Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
}


public struct Authenticate: Codable {
    
    public enum AuthenticateType {
        case token
        case noAuth
    }
}


public struct NetworkError : Codable, Error {
    var Message: String = "Something goes wrong"
    var status_code: Int?
    
}

//extension NetworkError {
//    var description: String {
//        guard let errors = self.errors else {
//            return message ?? ""
//        }
////        return errors.first?.value.first ?? ""
//        return "description not settled"
//    }
//}

// TODO: make retrier interceptor for Network
public class Network {
    static let sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        let eventMonitor = CaveHttpLogger()
        let sessionManager = Session(configuration: configuration, interceptor: RequestInterceptor(), eventMonitors: [eventMonitor])
        return sessionManager
    }()
    
    
    public static var shared : Network = {
        let configuration = URLSessionConfiguration.af.default
        let eventMonitor = CaveHttpLogger()
        let session = sessionManager
        let net = Network(session: session)
        return net
    }()
    
    
    
    var session : Session
    
    public init(session: Session) {
        self.session = session
    }
    
    public func request<T: Decodable>(_ convertible: URLRequestConvertible,
                               authenticate: Authenticate.AuthenticateType? = .token)  async -> Result<T, NetworkError>? {
        switch NetworkState.isConnected() {
        case true:
            let request =  Network.shared.session.request(convertible)
            let decodableResponse = await request.serializingDecodable(T.self,automaticallyCancelling: true).response
            let response = decodableResponse.result

            switch response {

            case .success(let response):
                return .success(response)
            case .failure(let error):
                Global.Funcs.log(" Failure response on \(String(describing: convertible.urlRequest?.url))",type: .error)
                if decodableResponse.response?.statusCode == 401 || decodableResponse.response?.statusCode == 403 {
                    
                    let errors = try? JSONDecoder().decode(NetworkError.self, from: decodableResponse.data ?? Data())
                    Helper.logout()
                    return .failure(errors ?? NetworkError())
                    //                    completion(.failure(errors ?? NetworkError()))
                    
                    
                }else{
                    
                    switch error {
                    case .responseSerializationFailed(let reason):
                        if case .inputDataNilOrZeroLength = reason  {
                            if let res = NullResponse() as? T {
                                return .success(res)
                            }
                            //                            return
                        }
                    default:
                        break
                    }
                    guard let data = decodableResponse.data else {
                        //                        completion(.failure(NetworkError(message: "Somthing wrong happened")))
                        return .failure(NetworkError(Message: "Somthing wrong happened"))
                    }
                    let errors = try? JSONDecoder().decode(NetworkError.self, from: data)
                    
                    Global.Funcs.log(" Failure response on \(String(describing: convertible.urlRequest?.url))",type: .error)
                    
                    
                    
                    return .failure(errors ?? NetworkError())
                    //                    completion(.failure(errors ?? NetworkError()))
                    
                }
                
            }
            
            
        case false:
            return .failure(NetworkError(Message: ""))
        }
        
    }
    
    
    
    public func request<T: Decodable>(_ convertible: URLRequestConvertible,
                                      authenticate: Authenticate.AuthenticateType? = .token,
                                      completion: @escaping (Result<T, NetworkError>) -> ()) {
        
        
        switch NetworkState.isConnected() {
            
        case true:
            
            Network.shared.session.request(convertible).validate().responseDecodable(of: T.self) { (response) in
                
                switch response.result {
                    
                case .failure(let error):
                    logMessage(" Failure response on \(String(describing: convertible.urlRequest?.url))",type: .error)
                    //                        debugPrint("⚠️ Failure response on \(String(describing: convertible.urlRequest?.url)) ⭕️ error: \(error)")
                    if response.response?.statusCode == 401 || response.response?.statusCode == 403 {
                        
                        let errors = try? JSONDecoder().decode(NetworkError.self, from: response.data ?? Data())
                        completion(.failure(errors ?? NetworkError()))
                        Helper.logout()
                        
                    } else {
                        
                        switch error {
                        case .responseSerializationFailed(let reason):
                            if case .inputDataNilOrZeroLength = reason  {
                                if let res = NullResponse() as? T {
                                    completion(.success(res))
                                    return
                                }
                                return
                            }
                        default:
                            break
                        }
                        guard let data = response.data else {
                            completion(.failure(NetworkError(Message: "Somthing wrong happened")))
                            return
                        }
                        
                        //                            do{
                        //                                var errors = try? JSONDecoder().decode(NetworkError.self, from: data)
                        //                                errors?.status_code = response.response?.statusCode
                        //
                        //                            }
                        //
                        //                            catch{
                        //                                print("catch")
                        //                            }
                        var errors = try? JSONDecoder().decode(NetworkError.self, from: data)
                        errors?.status_code = response.response?.statusCode
                        Global.Funcs.log(" Failure response on \(String(describing: convertible.urlRequest?.url))",type: .error)
                        completion(.failure(errors ?? NetworkError(status_code: response.response?.statusCode)))
                        
                    }
                case .success(let response):
                    completion(.success(response))
                }
            }
        case false:
            
            completion(.failure(NetworkError(Message: "")))
        }
    }
    
    
}

final class RequestInterceptor: Alamofire.RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        var urlRequest = urlRequest
        // Set the Authorization header value using the access token.
        guard let token = Tokens.accessToken else {
            completion(.success(urlRequest))
            return
        }
        urlRequest.headers.add(.authorization(bearerToken: token))
        completion(.success(urlRequest))
    }
    
}



// MARK: - Upload
extension Network {
    
    public func upload<T: Decodable>(_ convertible: URLRequestConvertible,
                                     headers: HTTPHeaders?,
                                     file: Data,
                                     completion: @escaping (Result<T, NetworkError>) -> ()) {
        
        
        session.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(file, withName: "image", fileName: "file.jpg", mimeType: "image/jpeg")
            
            if headers != nil {
                guard let headers = headers else { return }
                for header in headers {
                    multipartFormData.append(header.value.data(using: .utf8, allowLossyConversion: false)!, withName: header.name)
                }
                
            }
            
        }, with: convertible).responseData(completionHandler: { (response) in
            
            
            switch response.result {
                
            case .failure(let error):
                
                
                
                Global.Funcs.log(" Failure response on \(String(describing: convertible.urlRequest?.url))",type: .error)
                
                
                if response.response?.statusCode == 401 || response.response?.statusCode == 403 {
                    
                    
                    
                    Global.Funcs.log(" Failure response on \(String(describing: convertible.urlRequest?.url))",type: .error)
                    completion(.failure(NetworkError(status_code: response.response?.statusCode )))
                    Helper.logout()
                    
                } else {
                    
                    switch error {
                    case .responseSerializationFailed(let reason):
                        if case .inputDataNilOrZeroLength = reason  {
                            if let res = NullResponse() as? T {
                                completion(.success(res))
                                return
                            }
                            return
                        }
                    default:
                        break
                    }
                    guard let data = response.data else {
                        completion(.failure(NetworkError(Message: "Somthing wrong happened")))
                        return
                    }
                    let errors = try? JSONDecoder().decode(NetworkError.self, from: data)
                    Global.Funcs.log(" Failure response on \(String(describing: convertible.urlRequest?.url))",type: .error)
                    completion(.failure(errors ?? NetworkError()))
                    
                }
            case .success(let response):
                
                do {
                    let model = try JSONDecoder().decode(T.self, from: response)
                    completion(.success(model))
                } catch let jsonErr {
                    print("failed to decode, \(jsonErr)")
                }
            }
            
        }).uploadProgress(queue: .main) { (progress) in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        
        
    }
}
