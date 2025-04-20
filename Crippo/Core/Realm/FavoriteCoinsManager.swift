//
//  FavoriteCoinsManager.swift
//  Crippo
//
//  Created by 이빈 on 4/20/25.
//

import Foundation
import RealmSwift

class FavoriteCoinDataService {
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
    func add(coinID: String) {
        // 이미 있는지 확인
        if realm.object(ofType: FavoriteCoin.self, forPrimaryKey: coinID) != nil {
            return
        }
        
        // 즐겨찾기가 10개 이상인지 확인
        if (favoriteCoins?.count ?? 0) >= maxFavorites {
            // 가장 오래된 항목 삭제
            if let oldestCoin = favoriteCoins?.last {
                do {
                    try realm.write {
                        realm.delete(oldestCoin)
                    }
                } catch {
                    print("Error removing oldest favorite coin: \(error)")
                }
            }
        }
        
        let favoriteCoin = FavoriteCoin()
        favoriteCoin.coinID = coinID
        favoriteCoin.date = Date()
        
        do {
            try realm.write {
                realm.add(favoriteCoin)
            }
        } catch {
            print("Error adding favorite coin: \(error)")
        }
    }
    
    // 코인 즐겨찾기 제거
    func remove(coinID: String) {
        if let favoriteCoin = realm.object(ofType: FavoriteCoin.self, forPrimaryKey: coinID) {
            do {
                try realm.write {
                    realm.delete(favoriteCoin)
                }
            } catch {
                print("Error removing favorite coin: \(error)")
            }
        }
    }
}
