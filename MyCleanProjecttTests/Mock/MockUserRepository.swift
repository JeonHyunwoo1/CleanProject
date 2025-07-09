//
//  MockUserRepository.swift
//  MyCleanProjecttTests
//
//  Created by Hyunwoo Jeon on 7/9/25.
//

import Foundation
@testable import MyCleanProjectt

public struct MockUserRepository: UserRepositoryProtocol {
    public func fetchUser(query: String, page: Int) async -> Result<MyCleanProjectt.UserListResult, MyCleanProjectt.NetworkError> {
        .failure(.dataNil)
    }
    
    public func getFavoriteUsers() -> Result<[MyCleanProjectt.UserListItem], MyCleanProjectt.CoreDataError> {
        .failure(.readError(""))
    }
    
    public func saveFavoriteUser(user: MyCleanProjectt.UserListItem) -> Result<Bool, MyCleanProjectt.CoreDataError> {
        .failure(.saveError(""))
    }
    
    public func deleteFavoriteUser(userID: String) -> Result<Bool, MyCleanProjectt.CoreDataError> {
        .failure(.deleteError(""))
    }
    
    
}
