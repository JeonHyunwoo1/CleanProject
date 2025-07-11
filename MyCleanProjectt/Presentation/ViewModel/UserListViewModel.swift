//
//  UserListViewModel.swift
//  MyCleanProjectt
//
//  Created by Hyunwoo Jeon on 7/10/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol UserListViewModelProtocol {
    
}

public final class UserListViewModel: UserListViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let error = PublishRelay<String>()
    private let fetchUserList = BehaviorRelay<[UserListItem]>(value: [])  // fetchUser
    private let allFavoriteUserList = BehaviorRelay<[UserListItem]>(value: []) //즐겨찾기 여부가 포함된 전체 목록
    private let favoriteUserList = BehaviorRelay<[UserListItem]>(value: []) //즐겨찾기 목록에 보여줄 리스트
    private var page: Int = 1
    
    private let usecase: UserListUsecaseProtocol
    public init(usecase: UserListUsecaseProtocol) {
        self.usecase = usecase
    }
    
    public struct Input {
        let tabButtonType: Observable<TabButtonType>
        let query: Observable<String>
        let saveFavorite: Observable<UserListItem>
        let deleteFavorite: Observable<Int>
        let fetchMore: Observable<Void>
    }
    
    public struct Output {
        let cellData: Observable<[UserListCellData]>
        let error: Observable<String>
    }
    
    //상단 텍스트필드
    //하단 api탭 / 즐겨찾기 탭
    
    public func transform(input: Input) -> Output {   //VC 이벤트 -> VM 데이터
        
        input.query.bind { [weak self] query in
            guard let self = self, validateQuery(query: query) else {
                self?.getFavoriteUsers(query: query)
                return
            }
            page = 1
            fetchUser(query: query, page: page)
            getFavoriteUsers(query: query)
        }.disposed(by: disposeBag)
        
        input.saveFavorite
            .withLatestFrom(input.query, resultSelector: { users, query in
                return (users, query)
            })
            .bind { [weak self] user, query in
            self?.saveFavoriteUser(user: user, query: query)
        }.disposed(by: disposeBag)
        
        input.deleteFavorite
            .withLatestFrom(input.query, resultSelector: { ($0, $1)})
            .bind { [weak self] userID, query in
                self?.deleteFavoriteUser(userID: userID, query: query)
        }.disposed(by: disposeBag)
        
        input.fetchMore
            .withLatestFrom(input.query)
            .bind { [weak self] query in
                guard let self = self else { return }
                self.page += 1
                self.fetchUser(query: query, page: page)
            }.disposed(by: disposeBag)
        
        //유저리스트, 즐겨찾기 리스트
        let cellData: Observable<[UserListCellData]> = Observable.combineLatest(input.tabButtonType, fetchUserList, favoriteUserList, allFavoriteUserList).map { [weak self] tabButtonType, fetchUserList, favoriteUserList, allFavoriteUserList in
            var cellData: [UserListCellData] = []
            guard let self = self else { return cellData }
            //TODO: cellData 생성
            //Tab 타입에 따라 fetchUser List // Favorite User list
            switch tabButtonType {
            case .api:
                
                let tuple = usecase.checkFavoriteState(fetchUsers: fetchUserList, favoriteUsers: allFavoriteUserList)
                let userCellList = tuple.map { user, isFavorite in
                    UserListCellData.user(user: user, isFavorite: isFavorite)
                }
                
                return userCellList
            case .favorite:
                let dict = usecase.convertListToDictionary(favoriteUsers: favoriteUserList)
                let keys = dict.keys.sorted()
                keys.forEach { key in
                    cellData.append(.header(key))
                    if let users = dict[key] {
                        
                        cellData += users.map { UserListCellData.user(user: $0, isFavorite: true)}
                    }
                }
            }
            return cellData
        }
        
        return Output(cellData: cellData, error: error.asObservable())
    }
    
    private func fetchUser(query: String, page: Int) {
        guard let urlAllowedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        Task {
            let result = await usecase.fetchUser(query: query, page: page)
            switch result {
            case .success(let users):
                //첫번째 페이지
                if page == 0 {
                    fetchUserList.accept(users.items)
                } else {
                    //두번째 그 이상 페이지
                    fetchUserList.accept(fetchUserList.value + users.items)
                }
            case .failure(let error):
                self.error.accept(error.description)
            }
        }
    }
    
    private func getFavoriteUsers(query: String) {
        let result = usecase.getFavoriteUsers()
        switch result {
        case .success(let users):
            //검색어가 있을때 필터링
            if query.isEmpty {
                favoriteUserList.accept(users)
            } else {
                let filteredUsers = users.filter { user in
                    user.login.contains(query)
                }
                
                favoriteUserList.accept(filteredUsers)
            }
            
            allFavoriteUserList.accept(users)
            //전체 리스트
        case .failure(let error):
            self.error.accept(error.description)
        }
    }
    
    private func saveFavoriteUser(user: UserListItem, query: String) {
        let result = usecase.saveFavoriteUser(user: user)
        switch result {
        case .success:
            getFavoriteUsers(query: query)
        case let .failure(error):
            self.error.accept(error.description)
        }
    }
    
    private func deleteFavoriteUser(userID: Int, query: String) {
        let result = usecase.deleteFavoriteUser(userID: userID)
        switch result {
        case .success:
            getFavoriteUsers(query: query)
        case let .failure(error):
            self.error.accept(error.description)
        }
    }
    
    private func validateQuery(query: String) -> Bool {
        if query.isEmpty {
            return false
        } else {
            return true
        }
    }
}

public enum TabButtonType {
    case api
    case favorite
}

public enum UserListCellData {
    case user(user: UserListItem, isFavorite: Bool)
    case header(String)
}
