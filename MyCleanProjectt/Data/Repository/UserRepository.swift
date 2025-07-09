//
//  UserRepository.swift
//  MyCleanProjectt
//
//  Created by Hyunwoo Jeon on 7/9/25.
//

import Foundation

public struct UserRepository: UserRepositoryProtocol {
    
    private let network: UserNetworkProtocol
    private let coredata: UserCoreDataProtocol
    
    init(network: UserNetworkProtocol, coredata: UserCoreDataProtocol) {
        self.network = network
        self.coredata = coredata
    }
    func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError> {
        return await self.network.fetchUsers(query: query, page: page)
    }
    
    func getFavoriteUsers() -> Result<[UserListItem], CoreDataError> {
        return coredata.getFavoriteUsers()
    }
    
    func saveFavoriteUser(user: UserListItem) -> Result<Bool, CoreDataError> {
        return coredata.saveFavoriteUser(user: user)
    }
    
    func deleteFavoriteUser(userID: String) -> Result<Bool, CoreDataError> {
        return coredata.deleteFavoriteUser(userID: userID)
    }
    
    
}
