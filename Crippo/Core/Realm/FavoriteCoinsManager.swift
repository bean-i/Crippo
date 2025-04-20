//
//  FavoriteCoinsManager.swift
//  Crippo
//
//  Created by 이빈 on 4/20/25.
//

import Foundation
import RealmSwift

enum FavoriteActionResult {
    case added      // 추가됨
    case removed    // 삭제됨
    case limitReached // 최대 개수 도달
}

final class FavoriteCoinDataService {
    private var favoriteCoins: Results<FavoriteCoin>?
    private let realm = try! Realm()
    private let maxFavorites = 10
    
    static let shared = FavoriteCoinDataService()
    
    init() {
        fetchFavoriteCoins()
    }
    
    // 데이터 가져오기
    private func fetchFavoriteCoins() {
        favoriteCoins = realm.objects(FavoriteCoin.self).sorted(byKeyPath: "date", ascending: false)
    }
    
    // 즐겨찾기 목록 가져오기
    func getAllFavoriteCoins() -> [FavoriteCoin] {
        return favoriteCoins?.compactMap { $0 } ?? []
    }
    
    // 코인 즐겨찾기 추가
    func add(coinID: String) -> FavoriteActionResult {
        // 이미 있는지 확인
        if realm.object(ofType: FavoriteCoin.self, forPrimaryKey: coinID) != nil {
            return .added
        }
        
        // 즐겨찾기가 10개 이상인지 확인
        let currentCount = realm.objects(FavoriteCoin.self).count
        if currentCount >= maxFavorites {
            // 이미 10개가 있으면 추가하지 않음
            print("최대 즐겨찾기 개수(10개)에 도달했습니다.")
            return .limitReached
        }
        
        let favoriteCoin = FavoriteCoin()
        favoriteCoin.coinID = coinID
        favoriteCoin.date = Date()
        
        do {
            try realm.write {
                realm.add(favoriteCoin)
            }
            return .added
        } catch {
            print("Error adding favorite coin: \(error)")
            return .limitReached
        }
    }
    
    // 코인 즐겨찾기 제거
    func remove(coinID: String) -> FavoriteActionResult {
        if let favoriteCoin = realm.object(ofType: FavoriteCoin.self, forPrimaryKey: coinID) {
            do {
                try realm.write {
                    realm.delete(favoriteCoin)
                }
                return .removed
            } catch {
                print("Error removing favorite coin: \(error)")
                return .removed
            }
        }
        return .removed
    }
    
    func isFavorite(coinID: String) -> Bool {
        return realm.object(ofType: FavoriteCoin.self, forPrimaryKey: coinID) != nil
    }
}
