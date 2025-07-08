//
//  UserSession.swift
//  MyCleanProjectt
//
//  Created by Hyunwoo Jeon on 7/8/25.
//

import Foundation
import Alamofire

public protocol SessionProtocol {
    func request(_ convertible: URLConvertible,
                 method: HTTPMethod,
                 parameters: Parameters?,
                 headers: HTTPHeaders?) -> DataRequest
}

class UserSession: SessionProtocol {
    
    private var session: Session
    
    init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        let logger = NetworkLogger()
        self.session = Session(configuration: config, eventMonitors: [logger])
    }
    
    func request(_ convertible: URLConvertible,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 headers: HTTPHeaders? = nil) -> DataRequest {
        return session.request(convertible, method: method, parameters: parameters, headers: headers)
    }
}

final class NetworkLogger: EventMonitor {
    let queue = DispatchQueue(label: "networklogger.queue")
    
    func requestDidResume(_ request: Request) {
        print("➡️ [UserSession] REQUEST: \(request.description)")
        if let headers = request.request?.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        
        if let body = request.request?.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }
    
    func request<Value>(_ request: DataRequest,
                        didParseResponse response: DataResponse<Value, AFError>) {
        print("⬅️ [UserSession] RESPONSE for \(request.description)")
                if let data = response.data,
                   let bodyString = String(data: data, encoding: .utf8) {
                    print("Response Body: \(bodyString)")
                }
                if let error = response.error {
                    print("❌ Error: \(error)")
                } else {
                    print("✅ Success")
                }
    }
}
