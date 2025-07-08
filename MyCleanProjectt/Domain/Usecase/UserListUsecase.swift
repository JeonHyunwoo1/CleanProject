//
//  UserListUsecase.swift
//  MyCleanProjectt
//
//  Created by Hyunwoo Jeon on 7/8/25.
//

import Foundation

public protocol UserListUsecaseProtocol {
    
    func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError> //유저 리스트 불러오기 (원격)
    func getFavoriteUsers() -> Result<[UserListItem], CoreDataError> //전체 즐겨찾기 리스트 불러오기
    func saveFavoriteUser(user: UserListItem) -> Result<Bool, CoreDataError>
    func deleteFavoriteUser(userID: String) -> Result<Bool, CoreDataError>
    
    //배열 -> Dictionary [초성: [유저리스트]]
    //유저리스트 - 즐겨찾기 포함된 유저인지
}

public struct UserListUsecase: UserListUsecaseProtocol {
    
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError> {
        return await repository.fetchUser(query: query, page: page)
    }
    
    public func getFavoriteUsers() -> Result<[UserListItem], CoreDataError> {
        repository.getFavoriteUsers()
    }
    
    public func saveFavoriteUser(user: UserListItem) -> Result<Bool, CoreDataError> {
        repository.saveFavoriteUser(user: user)
    }
    
    public func deleteFavoriteUser(userID: String) -> Result<Bool, CoreDataError> {
        repository.deleteFavoriteUser(userID: userID)
    }
    
    
}
