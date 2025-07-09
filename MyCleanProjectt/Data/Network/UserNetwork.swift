//
//  UserNetwork.swift
//  MyCleanProjectt
//
//  Created by Hyunwoo Jeon on 7/9/25.
//

import Foundation
import Alamofire

protocol UserNetworkProtocol {
    func fetchUsers(query: String, page: Int) async -> Result<UserListResult, NetworkError>
}

final public class UserNetwork: UserNetworkProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchUsers(query: String, page: Int) async -> Result<UserListResult, NetworkError> {
        
        let url = "https://api.github.com/search/users?q=\(query)&page=\(page)"
        
        return await networkManager.fetchData(url: url, method: .get, parameters: nil)
    }
}
