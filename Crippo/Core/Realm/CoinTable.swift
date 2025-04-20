//
//  CoinTable.swift
//  Crippo
//
//  Created by 이빈 on 4/20/25.
//

import Foundation
import RealmSwift

class FavoriteCoin: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var coinID: String = ""
    @Persisted var id: String = UUID().uuidString
    @Persisted var date: Date = Date()
}
