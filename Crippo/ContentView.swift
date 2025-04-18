//
//  ContentView.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LazyView(TrendingView())
                .tabItem {
                    Image(systemName: "chart.bar")
                }
            LazyView(SearchView())
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
            LazyView(FavoriteView())
                .tabItem {
                    Image(systemName: "bookmark")
                }
            LazyView(ProfileView())
                .tabItem {
                    Image(systemName: "person.crop.circle")
                }
        }
        .tint(.point)
    }
}

#Preview {
    ContentView()
}
