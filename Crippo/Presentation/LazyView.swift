//
//  LazyView.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import SwiftUI

struct LazyView<Content: View>: View {
    
    let build: () -> Content
    
    var body: Content {
        build()
    }
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
}
