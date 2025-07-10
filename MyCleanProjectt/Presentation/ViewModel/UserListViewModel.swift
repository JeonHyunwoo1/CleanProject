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
    
    public func transform(input: Input) -> Output {   //VC 이벤트 -> VM 데이터
        input.query.bind { query in
            //TODO: 상황에 맞춰서 user Fetch
        }.disposed(by: disposeBag)
        
        input.saveFavorite.bind { user in
            //TODO: 즐겨찾기 추가
        }.disposed(by: disposeBag)
        
        input.deleteFavorite.bind { userID in
            //TODO: 즐겨찾기 삭제
        }.disposed(by: disposeBag)
        
        input.fetchMore.bind {
            //TODO: 다음 페이지 검색
        }.disposed(by: disposeBag)
        
        //유저리스트, 즐겨찾기 리스트
        let cellData: Observable<[UserListCellData]> = Observable.combineLatest(input.tabButtonType, fetchUserList, favoriteUserList).map { tabButtonType, fetchUserList, favoriteUserList in
            let cellData: [UserListCellData] = []
            //TODO: cellData 생성
            return cellData
        }
        
        return Output(cellData: cellData, error: error.asObservable())
    }
}

public enum TabButtonType {
    case api
    case favorite
}

public enum UserListCellData {
    case user
    case header
}
