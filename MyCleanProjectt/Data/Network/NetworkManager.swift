//
//  NetworkManager.swift
//  MyCleanProjectt
//
//  Created by Hyunwoo Jeon on 7/8/25.
//

import Foundation
import Alamofire

protocol NetworkManagerProtocol {
    
    func fetchData<T: Decodable>(url: String, method: HTTPMethod, parameters: Parameters?) async -> Result<T, NetworkError>
    
}

public class NetworkManager: NetworkManagerProtocol {
    
    private let session: SessionProtocol
    
    public init(session: SessionProtocol) {
        self.session = session
    }
    
    private let tokenHeader: HTTPHeader = {
        
        let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] ?? ""
        let header = HTTPHeader(name: "Authorization", value: "Bearer \(token)")
        
        return header
    
    }()
    
    func fetchData<T: Decodable>(url: String, method: HTTPMethod = .get, parameters: Parameters? = nil) async -> Result<T, NetworkError> {
        guard let url = URL(string: url) else {
            return .failure(.urlError)
        }
        
        let result =  await session.request(url, method: method, parameters: parameters, headers: HTTPHeaders([tokenHeader])).serializingData().response
        
        if let error = result.error { return .failure(.requestFailed(error.localizedDescription))}
        guard let data = result.data else { return .failure(.dataNil) }
        guard let response = result.response else { return .failure(.invalidResponse )}
        
        if 200..<300 ~= response.statusCode {
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return .success(decoded)
            } catch {
                return .failure(.failToDecode(error.localizedDescription))
            }
        } else {
            return .failure(.serverError(response.statusCode))
        }
    }
}
