//
//  UserRepositoryProtocol.swift
//  MyCleanProjectt
//
//  Created by Hyunwoo Jeon on 7/8/25.
//

import Foundation

protocol UserRepositoryProtocol {
    
    func fetchUser(query: String, page: Int) async -> Result<UserListResult, NetworkError> //유저 리스트 불러오기 (원격)
    func getFavoriteUsers() -> Result<[UserListItem], CoreDataError> //전체 즐겨찾기 리스트 불러오기
    func saveFavoriteUser(user: UserListItem) -> Result<Bool, CoreDataError>
    func deleteFavoriteUser(userID: Int) -> Result<Bool, CoreDataError>
}
